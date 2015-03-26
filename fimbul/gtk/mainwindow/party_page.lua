---@module fimbul.gtk.mainwindow.party_page

local party_page = {}

local base = _G

local lgi = require('lgi')
local Gtk = lgi.require('Gtk', '3.0')
local GObject = lgi.require('GObject')

local Column = {
   NAME = 1,
   PLAYER = 2,
   XP = 3,
}

function party_page:widget()
   return self.grid
end

function party_page:name()
   return "Party"
end

function party_page:_setup()
   self.grid = Gtk.Grid()

   self.store =  Gtk.ListStore.new {
      [Column.NAME] = GObject.Type.STRING,
      [Column.PLAYER] = GObject.Type.STRING,
      [Column.XP] = GObject.Type.UINT,
   }

   local scroll = Gtk.ScrolledWindow({shadow_type = 'ETCHED_IN'})
   self.players = Gtk.TreeView(
      { id = 'players',
        model = self.store,
        expand = true,
        Gtk.TreeViewColumn(
           {
              title = "Name",
              sort_column_id = Column.NAME,
              {
                 Gtk.CellRendererText {},
                 { text = Column.NAME },
              },
        }),
        Gtk.TreeViewColumn(
           {
              title = "Player",
              sort_column_id = Column.PLAYER,
              {
                 Gtk.CellRendererText {},
                 { text = Column.PLAYER },
              },

           }
        ),
        Gtk.TreeViewColumn(
           {
              title = "XP",
              sort_column_id = Column.XP,
              {
                 Gtk.CellRendererText {},
                 { text = Column.XP },
              },
           }
        ),
   })
   scroll:add(self.players)
   self.grid:attach(scroll, 0, 0, 1, 1)

end

function party_page:on_repository_open()
   self.store =  Gtk.ListStore.new {
      [Column.NAME] = GObject.Type.STRING,
      [Column.PLAYER] = GObject.Type.STRING,
      [Column.XP] = GObject.Type.UINT,
   }

   for _, p in base.pairs(self.repository.character) do
      local item = { p.name, p.player, p.xp or 0 }
      self.store:append(item)
   end
   self.players:set_model(self.store)
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
