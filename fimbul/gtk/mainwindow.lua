---@module fimbul.gtk.mainwindow

local mainwindow = {}

local lgi = require("lgi")
local Gtk = lgi.require("Gtk", "3.0")

local console_page = require("fimbul.gtk.mainwindow.console_page")

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
      ok, err = pcall(self.repository.open, self.repository, dlg:get_filename())

      if not ok then
         self.console:error(err);
      else
         self.console:say("Repository successfully opened.")
      end
   end
   dlg:destroy()
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
   self.console = console_page:new(self.repository)
   self.notebook:append_page(self.console:widget(),
                             Gtk.Label({label = self.console:name()}))

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
