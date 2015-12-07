---@module fimbul.eh.rules

-- Rules for Endless Horizons
--

local rules = {}

local string = require('string')

rules.abilities = {}

rules.abilities.LOWEST_RANK = 0
rules.abilities.HIGHEST_RANK = 10
rules.abilities.AVERAGE = 5
rules.abilities.names = {'Strength', 'Constitution', 'Dexterity',
                         'Perception', 'Intelligence', 'Charisma'}

rules.skills = {}

rules.skills.LOWEST_RANK = 0
rules.skills.HIGHEST_RANK = 10

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
