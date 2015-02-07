---@module fimbul.config

local config = {}

local lfs = require("lfs")
local os = require("os")
local posix = require("posix")
local util = require("fimbul.util")

function config.init()
   if not config.path then
      local home = os.getenv("HOME")
      config.path = home .. "/.fimbul"
      if not util.isdir(config.path) then
         assert(posix.mkdir(config.path),
                "Could not create save directory in " .. config.path)
      end
   end
end

config.init()

return config
