---@module fimbul.eh.engine

-- Engine for the Endless Horizons RPG
--

local engine = {}
package.loaded['fimbul.eh.engine'] = engine

local skill = require('fimbul.eh.skill')
local skill_template = require('fimbul.eh.skill_template')

local character = require('fimbul.eh.character')
local character_template = require('fimbul.eh.character_template')

function engine:init(r)
   r.eh = {}

   r.eh.characters = {}
   r.eh.skills = {}
   r.eh.perks = {}
   r.eh.flaws = {}
end

function engine:spawn(r, t)
   if t.templatetype == 'skill' then
      return skill:spawn(r, t)
   elseif t.templatetype == 'character' then
      return character:spawn(r, t)
   else
      error('Unsupported template in EH: ' .. what)
   end
end

function engine:create_template(what, ...)
   if what == 'skill_template' then
      return skill_template:new(...)
   elseif what == 'character_template' then
      return character_template:new(...)
   else
      error('Unsupported template in EH: ' .. what)
   end
end

function engine:load(r)
   r:_load_array('skills', 'skill_template', r.eh.skills)
   r:_load_files('characters', 'character_template', r.eh.characters)
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
