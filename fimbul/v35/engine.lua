--- @module fimbul.v35.engine

local engine = {}
package.loaded["fimbul.v35.engine"] = engine

local base = _G

local stacked_value = require("fimbul.stacked_value")

local creature =  require("fimbul.v35.creature")
local encounter = require("fimbul.v35.encounter")

local rules = require("fimbul.v35.rules")

local monster_template = require("fimbul.v35.monster_template")
local encounter_template = require("fimbul.v35.encounter_template")

function engine.stacked_value(c)
   -- Compose a new stacked value with proper v35 rules
   -- in place. Mostly regarding dodge and circumstance
   return stacked_value.new(c or stacked_value, rules.stacking_rules)
end

function engine:create_template(what, ...)
   if what == "monster_template" then
      return monster_template:new(...)
   elseif what == "encounter_template" then
      return encounter_template:new(...)
   else
      error("Unsupported template in v35: " .. what)
   end
end

function engine:spawn(repository, template)
   if template.templatetype == "monster" then
      return creature:spawn(repository, template)
   elseif template.templatetype == "encounter" then
      return encounter:spawn(repository, template)
   end
end

function engine:new()
   local neu = {}

   setmetatable(neu, self)
   self.__index = self

   return neu
end

return engine
