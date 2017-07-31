-- LICH plugin for fimbul
--

local plugin = require('lich.plugin')
local item_plugin = plugin:new()

local repository = require('fimbul.repository')
local log = require('lich.log')
local base = _G

function item_plugin:new(config)
   local neu = plugin:new(config)

   setmetatable(neu, self)
   self.__index = self

   self.config = config or {}

   assert(self.config.game, 'item_plugin: no game specified')

   return neu
end

function item_plugin:name()
   return 'fimbul.lich.item_plugin'
end

function item_plugin:onconnect(server)
   if not self.repository then
      ok, r = pcall(repository.new, repository, self.config.game)
      if not ok then
         log.error('item_plugin: error loading repo: ' .. self.repository)
      else
         self.repository = r
      end
   end
end

function item_plugin:on_item(server, user, channel, cmd)
   local i = table.concat(cmd.args, ' ')
   local msg

   -- Try to parse each item
   ok, item = pcall(self.repository.parse_item, self.repository, i)
   if not ok or item == nil then
      msg = 'Not a valid item: ' .. i
      log.error('item_plugin: not a valid item: ' .. i)
   else
      msg = item:string(true)
      log.info('item_plugin: item: ' .. item:string(true))
   end

   server:send_message(user, channel, msg)
end

function item_plugin:oncommand(server, user, channel, cmd)
   -- see what sort of command it was
   if cmd.command == 'item' then
      self:on_item(server, user, channel, cmd)
   end
end

return item_plugin
