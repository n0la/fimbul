---@module fimbul.gtk.mainwindow.console

local console_page = {}

local lgi = require('lgi')
local Gtk = lgi.require('Gtk', '3.0')
local Pango = lgi.require("Pango")

local command_dispatcher = require("fimbul.ui.command_dispatcher")

function console_page:_append_text(s)
   local buf = self.log:get_buffer()
   buf:insert(buf:get_end_iter(), s .. "\n", -1)
   self.log:scroll_to_iter(buf:get_end_iter(), 0.0, true, 1, 1)
end

function console_page:_on_input()
   local s = self.input:get_buffer():get_text()

   if s:len() > 0 then
      self:_append_text('> ' .. s)

      self.input:get_buffer():set_text('', -1)
      ok, cmd, args = self.dispatcher:parse(s)
      if ok then
         found, ret = self.dispatcher:run(cmd, args)
         if not found then
            self:_append_text('No such command: ' .. cmd)
         end
      else
         self:_append_text('Parsing error: ' .. cmd)
      end
   end
end

function console_page:_setup()
   self.consolegrid = Gtk.Grid()
   self.log = Gtk.TextView({
         name = "log",
         hexpand = true,
         vexpand = true,
         editable = false
   })

   font = Pango.FontDescription()
   font:set_family("monospace")
   self.log:override_font(font)

   scroll = Gtk.ScrolledWindow()
   scroll:add(self.log)

   self.input = Gtk.Entry({name = "input", hexpand = 1})
   self.input.on_activate = function (o) self:_on_input() end

   self.consolegrid:attach(scroll, 0, 0, 1, 1)
   self.consolegrid:attach(self.input, 0, 1, 1, 1)

   -- Override logging functions.
   self.dispatcher = command_dispatcher:new(self.repository)
   self.dispatcher.say = function (o, s) self:_append_text(s) end
   self.dispatcher.error = function (o, s) self:_append_text(s) end
end

function console_page:widget()
   return self.consolegrid
end

function console_page:name()
   return 'Console';
end

function console_page:new(repository)
   local neu = {}

   setmetatable(neu, self)
   self.__index = self

   neu.repository = repository
   neu:_setup()

   return neu
end

return console_page
