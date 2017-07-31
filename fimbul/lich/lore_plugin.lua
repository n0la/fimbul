local plugin = require('lich.plugin')
local lore_plugin = plugin:new()

local campaign = require('fimbul.campaign')
local log = require('lich.log')
local base = _G

function lore_plugin:new(config)
   local neu = plugin:new(config)

   setmetatable(neu, self)
   self.__index = self

   if not config.game or not config.name or not config.path then
      log.error('this plugin requires game, name and path to be set')
   end

   self.config = config or {}

   self.campaign = campaign:new(self.config)
   self.repository = self.campaign.repository

   return neu
end

function lore_plugin:name()
   return 'fimbul.lich.lore_plugin'
end

function lore_plugin:lore(server, user, channel, cmd)
   local c = table.concat(cmd.args, ' ')
   local wt = self.repository:spawn_lore(c)

   if wt then
      msg = wt:name() .. ': ' .. wt:description()
   else
      msg = 'No such place, character or lore item'
   end

   server:send_message(user, channel, msg)
end

function lore_plugin:oncommand(server, user, channel, cmd)
   local commands = {
      { name = "lore", handler = lore_plugin.lore }
   }

   for _, c in base.ipairs(commands) do
      if c.name == cmd.command then
         c.handler(self, server, user, channel, cmd)
      end
   end
end

return lore_plugin
