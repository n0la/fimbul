--- @module fimbul.repository

local base = _G

local yaml = require("yaml")
local lfs = require("lfs")

local pretty = require("pl.pretty")

local logger = require("fimbul.logger")
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

function repository:_load_common()
   local home = os.getenv('HOME')
   local fimbulhome = home .. '/.fimbul'
   local common = fimbulhome .. '/common'

   if home == nil or not util.isdir(common) then
      return nil
   end

   self.home = fimbulhome
   self.common = common

   for iter, dir in lfs.dir(common) do
      if iter ~= "." and iter ~= ".." then
         local full = util.realpath(common .. "/" .. iter)

         if util.isdir(full) then
            -- Load common repository
            local repo = data_repository:new({name = iter,
                                              path = full})
            table.insert(self.data, repo)
         end
      end
   end
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

   self:_load_common()
end

-- This method is useful if there are files called <WHAT>.yml and
-- each of these files has one element in it.
--
function repository:_load_files(what, template, tbl)
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

-- This method is used if there are files called <WHAT>.yml and have
-- array of elements in them.
--
function repository:_load_array(what, template, tbl)
   local w = self:find_all('', what .. '.yml')
   local t = tbl or what

   for _, m in pairs(w) do
      local y = util.yaml_loadfile(m)

      if not y then
         error("Failed to load file " .. m)
      end

      for _, i in pairs(y) do
         local tmp = self.engine:create_template(template, i)
         table.insert(self[t], tmp)
      end
   end
end

function repository:find(tbl, ...)
   local t = {}

   for _, i in base.pairs(self[tbl]) do
      for _, name in base.pairs({i.name, table.unpack(i.aliases or {})}) do
         for _, what in base.pairs({...}) do
            if string.lower(name) == string.lower(what) then
               table.insert(t, i)
            end
         end
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
   -- PCs and NPCs
   self:_load_files("monsters", "monster_template", "monster")
   self:_load_files("encounters", "encounter_template", "encounter")
   self:_load_files("characters", "character_template", "character")
   -- Items and Gear
   self:_load_array("weapons", "weapon_template", "weapon")
   self:_load_array("materials", "material_template", "material")
   self:_load_array("armors", "armor_template", "armor")
   self:_load_array("shields", "shield_template", "shield")
   -- Special magical abilities
   self:_load_array("abilities", "ability_template", "ability")

   self:update_items()
end

function repository:update_items()
   local items = {}

   items = util.concat_table(items, self.weapon)
   items = util.concat_table(items, self.armor)
   items = util.concat_table(items, self.shield)

   self.items = items
end

function repository:spawn_characters()
   local t = {}

   for _, c in base.pairs(self.character) do
      local char = self:spawn(c)
      table.insert(t, char)
   end

   return t
end

function repository:parse_item(s)
   if not self.engine then
      error('No engine loaded. Please load a repository first.')
   end
   logger.verbose("Parsing item " .. s)
   return self.engine:parse_item(self, s)
end

function repository:spawn(t)
   if not self.engine then
      error('No engine loaded. Please load a repository first.')
   end
   logger.verbose("Spawning " .. t.templatetype .. " " .. t.name)
   return self.engine:spawn(self, t)
end

function repository:create_battle(e)
   -- Create battle with template and spawned characters
   return self.engine:create_battle(e, self:spawn_characters())
end

function repository.create(dir, args)
   local configdir = dir .. '/.pnp'
   local configfile = configdir .. '/config.yml'

   if args.name == nil then
      error('New repository parameters do not contain a name.')
   end

   if args.game == nil then
      error('New repository parameters do not contain a game.')
   end

   if util.isdir(configdir) then
      error('Path is already a repository: ' .. dir)
   end

   if not lfs.mkdir(configdir) then
      error('Failed to create a new repository path: ' .. configdir)
   end

   -- Try to create a new file.
   local ok, err = pcall(util.yaml_dumpfile, configfile, args)
   if not ok then
      lfs.rmdir(configdir)
      error(util.prettify(err))
   end
end

function repository:new(p)
   local neu = {}

   setmetatable(neu, self)
   self.__index =  self

   neu.data = {}

   neu.monster = {}
   neu.encounter = {}
   neu.character = {}
   neu.weapon = {}
   neu.material = {}
   neu.armor = {}
   neu.shield = {}
   neu.ability = {}

   if p ~= nil then
      neu:open(p)
   end

   return neu
end

return repository
