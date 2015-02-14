---@module fimbul.ui.encounter_context

local battle_context = {}

local base = _G
local string = require("string")
local util = require("fimbul.util")

function battle_context:on_switch(d, args)
   local e = args

   if e == nil or not e then
      d:error("No encounter given.")
      return false
   end

   self.battle = self.repository:create_battle(e)

   return true
end

function battle_context:on_remove(d, args)
   d.list:remove(args, self.battle:members())
end

battle_context.on_rm = battle_context.on_remove

function battle_context:on_list(d, args)
   for _, i in base.pairs(self.battle.members) do
      d:fsay("%s (init = %d, hp = %d)",
             i.initiative, util.getname(i), i.hp)
   end
end

battle_context.on_ls = battle_context.on_list

function battle_context:new(repository)
   local neu = {}

   assert(repository, "battle_context need access to the repository")

   setmetatable(neu, self)
   self.__index = self

   neu.battle = nil
   neu.repository = repository
   neu.name = "battle"

   return neu
end

function battle_context:on_help(d, args)
   d:say([[
Battle - simulate a battle with characters vs. monster encounter

"list" "ls"                       ... Show all who participate in this skirmish.
"remove" "rm" i1 [, i2, ..., iN]  ... Remove characters or monsters from battle

]])
end

return battle_context
