---@module fimbul.encounter

local base = _G

local encounter = {}

function encounter:new()
   local neu = {}

   setmetatable(neu, self)
   self.__index = self

   neu._name = ''
   neu._participants = {}
   neu._logger = battle_logger:new()

   return neu
end

function encounter:name()
   return self._name
end

function encounter:participants()
   return self._participants
end

function encounter:spawn(r, e)
   local neu = self:new()

   if not e.name then
      error('An encounter needs a name')
   end

   neu._name = e.name

   for _, m in base.pairs(e._participants or {}) do
      local t = m.type
      local a = m.amount or "1"

      a = dice_expression.evaluate(a)

      for i = 1, a do
         local template = r:spawn_encounter_entity(t)

         if template == nil then
            error('Encounter ' .. neu:name() .. ' uses monster ' .. t
                     .. ' which cannot be found')
         else
            template = template[1]
         end

         table.insert(neu._participants, template)
      end
   end

   return neu
end

function encounter:string(e)
   print("FECK OFF")
end

return encounter
