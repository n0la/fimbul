---@module fimbul.gtk.mainwindow

local mainwindow = {}

local base = _G
local table = require("table")

local lgi = require("lgi")
local Gtk = lgi.require("Gtk", "3.0")

local console_page = require("fimbul.gtk.mainwindow.console_page")
local party_page = require("fimbul.gtk.mainwindow.party_page")
local item_page = require("fimbul.gtk.mainwindow.item_page")

function mainwindow:_emit(f)
   for _, p in base.pairs(self.pages) do
      local event = p["on_" .. f]
      if event ~= nil and type(event) == 'function' then
         event(p)
      end
   end
end

function mainwindow:_file_open()
   dlg = Gtk.FileChooserDialog(
      { title = "Open repository...",
        action = Gtk.FileChooserAction.SELECT_FOLDER,
        transient_for = self.wnd,
        destroy_with_parent = true,
        buttons = {
           { "Open", Gtk.ResponseType.ACCEPT },
           { Gtk.STOCK_CANCEL, Gtk.ResponseType.CANCEL },
        },
   })

   res = dlg:run()
   if res == Gtk.ResponseType.ACCEPT then
      local filename = dlg:get_filename()
      dlg:destroy()

      ok, err = pcall(self.repository.open, self.repository, filename)

      if not ok then
         self.console:error(err);
      else
         -- Load repository
         ok, err = pcall(self.repository.load, self.repository)
         if not ok then
            self.console:error(err)
         else
            self:_emit("repository_open")
         end
      end
   else
      dlg:destroy()
   end
end

function mainwindow:_setup()
   self.wnd = Gtk.Window({
         title = 'Fimbul',
         on_destroy = Gtk.main_quit
   })
   self.wnd:set_size_request(600, 400)

   self.menubar = Gtk.MenuBar(
      {
         id = "menubar",
         Gtk.MenuItem {
            label = "File",
            visible = true,
            submenu = Gtk.Menu {
               Gtk.MenuItem {
                  label = "Open...",
                  id = "file_open",
                  on_activate = function () self:_file_open() end
               },
               Gtk.SeparatorMenuItem(),
               Gtk.MenuItem {
                  label = "Quit",
                  id = "file_quit",
                  on_activate = Gtk.main_quit
               }
            },
         },
   })

   self.notebook = Gtk.Notebook()
   self.pages = {}

   self.console = console_page:new(self.repository)
   table.insert(self.pages, self.console)

   self.party = party_page:new(self.repository)
   table.insert(self.pages, self.party)

   self.item = item_page:new(self.repository)
   table.insert(self.pages, self.item)

   for _, page in base.pairs(self.pages) do
      self.notebook:append_page(page:widget(),
                                Gtk.Label({label = page:name()}))
   end
   grid = Gtk.Grid()

   grid:attach(self.menubar, 0, 0, 1, 1)
   grid:attach(self.notebook, 0, 1, 1, 1)

   self.wnd:add(grid)
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
