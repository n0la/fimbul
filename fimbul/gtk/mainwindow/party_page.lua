---@module fimbul.gtk.mainwindow.party_page

local party_page = {}

local lgi = require('lgi')
local Gtk = lgi.require('Gtk', '3.0')

function party_page:widget()
   return self.grid
end

function party_page:name()
   return "Party"
end

function party_page:_setup()
   self.grid = Gtk.Grid()
end

function party_page:on_repository_open()
end

function party_page:new(repository)
   local neu = {}

   setmetatable(neu, self)
   self.__index = self

   neu.repository = repository

   neu:_setup()

   return neu
end

return party_page
