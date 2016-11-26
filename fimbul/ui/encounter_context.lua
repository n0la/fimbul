---@module fimbul.ui.encounter_context

local encounter_context = {}

local base = _G
local string = require("string")

local pretty = require("pl.pretty")

function encounter_context:on_switch(d, args)
   if args then
      return self:on_select(d, {args})
   end

   return true
end

function encounter_context:check_encounter(d)
   if self.encounter == nil then
      d:error("No encounter selected.")
      return false
   end

   return true
end

function encounter_context:on_ls(d, args)
   local s = args[1] or ""
   local i = 0

   for _, e in pairs(self.repository:encounters()) do
      if s == "" or (s ~= "" and string.match(e.name, s)) then
         d:say(e.name)
         i = i + 1
      end
   end

   d:fsay("%d result(s) found.", i)
end

function encounter_context:on_select(d, args)
   local s = args[1]

   if type(s) == "string" then
      if s == nil or s == "" then
         d:error("Invalid encounter given.")
         return false
      end

      for _, e in pairs(self.repository.encounter) do
         if s == "" or (s ~= "" and string.match(e.name, s)) then
            self.encounter = e
            return true
         end
      end
   else
      self.encounter = s
      return true
   end

   return false
end

function encounter_context:on_start(d, args)
   if not self:check_encounter(d) then
      return
   end

   d:fsay("Spawning encounter '%s'.", self.encounter.name)
   local e = self.repository:spawn(self.encounter)
   d:switch_context("battle", e)
end

function encounter_context:on_help(d, args)
   d:say([[
Encounter - edit and view encounters available

"ls" "list"             ... Show a list of available encounters.
"select" [encounter]    ... Select another encounter.
"start"                 ... Start the encounter in a battle with the PCs.
   ]])
end

function encounter_context:new(repository)
   local neu = {}

   assert(repository, "encounter_context need access to the repository")

   setmetatable(neu, self)
   self.__index = self

   neu.encounter = nil
   neu.repository = repository
   neu.name = "encounter"

   return neu
end

encounter_context.on_list = encounter_context.on_ls

return encounter_context
