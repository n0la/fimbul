---@module fimbul.campaign.calendar

local calendar = {}

local util = require("fimbul.util")
local string = require("string")

local date = require("fimbul.campaign.date")

function calendar:initialise(blob)
   self.days_per_week = tonumber(blob.days_per_week)
   self.weeks_per_month = tonumber(blob.weeks_per_month)
   self.months_per_year = tonumber(blob.months_per_year)
   self.days_per_year = tonumber(blob.days_per_year)
   self.eras = blob.eras

   -- Sane default values
   if self.days_per_week == nil then
      self.days_per_week = 7
   end

   if self.weeks_per_month == nil then
      self.weeks_per_month = 4
   end

   if self.months_per_year == nil then
      self.months_per_year = 12
   end

   if self.days_per_month == nil then
      self.days_per_month = self.days_per_week *
         self.weeks_per_month
   end
   if self.days_per_year == nil then
      self.days_per_year = self.days_per_month *
         self.months_per_year
   end

   if blob.today ~= nil then
      self.today = self:parse_date(blob.today)
   end
end

function calendar:parse_date(str)
   local day, month, era, sign, year
      = string.match(str, "(%d+).(%d+).([%u%l]+)([+-]*)(%d+)")

   if day == nil or month == nil or era == nil or year == nil then
      error('Invalid date format.')
      return nil
   end

   local d = date:new()

   -- Check for a valid era
   if not util.containsif(self.eras, era, util.comparestr) then
      error('Unknown or unspecified era.')
      return nil
   end

   if sign == "-" then
      year = year * -1
   end

   d.day = tonumber(day)
   d.month = tonumber(month)
   d.era = era
   d.year = tonumber(year)

   self:normalise(d)

   return d
end

function calendar:add(date, obj)
   local copy = util.shallowclone(date)

   copy.day = copy.day + util.default(obj.day, 0)
   copy.day = copy.day + util.default(obj.days, 0)

   copy.month = copy.month + util.default(obj.month, 0)
   copy.month = copy.month + util.default(obj.months, 0)

   copy.year = copy.year + util.default(obj.year, 0)
   copy.year = copy.year + util.default(obj.years, 0)

   self:normalise(copy)
   return copy
end

function calendar:add_days(date, days)
   local copy = util.shallowclone(date)
   copy.day = copy.day + days
   self:normalise(copy)

   return copy
end

function calendar:add_weeks(date, weeks)
   return calendar:add_days(date, weeks * self.days_per_week)
end

function calendar:add_months(date, months)
   local copy = util.shallowclone(date)
   copy.month = copy.month + months
   self:normalise(copy)

   return copy
end

function calendar:add_years(date, years)
   local copy = util.shallowclone(date)
   copy.year = copy.year + years
   self:normalise(copy)

   return copy
end

function calendar:normalise(date)
   if date.day > self.days_per_month then
      month = math.floor(date.day / self.days_per_month)
      date.day = date.day % self.days_per_month
      date.month = date.month + month
   end

   if date.month > self.months_per_year then
      year = math.floor(date.month / self.months_per_year)
      date.month = date.month % self.months_per_year
      date.year = date.year + year
   end
end

function calendar:new(campaign, blob)
   local neu = {}

   setmetatable(neu, self)
   self.__index = self

   self.campaign = campaign
   if blob ~= nil then
      neu:initialise(blob)
   end

   return neu
end

return calendar
