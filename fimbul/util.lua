--- @module fimbul.util

local util = {}

local yaml = require("yaml")
local table = require("table")

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
   if yaml.loadfile then
      -- high five for modernized lua yaml ;-)
      return yaml.loadfile(str)
   else
      local file = io.open(str, "r")
      local content = file:read("*all")
      file:close()

      return yaml.load(content)
   end
end

function util.concat_table(t1, t2)
   local t3 = t1

   for i=1,#t2 do
      table.insert(t3, t2[i])
   end

   return t3
end

return util
