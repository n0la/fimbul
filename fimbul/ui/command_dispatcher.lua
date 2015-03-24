---@module fimbuil.ui.command_dispatcher

local command_dispatcher = {}

local base = _G
local io = require("io")
local table = require("table")

local util = require("fimbul.util")
local common_context = require("fimbul.ui.common_context")

-- Common methods for manipulating lists in contexts
local list = require("fimbul.ui.list")

function command_dispatcher:add(context)
   assert(context, "Cannot add nil context.")
   assert(context.name, "Given context has no name.")
   self.contexts[context.name] = context
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
   self:say(line)
end

function command_dispatcher:error(str)
   self.stderr:write("Error: " .. str .. "\n")
end

function command_dispatcher:ferror(fmt, ...)
   local line = string.format(fmt, ...)
   self:error(line)
end

function command_dispatcher:modules()
   if self.current then
      return {self.common, self.current}
   else
      return {self.common}
   end
end

function command_dispatcher:has_function(c, n)
   return c[n] ~= nil and type(c[n]) == "function"
end

function command_dispatcher:run(c, a)
   local args = a or {}
   local ret
   local found = false
   local cur = self.current or {}

   assert(c, "Command must not be nil.")

   for _, i in base.pairs(self:modules()) do
      local funcname = "on_" .. c
      if self:has_function(i, funcname) then
         found = true

         local ok, ret = pcall(i[funcname], i, self, a)

         if not ok then
            self:ferror("Error in command '%s': %s", c, ret)
         end

         break
      end

   end

   return found, ret
end

function command_dispatcher:switch_context(c, arg)
   local context
   local ret

   if c == nil then
      return self.current
   end

   context = self.contexts[c]
   assert(context, "Invalid context to switch to '" .. c .. "'")

   -- Notify context that it has been activated
   if self:has_function(context, "on_switch") then
      ret = context:on_switch(self, arg)
   end

   if ret then
      local old = self.current
      self.current = context
      self:fsay("Switched to context '%s'.", c)
   end

   return old
end

function command_dispatcher:new(r, o)
   local neu = {}

   setmetatable(neu, self)
   self.__index = self

   -- Stuff goes to stdout by default
   if o then
      neu.stdout = o.stdout or io.stdout
      neu.stderr = o.stderr or io.stderr
   else
      neu.stdout = io.stdout
      neu.stderr = io.stderr
   end

   neu.contexts = {}
   -- Register common commands
   neu.common = common_context:new(r)
   neu.current = nil

   neu.list = list:new(neu)

   return neu
end

return command_dispatcher
