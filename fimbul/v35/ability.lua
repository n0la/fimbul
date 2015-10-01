---@module fimbul.v35.ability

-- Magic Item Special Ability
--

local base = _G

local ability = {}

local dice_expression = require('fimbul.dice_expression')
local util = require('fimbul.util')
local rules = require('fimbul.v35.rules')

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
   neu.bonus = util.deepcopy(t.bonus or {})

   neu.feats = util.deepcopy(t.feats or {})
   neu.spells = util.deepcopy(t.spells or {})
   neu.alignments = util.deepcopy(t.alignments or {})

   neu._price = t.price or 0
   neu.modifier = t.modifier or 0
   neu.description = t.description

   neu.lua = util.deepcopy(t.lua or {})

   return neu
end

function ability:parse(tbl)
   if self.bonus.required then
      if #tbl == 0 then
         error('No bonus specified, but a bonus is required.')
      end

      mod = util.parse_modifier(tbl[1])
      if self.bonus.maximum ~= nil and mod > self.bonus.maximum then
         error('No bonus can exceed the maximum allowed modifier: '
                  .. self.bonus.maximum)
      end
      if self.bonus.minimum ~= nil and mod < self.bonus.minimum then
         error('No bonus can be lower than the minimum: ' .. self.bonus.minimum)
      end

      self.bonus = mod

      -- We consumed one.
      return true, 1
   end

   return false, 0
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
