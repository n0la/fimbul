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

   assert(os.execute(cmd), 'Failed to update repository.')
end

function sources:import(url)
   if url == nil then
      error('No URL specified')
   end

   tmp = util.tempdir("fimbul")

   cleanup = function()
      os.execute('rm -rf "' .. tmp .. '"')
   end

   -- Clone repository first, then read configuration
   -- and if it fits then take it and move it somewhere.
   assert(os.execute('git clone "' .. url .. '" "' .. tmp .. '"'),
          'Failed to clone the repository.')

   info = tmp .. "/info.yml"

   ok, yaml = pcall(util.yaml_loadfile, info)

   if not ok then
      cleanup()
      error(yaml)
   end

   name = yaml.name

   if name == nil then
      cleanup()
      error("Remote repository doesn't specify a name.")
   end

   newpath = self.path .. "/" .. name

   if util.isdir(newpath) then
      cleanup()
      error("There already is a source with this name: " .. name)
   end

   ok, err = pcall(os.execute, 'mv "' .. tmp .. '" "' .. newpath .. '"')

   if not ok then
      cleanup()
      error(err)
   end

   cleanup()
end

function sources:load()
   local data = {}

   -- Load all yaml files
   --
   for iter, dir in lfs.dir(self.path) do
      if iter ~= '.' and iter ~= '..' then

         local full = util.realpath(self.path .. "/" .. iter)
         local config = full .. "/info.yml"

         if util.isdir(full) and util.isfile(config) then
            yaml = util.yaml_loadfile(config)
            local name = util.getname(yaml)
            yaml.path = full
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

   neu.home = config.path
   neu.path = config.sources
   neu:load()

   return neu
end

return sources
