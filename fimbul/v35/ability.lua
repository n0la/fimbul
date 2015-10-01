---@module fimbul.v35.ability

-- Magic Item Special Ability
--

local base = _G

local ability = {}

local dice_expression = require('fimbul.dice_expression')
local util = require('fimbul.util')

function ability:new()
   local neu = {}

   setmetatable(neu, self)
   self.__index = self

   neu.bonus = 0

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

   if t.material then
      neu.material = util.deepcopy(t.material)
   end

   neu.school = t.school
   neu.grade = t.grade
   neu.cl = t.cl
   neu.has_modifier = t.has_modifier or false

   neu.feats = util.deepcopy(t.feats or {})
   neu.spells = util.deepcopy(t.spells or {})
   neu.alignments = util.deepcopy(t.alignments or {})

   neu._price = t.price or 0
   neu.modifier = t.modifier or 0
   neu.description = t.description

   neu.lua = util.deepcopy(t.lua or {})

   return neu
end

function ability:price()
   if self.lua.price ~= nil then
      ctx = {}
      ctx.ability = self

      value = dice_expression.evaluate(self.lua.price, ctx)
      return value
   end

   return self._price
end

function ability:string()
   local str = self.name

   if self.bonus ~= nil and self.bonus > 0 then
      str = str .. ' +' .. self.bonus
   end

   return str
end

return ability
