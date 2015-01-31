--- @module fimbul.v35.engine

local e = {}

local engine = {}

function e.new()
   local neu = {}

   engine.__index = engine
   setmetatable(neu, engine)

   return neu
end

return e
