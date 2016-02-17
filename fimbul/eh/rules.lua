---@module fimbul.eh.rules

-- Rules for Endless Horizons
--

local rules = {}

local string = require('string')
local util = require('fimbul.util')

local dice = require('fimbul.dice')

rules.task = {}
rules.task.STACKING_RULES = { stack = true }
rules.task.BASE = 5

rules.skill = {}
rules.skill.dice = dice.d10
rules.skill.STACKING_RULES = { stack = true }

rules.character = {}
rules.character.BASE_HP = 25
rules.character.BASE_CARRY_WEIGHT = 10

rules.abilities = {}

rules.abilities.BACKGROUND_FLAT_COST = 5

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

rules.equipment = {}

rules.equipment.MAGAZINE_COST = 0.1

rules.combat = {}
rules.combat.initiative_dice = dice.d10

rules.combat.movement = {}
rules.combat.movement.STILL = 'still'
rules.combat.movement.SUBTLE = 'subtle'
rules.combat.movement.SLOW = 'slow'
rules.combat.movement.FAST = 'fast'

rules.combat.movement.modifier = {
   [rules.combat.movement.STILL]  = -2,
   [rules.combat.movement.SUBTLE] =  0,
   [rules.combat.movement.SLOW]   =  2,
   [rules.combat.movement.FAST]   =  4,
}

rules.combat.stance = {}
rules.combat.stance.STANDING = 'standing'
rules.combat.stance.KNEELING = 'kneeling'
rules.combat.stance.PRONE = 'prone'

-- Bonuses for firing in those stances.
rules.combat.stance.modifier = {
   [rules.combat.stance.STANDING] = -1,
   [rules.combat.stance.KNEELING] = -2,
   [rules.combat.stance.PRONE]    = -3
}

rules.combat.size = {}
rules.combat.size.TINY = 'tiny'
rules.combat.size.SMALL = 'small'
rules.combat.size.MEDIUM = 'medium'
rules.combat.size.LARGE = 'large'
rules.combat.size.HUGE = 'huge'

rules.combat.size_by_stance = {
   [rules.combat.stance.STANDING] = rules.combat.size.MEDIUM,
   [rules.combat.stance.KNEELING] = rules.combat.size.SMALL,
   [rules.combat.stance.PRONE] = rules.combat.size.TINY,
}

rules.combat.range = {}
rules.combat.range.OUTOF = 'outof'
rules.combat.range.MAXIMUM = 'maximum'
rules.combat.range.FAR = 'far'
rules.combat.range.MEDIUM = 'medium'
rules.combat.range.CLOSE = 'close'

rules.combat.range.bounds = {
   [rules.combat.range.MAXIMUM] = 0.5,
   [rules.combat.range.FAR] = 0.25,
   [rules.combat.range.MEDIUM] = 0.15,
   [rules.combat.range.CLOSE] = 0.0
}

-- Penalties table for ranged combat
--
rules.combat.range.modifier = {
   [rules.combat.range.OUTOF] = {
      [rules.combat.size.TINY] = 18,
      [rules.combat.size.SMALL] = 12,
      [rules.combat.size.MEDIUM] = 6,
      [rules.combat.size.LARGE] = -2,
      [rules.combat.size.HUGE] = -3,
   },
   [rules.combat.range.MAXIMUM] = {
      [rules.combat.size.TINY] = 18,
      [rules.combat.size.SMALL] = 12,
      [rules.combat.size.MEDIUM] = 6,
      [rules.combat.size.LARGE] = -2,
      [rules.combat.size.HUGE] = -3,
   },
   [rules.combat.range.FAR] = {
      [rules.combat.size.TINY] = 12,
      [rules.combat.size.SMALL] = 8,
      [rules.combat.size.MEDIUM] = 4,
      [rules.combat.size.LARGE] = -4,
      [rules.combat.size.HUGE] = -6,
   },
   [rules.combat.range.MEDIUM] = {
      [rules.combat.size.TINY] = 6,
      [rules.combat.size.SMALL] = 4,
      [rules.combat.size.MEDIUM] = 2,
      [rules.combat.size.LARGE] = -8,
      [rules.combat.size.HUGE] = -12,
   },
   [rules.combat.range.CLOSE] = {
      [rules.combat.size.TINY] = 3,
      [rules.combat.size.SMALL] = 2,
      [rules.combat.size.MEDIUM] = 1,
      [rules.combat.size.LARGE] = -12,
      [rules.combat.size.HUGE] = -18,
   },
}

-- TODO: We need 'race'
rules.combat.zone = {}
-- 2d6
rules.combat.zone.dice = dice:new({sides = 6, amount = 2})
-- All zones
rules.combat.zone.VITAL = 'vital'
rules.combat.zone.LEGS = 'legs'
rules.combat.zone.ARMS = 'arms'
rules.combat.zone.HEAD = 'head'
rules.combat.zone.TORSO = 'torso'
-- Default zone
rules.combat.zone.default = rules.combat.zone.TORSO

rules.combat.zones = {
   nil,
   rules.combat.zone.VITAL,
   rules.combat.zone.LEGS,
   rules.combat.zone.LEGS,
   rules.combat.zone.TORSO,
   rules.combat.zone.TORSO,
   rules.combat.zone.TORSO,
   rules.combat.zone.ARMS,
   rules.combat.zone.ARMS,
   rules.combat.zone.HEAD,
   rules.combat.zone.HEAD,
   rules.combat.zone.VITAL,
}

function rules.valid_ability(name)
   local n = string.lower(name)
   n = util.capitalise(name)

   return util.contains(rules.abilities.names, n)
end

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
