---@module fimbul.ui.readline

local readline = {}

local os = require("os")
local io = require("io")
local ok, rl = pcall(require, 'readline')

if not ok then
   rl = nil
end

function readline.set_options(args)
   if rl ~= nil then
      return rl.set_options(args)
   end
end

function readline.save_history()
   if rl ~= nil then
      return rl.save_history()
   end
end

function readline.readline(prompt)
   if rl ~= nil then
      return rl.readline(prompt)
   else
      io.write(prompt)
      local line = io.read()
      return line
   end
end

return readline
