---@module fimbul.gtk.mainwindow

local mainwindow = {}

local lgi = require("lgi")
local Gtk = lgi.require("Gtk", "3.0")

local console_page = require("fimbul.gtk.mainwindow.console_page")

function mainwindow:_setup()
   self.wnd = Gtk.Window({
         title = 'Fimbul',
         on_destroy = Gtk.main_quit
   })
   self.wnd:set_size_request(600, 400)

   self.notebook = Gtk.Notebook()
   self.wnd:add(self.notebook)

   self.console = console_page:new(self.repository)

   self.notebook:append_page(self.console:widget(),
                             Gtk.Label({label = self.console:name()}))
end

function mainwindow:show()
   self.wnd:show_all()
end

function mainwindow:new(repository)
   local neu = {}

   setmetatable(neu, self)
   self.__index = self

   neu.repository = repository
   neu:_setup()

   return neu
end

return mainwindow
