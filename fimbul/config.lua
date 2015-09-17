---@module fimbul.config

local config = {}

local lfs = require("lfs")
local os = require("os")
local util = require("fimbul.util")

function config.init()
   if not config.path then
      local home = os.getenv("HOME")
      config.path = home .. "/.fimbul"
      if not util.isdir(config.path) then
         assert(lfs.mkdir(config.path),
                "Could not create save directory in " .. config.path)
      end

      config.sources = config.path .. "/sources"
      if not util.isdir(config.sources) then
         assert(lfs.mkdir(config.sources),
                "Could not create sources directory in " .. config.path)
      end
   end
end

config.init()

return config
