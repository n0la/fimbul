--- @module fimbul.repository

local base = _G

local yaml = require("yaml")
local lfs = require("lfs")

local pretty = require("pl.pretty")

local logger = require("fimbul.logger")
local util = require("fimbul.util")
local data_repository = require("fimbul.data_repository")

local repository = {}

repository.SUPPORTED_GAMES = {'v35'}
repository.BASE_PATH = '/usr/share/fimbul'

function repository.supported_games()
   return repository.SUPPORTED_GAMES
end

function repository:load_engine(game)
   if not util.contains(repository.supported_games(), game) then
      error('Invalid game: ' .. game)
   end

   engine_class = require('fimbul.' .. game .. '.engine')
   assert(engine_class, 'Could not load game engine: ' .. game)

   engine = engine_class:new(self)
   assert(engine, 'Could not create a new instance of the game engine: ' .. game)

   return engine
end

function repository:game_information(game)
   local engine = self:load_engine(game)
   local info = { description = engine:description() }

   return info
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

function repository:open(game)
   if not util.contains(repository.supported_games(), game) then
      error('Invalid game: ' .. game)
   end

   local descpath = repository.BASE_PATH .. '/' .. game .. '.yaml'
   logger.verbose('Loading file: ' .. descpath)
   local status, c = pcall(util.yaml_loadfile, descpath)

   if not status then
      error(c)
   end

   if c.data then
      for _, repo in base.ipairs(c.data) do
         local block = {}

         block.path = repository.BASE_PATH .. '/' .. repo
         block.name = repo

         logger.verbose('Loading repository ' .. repo .. ' from ' .. block.path)
         local repo = data_repository:new(block)
         table.insert(self.data, repo)
      end
   end

   -- Load engine
   local e = self:load_engine(game)
   self:engine(e)

   -- Load data
   self:load()
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
      local tmp = self._engine:create_template(template, y)
      table.insert(t, tmp)
   end
end

-- This method is used if there are files called <WHAT>.yml and have
-- array of elements in them.
--
function repository:_load_array(what, template, tbl)
   local w = self:find_all('', what .. '.yml')
   local w = util.concat_table(w, self:find_all('', what .. '.yaml'))
   local t = tbl or what

   for _, m in pairs(w) do
      logger.verbose('Loading file: ' .. m)
      local y = util.yaml_loadfile(m)

      if not y then
         error("Failed to load file " .. m)
      end

      for _, i in pairs(y) do
         local tmp = self._engine:create_template(template, i)
         table.insert(t, tmp)
      end
   end
end

function repository:find(tbl, ...)
   local t = {}
   local target

   if type(tbl) == 'string' then
      target = self[tbl]
   elseif type(tbl) == 'table' then
      target = tbl
   end

   for _, i in base.pairs(target) do
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

function repository:create_combat()
   return self._engine:create_combat(self)
end

function repository:find_spawn_first(tbl, ...)
   local r = self:find(tbl, ...)

   if r == nil or #r == 0 then
      error('Nothing found for spawning.')
   end

   local o = self:spawn(r[1])
   if o == nil then
      error('Failed to spawn object')
   end

   return o, r[1]
end

function repository:spawn_character(name)
   local cs = self:engine():characters(self)
   return self:find_spawn_first(cs, name)
end

function repository:spawn_characters()
   local c = {}
   local cs = self:engine():characters(self)
   for _, i in base.pairs(cs) do
      l = self:spawn_character(i.name)
      table.insert(c, l)
   end

   return c
end

function repository:encounters()
   return self:engine():encounters(self)
end

function repository:spawn_encounter(name)
   local cs = self:engine():encounters(self)
   return self:find_spawn_first(cs, name)
end

function repository:spawn_encounter_entity(name)
   local cs = self:engine():encounter_entities(self)
   return self:find_spawn_first(cs, name)
end

function repository:has_function(name, ...)
   for _, repo in base.ipairs(self.data) do
      if repo:has_function(name) then
         return true
      end
   end

   return false
end

function repository:engine(neu)
   if neu ~= nil then
      self._engine = neu
      -- Initialise engine.
      self._engine:init(self)
   end
   return self._engine
end

function repository:load()
   if not self._engine then
      error('Please select an engine first.')
   end
   -- Delegate loading to the engine.
   self._engine:load(self)
end

function repository:call_function(name, ...)
   for _, repo in base.ipairs(self.data) do
      if repo:has_function(name) then
         return repo:call_function(name, ...)
      end
   end

   error('Requesting to call non-existant repo function: ' .. name)
end

function repository:parse_item(s)
   if not self._engine then
      error('No engine loaded. Please load a repository first.')
   end
   logger.verbose("Parsing item " .. s)
   return self._engine:parse_item(self, s)
end

function repository:spawn(t)
   if not self._engine then
      error('No engine loaded. Please load a repository first.')
   end
   logger.verbose("Spawning " .. t.templatetype .. ' with the name ' .. t.name)
   return self._engine:spawn(self, t)
end

function repository:create_battle(e)
   -- Create battle with template and spawned characters
   return self._engine:create_battle(e, self:spawn_characters())
end

function repository:new(p)
   local neu = {}

   setmetatable(neu, self)
   self.__index =  self

   neu.data = {}

   if p ~= nil then
      neu:open(p)
   end

   return neu
end

return repository
