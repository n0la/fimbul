---@module fimbul.eh.task

local task = {}

local stacked_value = require('fimbul.stacked_value')
local rules = require('fimbul.eh.rules')

task = stacked_value:new(rules.task.STACKING_RULES)

function task:new()
   local neu = stacked_value:new(rules.task.STACKING_RULES)

   setmetatable(neu, self)
   self.__index = self

   -- Associated skill (if any)
   neu._skill = nil
   -- The one performing the task
   neu._source = nil
   -- The target of the skill (if any)
   neu._target = nil
   -- Most tasks have a base of 5
   neu:add(rules.task.BASE, 'base')

   return neu
end

function task:skill()
   return self._skill
end

function task:ranged_attack(source, target, gun, range)
   local t = task:new()

   -- Add penalty for stance
   t:add(rules.combat.stance.modifier[source:stance()], 'stance')
   -- Add penalty for movement of source
   t:add(rules.combat.movement.modifier[source:movement()],
         'movement', 'Source')
   -- Add penalty for movement of target
   t:add(rules.combat.movement.modifier[target:movement()],
         'movement', 'Target')
   -- Determine range
   local rm = gun:range():determine(range)
   local sz = target:size()

   local rp = rules.combat.range.modifier[rm][sz]
   t:add(rp, 'range', rm .. '/' .. sz)

   t._skill = gun:skill()
   t._source = source
   t._target = target

   return t
end

return task
