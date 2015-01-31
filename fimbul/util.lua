--- @module fimbul.util

local util = {}

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

return util
