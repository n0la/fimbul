--- @module fimbul.repository

local base = _G

local yaml = require("yaml")
local lfs = require("lfs")

local pretty = require("pl.pretty")

local util = require("fimbul.util")
local data_repository = require("fimbul.data_repository")

local repository = {}

function repository:load_configuration(name)
   local configfile = self.datapath .. "/" .. name
   local status, c = pcall(util.yaml_loadfile, configfile)

   assert(status, "Your repository is missing " .. name)

   return c
end

function repository:_load_config()
   c = self:load_configuration("config.yml")

   assert(c.name, "Please specify a name for your repository.")
   assert(c.game, "Please specify a game for your repository.")

   local ename = "fimbul." .. c.game .. ".engine"
   local engine = require(ename)

   assert(engine, "Repository uses unsupported game " .. c.game)

   self.engine = engine
   self.config = c
end

function repository:_find_path(path)
   local r = path
   local found = false

   while true do
      if r == "/" then
         break
      end

      if util.isdir(r .. "/.pnp/") then
         found = true
         break
      else
         r = r .. "/../"
         r = util.realpath(r)
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
            block.path = util.realpath(full)
            assert(block.path,
                   "The given data path " .. p .. " does not exist.")
         end

         local repository = data_repository:new(block)
         table.insert(self.data, repository)
      end
   end

   -- Setup default data repository
   table.insert(self.data,
                data_repository:new({name = "_local", path = self.root}))

end

function repository:_load_what(what, template, tbl)
   local w = self:find_all(what)
   local t = tbl or what

   for _, m in pairs(w) do
      local y = util.yaml_loadfile(m)
      if not y then
         error("Failed to load file " .. m)
      end
      local tmp = self.engine:create_template(template, y)
      table.insert(self[t], tmp)
   end
end

function repository:find(tbl, what)
   local t = {}

   for _, i in base.pairs(self[tbl]) do
      local name = i.name
      if string.lower(name) == string.lower(what) then
         table.insert(t, i)
      end
   end

   return t
end

function repository:all(what)
   local r = {}

   r = util.concat_table(r, self:find("monster", what))
   r = util.concat_table(r, self:find("encounter", what))

   return r
end

function repository:load()
   self:_load_what("monsters", "monster_template", "monster")
   self:_load_what("encounters", "encounter_template", "encounter")
   self:_load_what("characters", "character_template", "character")
end

function repository:spawn_characters()
   local t = {}

   for _, c in base.pairs(self.character) do
      local char = self:spawn(c)
      table.insert(t, char)
   end

   return t
end

function repository:spawn(t)
   return self.engine:spawn(self, t)
end

function repository:create_battle(e)
   -- Create battle with template and spawned characters
   return self.engine:create_battle(e, self:spawn_characters())
end

function repository:new(p)
   local neu = {}

   setmetatable(neu, self)
   self.__index =  self

   neu.data = {}

   neu.monster = {}
   neu.encounter = {}
   neu.character = {}

   neu:open(p)

   return neu
end

return repository
