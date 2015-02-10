--- @module fimbul.v35.player_character

local creature = require("fimbul.v35.creature")

local player_character = creature:new()

function player_character:new(p)
   local neu = creature:new()

   neu.player = p

   return neu
end

return player_character
