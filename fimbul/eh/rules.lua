---@module fimbul.eh.rules

-- Rules for Endless Horizons
--

local rules = {}

local string = require('string')

rules.ability = {}
rules.ability.AVERAGE = 5

rules.ability.names = {'Strength', 'Constitution', 'Dexterity',
                       'Perception', 'Intelligence', 'Charisma'}

rules.skills = {}

rules.skills.SPECIAL_ACTIVATION_COST = 10
rules.skills.ACTIVATION_COST = 1

function rules.short_ability_name(name)
   return string.upper(name:sub(0, 3))
end

function rules.calculate_rank_cost(from, to)
   local cost = 0

   for i = from+1, to do
      cost = cost + i
   end

   return cost
end

return rules
