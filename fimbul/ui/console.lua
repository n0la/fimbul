---@module fimbul.ui.console

local console = {}

local base = _G

local pretty = require("pl.pretty")

local config = require("fimbul.config")
local command_dispatcher = require("fimbul.ui.command_dispatcher")

local readline = require("readline")

function console:new(r, o)
   local neu = {}

   setmetatable(neu, self)
   self.__index = self

   neu.name = o.name or ""
   neu.dispatcher = command_dispatcher:new(r, o)

   neu.context = nil

   return neu
end

function console:run()
   local name = self.name
   local history

   if self.name ~= "" then
      history = config.path .. "/" .. name .. "_history"
   else
      history = config.path .. "/history"
   end

   readline.set_options{histfile = history}

   while true do
      local ok, line = pcall(readline.readline, "> ")

      if not ok then
         break
      end

      local ok, cmd, args = self.dispatcher:parse(line)

      if not ok then
         self.dispatcher:error(cmd .. "\n")
      elseif ok and cmd then
         local found, ret = self.dispatcher:run(cmd, args)

         if not found then
            self.dispatcher:ferror(
               "Unknown command '%s'. For a list of commands type 'help'.", cmd)
         end
      end
   end

   readline.save_history()
   return 0
end

return console
