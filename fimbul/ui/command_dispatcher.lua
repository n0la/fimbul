---@module fimbuil.ui.command_dispatcher

local command_dispatcher = {}

local base = _G
local io = require("io")
local table = require("table")

local util = require("fimbul.util")
local common_commands = require("fimbul.ui.common_commands")

function command_dispatcher:register(f, a, n, h)
   local cmd

   if type(f) == "function" then
      cmd = {name = n, func = f, arg = a, help = (h or "")}
   elseif type(f) == "table" then
      cmd = f
   end

   table.insert(self.commands, cmd)
end

function command_dispatcher:help(dispatcher, arg)
   for _, cmd in base.pairs(self.commands) do
      local line = ""

      if type(cmd.name) == "string" then
         line = string.format("%s\t%s", cmd.name, cmd.help)
      elseif type(cmd) == "table" then
         line = string.format("%s\t%s", cmd.name[1], cmd.help)

         if #cmd.name > 1 then
            line = line .. " Available aliases: "

            for i = 2, #cmd.name do
               line = line .. '"' .. cmd.name[i] .. '" '
            end
         end
      end

      self:say(line)
   end
end

function command_dispatcher:parse(str)
   local cmd
   local args = {}

   local doublequote = false
   local cur = ""

   -- Comments are ignored
   if str:sub(1, 1) == '#' or
      str:sub(1, 2) == "//" or
      str:sub(1, 2) == "--" then
      return true, "", {}
   end

   for i = 1, #str do
      local c = str:sub(i, i)

      if (c == ' ' or c == '\t') and not doublequote then
         if not cmd then
            cmd = cur
            cur = ""
         else
            table.insert(args, cur)
            cur = ""
         end
      elseif c == '"' then
         if not cmd then
            return false, "Don't put the command under quotes.", {}
         else
            doublequote = not doublequote
         end
      else
         cur = cur .. c
      end
   end

   if doublequote then
      return false, "Unclosed double quotes.", {}
   end

   if cur then
      if not cmd then
         cmd = cur
      else
         table.insert(args, cur)
      end
   end

   return true, cmd, args
end

function command_dispatcher:say(str)
   self.stdout:write(str .. "\n")
end

function command_dispatcher:fsay(fmt, ...)
   local line = string.format(fmt, ...)
   self.stdout:write(line .. "\n")
end

function command_dispatcher:error(str)
   self.stderr:write(str .. "\n")
end

function command_dispatcher:ferror(fmt, ...)
   local line = string.format(fmt, ...)
   self.stderr:write(line .. "\n")
end

function command_dispatcher:run(c, a)
   local args = a or {}
   local ret
   local found = false

   for _, i in base.pairs(self.commands) do
      if (type(i.name) == "table" and util.contains(i.name, c)) or
         (type(i.name) == "string" and i.name == c) then
         found = true

         -- This allows methods of objects to be used as commands
         -- Or it can be used if you need pass some parameter first
         ret = i.func(i.arg, self, a)

         break
      end
   end

   return found, ret
end

function command_dispatcher:new(o)
   local neu = {}

   setmetatable(neu, self)
   self.__index = self

   -- Stuff goes to stdout by default
   neu.stdout = o.stdout or io.stdout
   neu.stderr = o.stderr or io.stderr

   neu.commands = {}
   -- Register common commands
   common_commands:register(neu)
   -- Register help command
   neu:register(command_dispatcher.help, neu, "help", "This bogus.")

   return neu
end

return command_dispatcher
