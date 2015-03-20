---@module fimbul.campaign

local campaign = {}

local calendar = require("fimbul.campaign.calendar")
local date = require("fimbul.campaign.date")

function campaign:load()
   local yaml = self.repository:load_configuration("campaign.yml")
   self.yaml = yaml
end

function campaign:calendar()
   if self.yaml.calendar == nil then
      error("No calendar data available for this campaign.")
   end

   if self.cal == nil then
      self.cal = calendar:new(self, self.yaml.calendar)
   end

   return self.cal
end

function campaign:today()
   if self.yaml.calendar == nil or self.yaml.today == nil then
      error("No calendar and no current date specified.")
   end

   local date = self:calendar():parse_date(self.yaml.today)
   return date
end

function campaign:new(repository)
   local neu = {}

   setmetatable(neu, self)
   self.__index = self

   self.repository = repository
   neu:load()

   return neu
end

return campaign
