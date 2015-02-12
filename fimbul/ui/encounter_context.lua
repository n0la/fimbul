---@module fimbul.ui.encounter_context

local encounter_context = {}

local base = _G
local string = require("string")

local pretty = require("pl.pretty")

function encounter_context:on_switch(d, args)
   if args then
      self.encounter = args
   end
end

function encounter_context:check_encounter(d)
   if self.encounter == nil then
      d:error("No encounter selected.")
      return false
   end

   return true
end

function encounter_context:on_encounters(d, args)
   local s = args[1] or ""
   local i = 0

   if #self.repository.encounter == 0 then
      d:say("Repository has no encounters.")
      return
   end

   for _, e in pairs(self.repository.encounter) do
      if s == "" or (s ~= "" and string.match(e.name, s)) then
         d:say(e.name)
         i = i + 1
      end
   end

   d:fsay("%d result(s) found.", i)
end

function encounter_context:on_info(d, args)
   if not self:check_encounter(d) then
      return
   end

   d:fsay("Name: %s", self.encounter.name)
   d:fsay("Description: %s", self.encounter.description)
   d:fsay("Gold: %s", self.encounter.gold)
   d:fsay("Chance: %f", self.encounter.chance)

   d:say("\nMonsters:")
   for _, m in base.pairs(self.encounter.monsters) do
      d:fsay(" %s\t%s", m.amount, m.type)
   end
end

encounter_context.on_show = encounter_context.on_info
encounter_context.on_print = encounter_context.on_info

function encounter_context:on_help(d, args)
   d:say([[
Encounter - play a spawned encounter

"info" "show" "print"   ... Display information about the current encounter.
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

return encounter_context