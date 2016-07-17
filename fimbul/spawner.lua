---@module fimbul.spawner

local spawner = {}

local base = _G

function spawner:full_path(c)
   return self:namespace() .. '.' .. c
end

function spawner:spawn(r, t)
   local nm

   if t == nil then
      error('spawner: no template given')
   end

   if type(t) == 'table' then
      nm = t.templatetype
   elseif type(t) == 'string' then
      nm = t
   end

   local c = self._classes[self:full_path(nm)]

   if not c then
      error('spawner: unsupported class: ' .. nm)
   end

   return c:spawn(r, t)
end

function spawner:create_template(what, ...)
   local t = self._templates[self:full_path(what)]

   if not t then
      error('spawner: unsupported template: ' .. what)
   end

   return t:new(...)
end

function spawner:add(...)
   for _, i in base.ipairs({...}) do
      local cls = self._namespace .. '.' .. i
      local nw = require(cls)
      if not nw then
         error('spawner: no such class: ' .. cls)
      end

      local tmpl = self._namespace .. '.' .. i .. '_template'
      local tm = require(tmpl)
      if not tm then
         error('spawner: no such class: ' .. tmpl)
      end

      self._templates[tmpl] = tm
      self._classes[cls] = nw
   end
end

function spawner:namespace()
   return self._namespace
end

function spawner:new(namespace)
   local neu = {}

   if namespace == nil then
      error('No namespace given for spawner')
   end

   setmetatable(neu, self)
   self.__index = self

   neu._namespace = namespace
   neu._templates = {}
   neu._classes = {}

   return neu
end

return spawner
