--- @module fimbul.repository

local base = _G

local yaml = require("yaml")
local posix = require("posix")
local lfs = require("lfs")

local util = require("fimbul.util")
local data_repository = require("fimbul.data_repository")

local repository = {}

function repository:_load_config()
   local configfile = self.datapath .. "/config.yml"
   local status, c = pcall(util.yaml_loadfile, configfile)

   -- Check configuration file.
   assert(status, "Your repository has no config.yml")

   assert(c.name, "Please specify a name for your repository.")
   assert(c.game, "Please specify a game for your repository.")

   self.config = c
end

function repository:_find_path(path)
   local r = path
   local found = false

   while true do
      if r == "/" then
         break
      end

      local s = posix.stat(r .. "/.pnp/")
      if s and s.type == "directory" then
         found = true
         break
      else
         r = r .. "/../"
         r = posix.realpath(r)
      end
   end

   if found then
      self.root = r
      self.current = path
      self.datapath = self.root .. "/.pnp/"
   end

   return found
end

function repository:find_all(dirname, glob)
   local results = {}

   for _,dr in ipairs(self.data) do
      local r = dr:find_all(dirname, glob)
      results = util.concat_table(results, r)
   end

   return results
end

function repository:open(path)
   local p = path or lfs.currentdir()

   -- Find current path
   assert(self:_find_path(p), "Path is not a repository.")
   -- Load configuration
   self:_load_config()
   self.data = {}

   -- Setup different data repository directories
   if self.config.data then
      for _, block in base.ipairs(self.config.data) do
         local p = block.path

         -- Translate relative paths for ease of opening
         if p and util.is_relative(p) then
            local full = self.root .. "/" .. p
            block.path = posix.realpath(full)
            assert(block.path, "The given data path " .. p .. " does not exist.")
         end

         local repository = data_repository:new(block)
         table.insert(self.data, repository)
      end
   end

   -- Setup default data repository
   table.insert(self.data,
                data_repository:new({name = "_local", path = self.datapath}))

end

function repository:new(p)
   local neu = {}

   setmetatable(neu, self)
   self.__index =  self

   neu.data = {}
   neu:open(p)

   return neu
end

return repository
