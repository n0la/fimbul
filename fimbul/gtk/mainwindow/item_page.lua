---@module fimbul.gtk.mainwindow.item_page

local item_page = {}

local base = _G

local lgi = require('lgi')
local Gtk = lgi.require('Gtk', '3.0')
local GObject = lgi.require('GObject')
local Pango = lgi.require('Pango')

function item_page:widget()
   return self.grid
end

function item_page:name()
   return "Items & Loot"
end

function item_page:_on_input()
end

function item_page:_setup()
   self.grid = Gtk.Grid()

   font = Pango.FontDescription()
   font:set_family("monospace")

   self.input = Gtk.Entry({name = "input", hexpand = true})
   self.input:override_font(font)
   self.input.on_activate = function() self:_on_input() end
   self.grid:attach(self.input, 0, 0, 1, 1)

   self.log = Gtk.TextView({
         name = "items",
         hexpand = true,
         vexpand = true,
         editable = false
   })
   self.log:override_font(font)

   scroll = Gtk.ScrolledWindow()
   scroll:add(self.log)

   self.grid:attach(scroll, 0, 1, 1, 1)
end

function item_page:new(repository)
   local neu = {}

   setmetatable(neu, self)
   self.__index = self

   neu.repository = repository

   neu:_setup()

   return neu
end

return item_page
