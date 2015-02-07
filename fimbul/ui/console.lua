---@module fimbul.ui.console

local console = {}

local base = _G

local pretty = require("pl.pretty")

local config = require("fimbul.config")
local command_dispatcher = require("fimbul.ui.command_dispatcher")

local readline = require("readline")

function console:new(o)
   local neu = {}

   setmetatable(neu, self)
   self.__index = self

   neu.name = o.name or ""
   neu.cmd = command_dispatcher:new(o)

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

      local ok, cmd, args = self.cmd:parse(line)

      if not ok then
         self.cmd:error(cmd .. "\n")
      elseif ok and cmd then
         local found, ret = self.cmd:run(cmd, args)

         if not found then
            self.cmd:ferror(
               "Unknown command '%s'. For a list of commands type 'help'.", cmd)
         end
      end
   end

   readline.save_history()
   return 0
end

return console
