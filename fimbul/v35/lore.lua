local lore = {}

function lore:new(y)
   local neu = y or {}

   setmetatable(neu, self)
   self.__index = self

   return neu
end

function lore:spawn(r, t)
   local neu = self:new()

   assert(t, 'No template to spawn from')

   neu.template = t

   neu._name = t.name or ''
   neu._description = t.description or ''
   neu._aliases = t.aliases or {}

   return neu
end

function lore:description()
   return self._description or ''
end

function lore:name()
   return self._name or ''
end

function lore:aliases()
   return self._aliases or {}
end

return lore
