---@module fimbul.eh.skill_check

local skill_check = {}

local stacked_value = require('fimbul.stacked_value')
local rules = require('fimbul.eh.rules')

skill_check = stacked_value:new(rules.skill.STACKING_RULES)

function skill_check:new()
   local neu = stacked_value:new(rules.skill.STACKING_RULES)

   setmetatable(neu, self)
   self.__index = self

   return neu
end

function skill_check:roll()
   self:remove_all_type('dice')
   local r = rules.skill.dice:roll()
   self:add(r, 'dice')
end

return skill_check
