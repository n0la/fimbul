---@module fimbul.eh.magazine

local item = require('fimbul.eh.item')

local magazine = item:new()

function magazine:new(y)
   local neu = item:new(y)

   setmetatable(neu, self)
   self.__index = self

   neu._capacity = 0
   neu._loaded = 0
   neu._internal = false
   neu._weapon = nil

   return neu
end

function magazine:spawn(r, t)
   local neu = self:new()

   if not t.name then
      error('Even a magazine needs a name')
   end

   neu._name = t.name
   neu.template = t
   item.set_attributes(neu, t)

   neu._capacity = t.capacity
   neu._internal = t.internal
   neu._weapon = t.weapon
   neu._loaded = 0

   return neu
end

function magazine:_parse_attributes(r, t)
   item._parse_attributes(self, r, t)

   for i = 1, #t do
      local s = string.lower(t[i])

      -- Parse loaded as {amount}
      cap = string.match(s, '^%{([%d]+)%}$')
      if cap ~= nil then
         cap = tonumber(cap)
         self:loaded(cap)
      end
   end
end

function magazine:capacity()
   return self._capacity
end

function magazine:loaded(n)
   if n == nil then
      return self._loaded
   else
      num = tonumber(n)
      if num > self:capacity() then
         error('Too many bullets loaded')
      end
      self._loaded = num
   end
end

function magazine:internal()
   return self._internal
end

function magazine:weapon()
   return self._weapon
end

function magazine:string(extended)
   local s

   s = self:name() .. ' {' .. self:loaded() .. '}'

   if self:amount() > 1 then
      s = s .. ' (' .. self:amount() .. ')'
   end

   return s
end

return magazine
