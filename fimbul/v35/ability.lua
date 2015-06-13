---@module fimbul.v35.ability

-- Magic Item Special Ability
--

local base = _G

local ability = {}

local util = require('fimbul.util')

function ability:new()
   local neu = {}

   setmetatable(neu, self)
   self.__index = self

   return neu
end

function ability:spawn(r, t)
   local neu = ability:new()

   if t == nil then
      error('No template specified')
   end

   neu.name = t.name
   neu.slots = util.deepcopy(t.slots or {})
   if t.requires then
      neu.requires = util.deepcopy(t.requires)
   end

   if t.weapon then
      neu.weapon = util.deepcopy(t.weapon)
   end

   if t.armor then
      neu.armor = util.deepcopy(t.armor)
   end

   if t.shield then
      neu.shield = util.deepcopy(t.shield)
   end

   neu.school = t.school
   neu.grade = t.grade
   neu.cl = t.cl

   neu.feats = util.deepcopy(t.feats or {})
   neu.spells = util.deepcopy(t.spells or {})
   neu.alignments = util.deepcopy(t.alignments or {})

   neu.price = t.price or 0
   neu.modifier = t.modifier or 0
   neu.description = t.description

   return neu
end

return ability
