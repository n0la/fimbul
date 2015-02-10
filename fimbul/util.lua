--- @module fimbul.util

local util = {}

local base = _G

local yamlok, yaml = pcall(require, "yaml")
local lyamlok, lyaml = pcall(require, "lyaml")

local table = require("table")
local lfs = require("lfs")

function util.removeif(t, F)
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

function util.yaml_loadfile(str)
   -- There are two lua-yaml libraries out there.
   --   lyaml: https://github.com/gvvaughan/lyaml
   --   lua-yaml: http://yaml.luaforge.net
   -- This function tries to work with either installed.
   if yamlok and yaml.loadfile then
      -- And there is my fork of lua-yaml with a loadfile()
      -- function built in.
      return yaml.loadfile(str)
   else
      local file = io.open(str, "r")
      local content = file:read("*all")
      file:close()

      if yamlok and yaml.load then
         return yaml.load(content)
      elseif lyamlok and lyaml.load then
         return lyaml.load(content)
      else
         error("No suitable YAML loading mechanism found.")
         return nil
      end
   end
end

function util.getname(t)
   if not t then
      return nil
   end

   if type(t) ~= "table" then
      return nil
   end

   if t.name then
      return t.name
   end

   for _, c in base.pairs(t) do
      if c.name then
         return c.name
      end
   end

   return nil
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

function util.contains(t, v)
   for _, value in base.pairs(t) do
      if value == v then
         return true
      end
   end

   return false
end

function util.foreach(t, f)
   for _, value in base.pairs(t) do
      f(value)
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
   while i < #t do
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

return util
