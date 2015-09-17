local base = _G

local yaml = require("yaml")
local lfs = require("lfs")

local os = require('os')

local config = require("fimbul.config")
local util = require("fimbul.util")

local sources = {}

function sources:update(s)
   if s == nil then
      error('No source specified.')
   end

   local url = s.url

   if not util.isdir(s.path) then
      assert(lfs.mkdir(path),
             "Could not create for source " .. name)
      cmd = 'cd "' .. s.path .. '" && git clone "' .. url .. '" .'
   else
      cmd = 'cd "' .. s.path .. '" && git pull origin master:master'
   end

   os.execute(cmd)
end

function sources:load()
   local data = {}

   -- Load all yaml files
   --
   for iter, dir in lfs.dir(self.path) do
      if iter ~= '.' and iter ~= '..' then

         local full = util.realpath(self.path .. "/" .. iter)
         if util.isfile(full) then
            yaml = util.yaml_loadfile(full)
            local name = util.getname(yaml)
            yaml.path = self.path .. "/" .. name .. ".d"
            data[name] = yaml
         end
      end
   end

   self.data = data
end

function sources:new()
   local neu = {}

   setmetatable(neu, self)
   self.__index = self

   neu.path = config.sources
   neu:load()

   return neu
end

return sources
