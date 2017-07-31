local base = _G

local repository = require('fimbul.repository')
local util = require('fimbul.util')

local campaign = {}

function campaign:new(config)
   local neu = {}

   assert(config.name, "campaign needs a name")
   assert(config.game, "campaign needs a game")
   assert(config.path, "campaign needs a path")

   setmetatable(neu, self)
   self.__index = self

   self.name = config.name
   self.game = config.game
   self.path = config.path

   self.repository = repository:new()
   self.repository:add_data_directory(neu.name, neu.path)
   self.repository:open(neu.game)

   return neu
end

return campaign
