---@module fimbul.ui.encounter_context

local battle_context = {}

local base = _G
local string = require("string")
local pretty = require("pl.pretty")
local util = require("fimbul.util")
local dice_expression = require("fimbul.dice_expression")

function battle_context:on_switch(d, args)
   local e = args

   if e == nil or not e then
      d:error("No encounter given.")
      return false
   end

   self.battle = self.repository:create_battle(e)

   return true
end

function battle_context:on_damage(d, args)
   if not self.battle:has_started() then
      d:error("Battle must starte to deal/receive damage.")
      return
   end

   if #args < 2 then
      d:error("Need dice expression and at least one target for damage.")
      return
   end

   local expr = args[1]
   table.remove(args, 1)
   local targets = args

   local ok, d = self.repository.engine.damage(expr)
   if not ok then
      d:error(d)
      return
   end

   for _, t in base.pairs(targets) do
      util.foreach(self.battle.members,
                   function (i) self.battle:damage(i, d) end,
                   function (s) return util.name_matches(s, t) end)
   end
end

function battle_context:on_start(d, args)
   if self.battle:has_started() then
      d:error("The battle has already started.")
      return
   end

   self.battle:start()
end

function battle_context:on_next(d, args)
   if not self.battle:has_started() then
      d:error("The battle has not yet started. Use 'start'.")
      return
   end

   if self.battle:is_wipe() then
      d:error("There is no one left alive.")
      return
   end

   -- Next
   local newround, target = self.battle:next()

   if newround then
      d:fsay("Round #%d has started.", self.battle:current_round())
   end

   d:fsay("Now: %s", util.getname(target))
end

function battle_context:on_remove(d, args)
   d.list:remove(args, self.battle:members())
end

function battle_context:on_list(d, args)
   for _, i in base.pairs(self.battle.members) do
      d:fsay("%s (init = %d, hp = %d/%d)",
             util.getname(i), i.initiative, i.hp, i.max_hp)
   end
end

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

-- Alias
battle_context.on_s = battle_context.on_start
battle_context.on_n = battle_context.on_next
battle_context.on_rm = battle_context.on_remove
battle_context.on_ls = battle_context.on_list

function battle_context:on_help(d, args)
   d:say([[
Battle - simulate a battle with characters vs. monster encounter

"list" "ls"                       ... Show all who participate in this skirmish.
"next" "n"                        ... Jump to however is next in line for action.
"remove" "rm" i1 [, i2, ..., iN]  ... Remove characters or monsters from battle.
"start" "s"                       ... Start the skirmish.

Remove monsters or players who flee or which were summoned and now have
disappeared. Use kill for monsters that were actually defeated. Removed monsters
do not generate loot and gold, but defeated monsters do.

]])
end

return battle_context
