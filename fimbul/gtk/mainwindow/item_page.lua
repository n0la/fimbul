---@module fimbul.gtk.mainwindow.item_page

local item_page = {}

local base = _G

local pretty = require('pl.pretty')

local lgi = require('lgi')
local Gtk = lgi.require('Gtk', '3.0')
local GObject = lgi.require('GObject')
local Pango = lgi.require('Pango')

local repository = require('fimbul.repository')

function item_page:widget()
   return self.grid
end

function item_page:name()
   return "Items & Loot"
end

function item_page:_append_text(s)
   local buf = self.log:get_buffer()
   buf:insert(buf:get_end_iter(), s .. "\n", -1)
   self.log:scroll_to_iter(buf:get_end_iter(), 0.0, true, 1, 1)
end

function item_page:_on_input()
   local s = self.input:get_buffer():get_text()

   if s:len() == 0 then
      return
   end

   self:_append_text('> ' .. s)
   self.input:get_buffer():set_text('', -1)

   ok, item = pcall(repository.parse_item, self.repository, s)
   if ok then
      -- Print information about the item parsed
      self:_append_text(item:string(true))
      -- Print the price in detail
      local pr, sv = item:price()
      self:_append_text(sv:string())
   else
      self:_append_text('Error: ' .. item)
   end
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
         editable = false,
         wrap_mode = 2
   })
   self.log:override_font(font)

   scroll = Gtk.ScrolledWindow({shadow_type = 'ETCHED_IN'})
   scroll:set_policy(2, 0)
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
