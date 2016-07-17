---@module fimbul.eh.engine

-- Engine for the Endless Horizons RPG
--

local engine = {}
package.loaded['fimbul.eh.engine'] = engine

local base = _G

local rules = require('fimbul.eh.rules')

local spawner = require('fimbul.spawner')

local magazine_template = require('fimbul.eh.magazine_template')

local combat = require('fimbul.eh.combat')

local util = require('fimbul.util')

function engine:init(r)
   r.eh = {}

   r.eh.characters = {}
   r.eh.races = {}
   r.eh.skills = {}
   r.eh.backgrounds = {}
   r.eh.perks = {}
   r.eh.flaws = {}

   -- Equipment
   r.eh.cartridges = {}
   r.eh.firearms = {}
   r.eh.magazines = {}
end

function engine:create_combat(r)
   return combat:new(r)
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
   return self._spawner:spawn(r, t)
end

function engine:create_template(what, ...)
   return self._spawner:create_template(what, ...)
end

function engine:characters(r)
   return r.eh.characters
end

function engine:_create_magazines(r)
   local mags = {}

   for _, i in base.ipairs(r.eh.firearms) do
      for _, m in base.pairs(i.magazines) do
         -- Internal magazines can't be external. What?
         if not m.internal then
            tmp = magazine_template:new(
               {
                  capacity = m.capacity,
                  name = i.name .. ' Magazine [' .. m.capacity .. ']',
                  weapon = i.name,
                  cost = i.cost * rules.equipment.MAGAZINE_COST,
               }
            )
            table.insert(mags, tmp)
         end
      end
   end

   return mags
end

function engine:load(r)
   r:_load_array('skills', 'skill_template', r.eh.skills)
   r:_load_array('backgrounds', 'background_template', r.eh.backgrounds)
   r:_load_array('races', 'race_template', r.eh.races)
   r:_load_files('characters', 'character_template', r.eh.characters)
   -- Load equipment
   r:_load_array('cartridges', 'cartridge_template', r.eh.cartridges);
   r:_load_array('firearms', 'firearm_template', r.eh.firearms);
   -- Create magazine templates based on firearms
   r.eh.magazines = self:_create_magazines(r)

   r.eh.items = {}
   r.eh.items = util.concat_table(r.eh.items, r.eh.cartridges)
   r.eh.items = util.concat_table(r.eh.items, r.eh.magazines)
   r.eh.items = util.concat_table(r.eh.items, r.eh.firearms)
end

function engine:description()
   return "Engine for the Endless Horizons Space RPG."
end

function engine:new(r)
   local neu = {}

   setmetatable(neu, self)
   self.__index = self

   neu._spawner = spawner:new('fimbul.eh')
   -- Initialise our spawner
   neu._spawner:add('skill', 'character', 'race',
                     'background', 'cartridge', 'firearm',
                     'magazine')

   return neu
end

return engine
