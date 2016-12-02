--- @module fimbul.util

local util = {}

local base = _G

local lyaml = require("lyaml")

local table = require("table")
local string = require("string")
local io = require("io")
local std = require("std")

local lfs = require("lfs")
local pretty = require("pl.pretty")

function util.dump(o)
   pretty.dump(o)
end

function util.lookahead(t, pos, f)

   i = #t
   while i >= pos do
      str = table.concat(t, " ", pos, i)

      ok, extra = f(str, t, pos, i)
      if ok then
         if extra == nil then
            extra = 0
         end
         return true, ((i - pos) + extra + 1)
      end

      i = i - 1
   end

   return false, 0
end

function util.shift(t)
   if #t == 0 then
      return nil
   end

   r = t[1]
   table.remove(t, 1)

   return r
end

function util.remove(t, i, n)
   local c = 0

   while c < n and i <= #t do
      table.remove(t, i)
      c = c + 1
   end

   return t
end

function util.splice(t, i, j)
   local st = i or 1
   local en = j or #t

   return { table.unpack(t, st, en) }
end

function util.removeif_copy(t, F)
   local n = table.getn(t)

   if n == 0 then
      return n
   end

   local copy = t

   for i = 1,n do
      if not F(t[i]) then
         table.insert(copy, t[i])
      end
   end

   return copy
end

function util.removeif(t, F)
   local i = #t
   local c = 0

   for i = 1, #t do
      if F(t[i]) then
         table.remove(t, i)
         c = c + 1
      else
         i = i + 1
      end
   end

   return c
end

function util.max(t, fn)
    if #t == 0 then return nil, nil end
    local key, value = 1, t[1]
    for i = 2, #t do
        if fn(value, t[i]) then
            key, value = i, t[i]
        end
    end
    return key, value
end

function util.min(t, fn)
    if #t == 0 then return nil, nil end
    local key, value = 1, t[1]
    for i = 2, #t do
        if fn(value, t[i]) then
            key, value = i, t[i]
        end
    end
    return key, value
end

function util.yaml_dumpfile(f, o)
   local file = io.open(f, "w")
   local str = lyaml.dump({o})

   file:write(str)
   file:close()
end

function util.yaml_loadfile(str)
   local file = io.open(str, "r")
   if not file then
      error('Could not load file: ' .. str)
   end

   local content = file:read("*all")
   file:close()

   return lyaml.load(content)
end

function util.getname(t)
   if t == nil then
      return nil
   end

   if type(t) == "string" then
      return t
   elseif type(t) ~= "table" then
      return nil
   end

   if type(t.name) == 'string' then
      return t.name
   elseif type(t._name) == 'string' then
      return t._name
   end

   for _, c in base.pairs(t) do
      if type(c) == "table" and c.name ~= nil then
         return c.name
      end
   end

   return nil
end

function util.deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[util.deepcopy(orig_key)] = util.deepcopy(orig_value)
        end
        setmetatable(copy, util.deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function util.deepclone(orig)
   local copy = util.deepcopy(orig)
   setmetatable(copy, getmetatable(orig))
   return clone
end

function util.shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in base.pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function util.shallowclone(orig)
   local clone = util.shallowcopy(orig)
   setmetatable(clone, getmetatable(orig))
   return clone
end

function util.name_matches(t1, t2)
   local n1 = util.getname(t1)
   local n2 = util.getname(t2)

   if n1 == nil or n2 == nil then
      return false
   end

   n1 = string.lower(n1)
   n2 = string.lower(n2)

   return (n1 == n2)
end

function util.concat_table(t1, t2)
   local t3 = t1

   for i=1,#t2 do
      table.insert(t3, t2[i])
   end

   return t3
end

function util.is_relative(path)
   if path == "" then
      return false
   end

   if path:sub(1, 1) ~= "/" or path:sub(1, 1) == "." then
      return true
   else
      return false
   end
end

function util.containsvalue(t, v)
   for _, value in base.pairs(t) do
      if value == v then
         return true
      end
   end

   return false
end

function util.containskey(t, k)
   for key, _ in base.pairs(t) do
      if key == k then
         return true
      end
   end

   return false
end

util.contains = util.containsvalue

function util.containsbyname(t, v)
   local n1 = string.lower(util.getname(v))

   for _, value in base.pairs(t) do
      local n2 = util.getname(value)
      if n1 == string.lower(n2) then
         return true
      end
   end

   return false
end

function util.containsif(t, v, C)
   for _, value in base.pairs(t) do
      if C(value, v) then
         return true
      end
   end

   return false
end

function util.find_name(t, v)
   local l = string.lower(v)

   for _, i in base.pairs(t) do
      if type(i) == 'table' then
         local n = util.getname(i)
         for _, name in base.pairs({n, table.unpack(i.aliases or {})}) do
            if string.lower(name) == l then
               return i
            end
         end
      end
   end

   return nil
end

function util.foreach(t, f, m)
   for _, value in base.pairs(t) do
      if m ~= nil then
         if m(value) then
            f(value)
         end
      else
         f(value)
      end
   end
end

function util.realpath(p)
   local c
   local t = {}

   if #p == 0 then
      return p
   end

   if util.is_relative(p) then
      c = lfs.currentdir() .. "/" .. p
   else
      c = p
   end

   for str in string.gmatch(c, "([^/]+)") do
      if str ~= "." and str ~= "" then
         table.insert(t, str)
      end
   end

   local i = 1
   while i <= #t do
      if t[i] == ".." then
         table.remove(t, i)
         if i > 1 then
            table.remove(t, i-1)
            i = i - 1
         end
      else
         i = i + 1
      end
   end

   c = "/" .. table.concat(t, "/")
   return c
end

function util.isdir(p)
   local s = lfs.attributes(p)
   if s then
      return s.mode == "directory"
   else
      return false
   end
end

function util.isfile(p)
   local s = lfs.attributes(p)
   if s then
      return s.mode == "file"
   else
      return false
   end
end

function util.comparestr(a, b)
   if a == nil or b == nil then
      return false
   end
   if string.len(a) ~= string.len(b) then
      return false
   end

   return string.lower(a) == string.lower(b)
end

function util.default(a, v)
   if a ~= nil then
      return a
   else
      return v
   end
end

function util.split(str, glob)
   local g = glob or '%g+'
   local t = {}

   for w in string.gmatch(str, g) do
      table.insert(t, w)
   end

   return t
end

function util.capitalise(str)
   return string.upper(str:sub(0, 1)) .. str:sub(2)
end

function util.prettify(err)
   local s, e = string.find(err, ':%d+:')

   if e ~= nil then
      return string.sub(err, e+2)
   end

   return err
end

function util.parse_modifier(modstr)
   local mod = 0

   if modstr == nil then
      error('No modifier string present.')
   end

   mod = string.match(modstr, "[+]?(%d+)")
   if mod ~= nil then
      return tonumber(mod)
   end

   mod = string.match(modstr, "%([+]?(%d+)%)")
   if mod ~= nil then
      return tonumber(mod)
   end

   error('Invalid mod specifier: ' .. modstr)
end

function util.findfirst(t, ...)
   for _, i in base.pairs({...}) do
      if t[i] ~= nil then
         return t[i]
      end
   end
end

return util
