---@module fimbul.eh.character

local character = {}

local base = _G

local ability = require('fimbul.eh.ability')
local rules = require('fimbul.eh.rules')
local skill_check = require('fimbul.eh.skill_check')

local util = require('fimbul.util')

function character:new(y)
   local neu = y or {}

   setmetatable(neu, self)
   self.__index = self

   -- Initialise abilities
   neu.abilities = {}
   for _, a in base.pairs(rules.abilities.names) do
      local lower = string.lower(a)
      neu[lower] = ability:new(a)
      table.insert(neu.abilities, neu[lower])
   end

   neu.skills = {}
   neu._equipment = {}
   neu._credits = 0
   neu._weight = 0
   neu._hp = 0
   neu._stance = rules.combat.stance.STANDING
   neu._movement = rules.combat.movement.SUBTLE
   neu.name = ''

   return neu
end

function character:spawn(r, t)
   local neu = self:new()

   if not t.name then
      error('Character must have a name!')
   end

   neu.name = t.name
   neu.template = t

   -- Load race.
   if t.race == nil then
      error('Character does not have a race.')
   end

   local race = r:find_spawn_first(r.eh.races, t.race)
   if race == nil then
      error('No such race: ' .. t.race)
   end

   neu._race = race

   neu._weight = t.weight or 0
   neu._height = t.height or 0
   neu._credits = t.credits or 0

   for _, a in base.pairs(rules.abilities.names) do
      local at
      local name = string.lower(a)
      local ans = rules.short_ability_name(a)

      -- TODO: Perfect candidate for a function in util
      if t[a] then
         -- Normal name?
         at = t[a]
      elseif t[name] then
         -- Lower case name?
         at = t[name]
      elseif t[ans] then
         -- Short ability name?
         at = t[ans]
      elseif t[string.lower(ans)] then
         -- Lowercase short ability name?
         at = t[string.lower(ans)]
      end

      if at then
         neu[name] = ability:new(name, at)
      end
   end

   if t.skills then
      for skill, rank in base.pairs(t.skills) do
         local s = r:find(r.eh.skills, skill)
         if #s == 0 then
            error('No such skill: ' .. skill)
         end

         local sk = r:spawn(s[1])
         sk:rank(rank)
         -- Insert skill to list
         table.insert(neu.skills, sk)
      end
   end

   if t.equipment then
      for _, item in base.pairs(t.equipment) do
         local it = r:parse_item(item)

         if it == nil then
            error('No such item: ' .. item)
         end

         table.insert(neu._equipment, it)
      end
   end

   neu._hp = neu:max_hp()

   return neu
end

function character:weight()
   return self._weight
end

function character:height()
   return self._height
end

function character:race()
   return self._race
end

function character:max_hp()
   return rules.character.BASE_HP
      + self.strength:rank()
      + self.constitution:rank()
end

function character:damage(dmg, source)
   local d
   local z = self:race():hitzone():roll_zone()

   -- TODO: Armor

   z:modify_damage(dmg)

   d = dmg:value()
   self._hp = self._hp - d

   -- TODO: Roll wounds

   return dmg, z
end

function character:perform(r, t)
   local s = t:skill()
   local skill = r:find_spawn_first(r.eh.skills, s)
   local sk = util.find_name(self.skills, s)
   local mod = skill_check:new()

   -- Handle ability modifiers
   --
   for _, a in base.pairs(skill:uses()) do
      local m = self:ability(a):modifier()
      if (m < 0 and sk == nil) or
         (m >= 0 and sk ~= nil) then
         mod:add(m, a)
      end
   end

   -- Do we have a skill modifier?
   --
   if sk ~= nil then
      local rk = sk:rank()
      mod:add(rk, sk:name())
   end

   -- Roll
   mod:roll()

   if mod:value() >= t:value() then
      return true, mod
   end

   return false, mod
end

function character:ability(a)
   local n = string.lower(a)
   return self[n]
end

function character:hp()
   return self._hp
end

function character:is_dead()
   return self:hp() <= 0
end

function character:equipment()
   return self._equipment
end

function character:max_carry_weight()
   return rules.character.BASE_CARRY_WEIGHT
      + self.constitution:rank()
      + self.constitution:rank()
end

function character:equipment_weight()
   local w = 0

   for _, i in base.pairs(self._equipment) do
      w = w + i:weight()
   end

   return w
end

function character:equipment_cost()
   local c = 0

   for _, i in base.pairs(self._equipment) do
      c = c + i:cost()
   end

   return c
end

function character:total_weight()
   return self:weight() + self:equipment_weight()
end

function character:cost()
   local c = 0

   -- TODO: Performance
   for _, a in base.pairs(self.abilities) do
      c = c + a:cost()
   end

   for _, s in base.pairs(self.skills) do
      c =  c + s:cost()
   end

   return c
end

function character:stance(v)
   if v == nil then
      return self._stance
   else
      if not util.contains(rules.combat.stance, v) then
         error('Invalid stance.')
      end
      self._stance = v
   end
end

function character:movement(v)
   if v == nil then
      return self._movement
   else
      if not util.contains(rules.combat.movement, v) then
         error('Invalid stance.')
      end
      self._movement = v
   end
end

function character:roll_initiative()
   return rules.combat.initiative_dice:roll()
      + self.dexterity:modifier()
end

function character:size()
   return rules.combat.size_by_stance[self:stance()]
end

return character
