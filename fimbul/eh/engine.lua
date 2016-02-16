---@module fimbul.eh.engine

-- Engine for the Endless Horizons RPG
--

local engine = {}
package.loaded['fimbul.eh.engine'] = engine

local skill = require('fimbul.eh.skill')
local skill_template = require('fimbul.eh.skill_template')

local character = require('fimbul.eh.character')
local character_template = require('fimbul.eh.character_template')

local background = require('fimbul.eh.background')
local background_template = require('fimbul.eh.background_template')

local cartridge = require('fimbul.eh.cartridge')
local cartridge_template = require('fimbul.eh.cartridge_template')

local firearm = require('fimbul.eh.firearm')
local firearm_template = require('fimbul.eh.firearm_template')

local util = require('fimbul.util')

function engine:init(r)
   r.eh = {}

   r.eh.characters = {}
   r.eh.skills = {}
   r.eh.backgrounds = {}
   r.eh.perks = {}
   r.eh.flaws = {}

   -- Equipment
   r.eh.cartridges = {}
   r.eh.firearms = {}
end

function engine:parse_item(r, s)
   local parts = util.split(s)

   if #parts == 0 then
      return nil
   end

   it = nil

   spawner = function(str, tbl, pos, i)
      local item = r:find(r.eh.items, str)

      if item ~= nil and #item > 0 and it == nil then
         local t = util.shallowcopy(parts)
         t = util.remove(t, pos, i)
         it = r:spawn(item[1])
         if it ~= nil then
            -- TODO: Make unit test.
            it:_parse_attributes(r, t)
            return true
         end
      end

      return false
   end

   for i = 1, #parts do
      ok = util.lookahead(parts, i, spawner)
      if ok then
         break
      end
   end

   return it
end

function engine:spawn(r, t)
   if t.templatetype == 'skill' then
      return skill:spawn(r, t)
   elseif t.templatetype == 'character' then
      return character:spawn(r, t)
   elseif t.templatetype == 'background' then
      return background:spawn(r, t)
   elseif t.templatetype == 'cartridge' then
      return cartridge:spawn(r, t)
   elseif t.templatetype == 'firearm' then
      return firearm:spawn(r, t)
   else
      error('Unsupported template in EH: ' .. what)
   end
end

function engine:create_template(what, ...)
   if what == 'skill_template' then
      return skill_template:new(...)
   elseif what == 'character_template' then
      return character_template:new(...)
   elseif what == 'background_template' then
      return background_template:new(...)
   elseif what == 'cartridge_template' then
      return cartridge_template:new(...)
   elseif what == 'firearm_template' then
      return firearm_template:new(...)
   else
      error('Unsupported template in EH: ' .. what)
   end
end

function engine:characters(r)
   return r.eh.characters
end

function engine:load(r)
   r:_load_array('skills', 'skill_template', r.eh.skills)
   r:_load_array('backgrounds', 'background_template', r.eh.backgrounds)
   r:_load_files('characters', 'character_template', r.eh.characters)
   -- Load equipment
   r:_load_array('cartridges', 'cartridge_template', r.eh.cartridges);
   r:_load_array('firearms', 'firearm_template', r.eh.firearms);

   r.eh.items = {}
   r.eh.items = util.concat_table(r.eh.items, r.eh.cartridges)
   r.eh.items = util.concat_table(r.eh.items, r.eh.firearms)
end

function engine:description()
   return "Engine for the Endless Horizons Space RPG."
end

function engine:new(r)
   local neu = {}

   setmetatable(neu, self)
   self.__index = self

   return neu
end

return engine
