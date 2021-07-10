-- Standard awesome library
local gears = require "gears"
local awful = require "awful"
require "awful.autofocus"
-- Theme handling library
local beautiful = require "beautiful"
-- Notification library
local naughty = require "naughty"
local hotkeys_popup = require "awful.hotkeys_popup"
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require "awful.hotkeys_popup.keys"
local bar = require "bar"

-- Load Debian menu entries
local debian = require "debian.menu"
local has_fdo, freedesktop = pcall(require, "freedesktop")

-- Handle runtime errors after startup
do
  local in_error = false
  awesome.connect_signal(
    "debug::error",
    function(err)
      -- Make sure we don't go into an endless error loop
      if in_error then
        return
      end
      in_error = true

      naughty.notify(
        {
          preset = naughty.config.presets.critical,
          title = "Oops, an error happened!",
          text = tostring(err)
        }
      )
      in_error = false
    end
  )
end

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
beautiful.wallpaper = "/usr/share/backgrounds/surface.jpg"

-- Globals
modkey = "Mod4"
terminal = "kitty"
editor = os.getenv("EDITOR") or "nvim"
editor_cmd = terminal .. " -e " .. editor

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
  awful.layout.suit.tile,
  awful.layout.suit.floating
  -- awful.layout.suit.spiral,
  -- awful.layout.suit.spiral.dwindle,
}

local function set_wallpaper(s)
  -- Wallpaper
  if beautiful.wallpaper then
    local wallpaper = beautiful.wallpaper
    -- If wallpaper is a function, call it with the screen
    if type(wallpaper) == "function" then
      wallpaper = wallpaper(s)
    end
    gears.wallpaper.maximized(wallpaper, s, true)
  end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(
  function(s)
    -- Menubar
    -- bar(s)

    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag({"1", "2", "3", "4", "5", "6", "7", "8", "9"}, s, awful.layout.layouts[1])
  end
)
-- }}}

-- {{{ Mouse bindings
root.buttons(
  gears.table.join(
    awful.button(
      {},
      3,
      function()
        mymainmenu:toggle()
      end
    ),
    awful.button({}, 4, awful.tag.viewnext),
    awful.button({}, 5, awful.tag.viewprev)
  )
)
-- }}}

-- {{{ Key bindings
globalkeys =
  gears.table.join(
  awful.key({modkey}, "s", hotkeys_popup.show_help, {description = "show help", group = "awesome"}),
  awful.key({modkey}, "Escape", awful.tag.history.restore, {description = "go back", group = "tag"}),
  awful.key(
    {modkey},
    "j",
    function()
      awful.client.focus.byidx(1)
    end,
    {description = "focus next by index", group = "client"}
  ),
  awful.key(
    {modkey},
    "k",
    function()
      awful.client.focus.byidx(-1)
    end,
    {description = "focus previous by index", group = "client"}
  ),
  -- Layout manipulation
  awful.key(
    {modkey, "Shift"},
    "j",
    function()
      awful.client.swap.byidx(1)
    end,
    {description = "swap with next client by index", group = "client"}
  ),
  awful.key(
    {modkey, "Shift"},
    "k",
    function()
      awful.client.swap.byidx(-1)
    end,
    {description = "swap with previous client by index", group = "client"}
  ),
  awful.key(
    {modkey, "Control"},
    "j",
    function()
      awful.screen.focus_relative(1)
    end,
    {description = "focus the next screen", group = "screen"}
  ),
  awful.key(
    {modkey, "Control"},
    "k",
    function()
      awful.screen.focus_relative(-1)
    end,
    {description = "focus the previous screen", group = "screen"}
  ),
  awful.key({modkey}, "u", awful.client.urgent.jumpto, {description = "jump to urgent client", group = "client"}),
  -- Standard program
  awful.key(
    {modkey},
    "Return",
    function()
      awful.spawn(terminal)
    end,
    {description = "open a terminal", group = "launcher"}
  ),
  awful.key({modkey, "Control"}, "r", awesome.restart, {description = "reload awesome", group = "awesome"}),
  awful.key({modkey, "Shift"}, "q", awesome.quit, {description = "quit awesome", group = "awesome"}),
  awful.key(
    {modkey},
    "l",
    function()
      awful.tag.incmwfact(0.05)
    end,
    {description = "increase master width factor", group = "layout"}
  ),
  awful.key(
    {modkey},
    "h",
    function()
      awful.tag.incmwfact(-0.05)
    end,
    {description = "decrease master width factor", group = "layout"}
  ),
  awful.key(
    {modkey},
    "space",
    function()
      awful.layout.inc(1)
    end,
    {description = "select next", group = "layout"}
  ),
  awful.key(
    {modkey, "Control"},
    "n",
    function()
      local c = awful.client.restore()
      -- Focus restored client
      if c then
        c:emit_signal("request::activate", "key.unminimize", {raise = true})
      end
    end,
    {description = "restore minimized", group = "client"}
  ),
  -- Menubar
  awful.key(
    {modkey},
    "p",
    function()
      awful.spawn("rofi -show drun")
    end,
    {description = "show the menubar", group = "launcher"}
  ),
  -- Custom Keybinds
  -- You can checkout which key is which with `xbindkeys --key`
  -- Firefox
  awful.key(
    {modkey},
    "b",
    function()
      awful.spawn("/opt/firefox/firefox")
    end
  ),
  -- Volume Mixer
  awful.key(
    {},
    "XF86AudioLowerVolume",
    function()
      awful.spawn("amixer set Master 5%-")
    end
  ),
  awful.key(
    {},
    "XF86AudioRaiseVolume",
    function()
      awful.spawn("amixer set Master 5%+")
    end
  ),
  awful.key(
    {},
    "XF86AudioMute",
    function()
      awful.spawn("amixer -D pulse set Master 1+ toggle")
    end
  ),
  -- Following requires `playerctl`
  awful.key(
    {},
    "XF86AudioPlay",
    function()
      awful.spawn("playerctl play-pause")
    end
  ),
  awful.key(
    {},
    "XF86AudioPrev",
    function()
      awful.spawn("playerctl previous")
    end
  ),
  awful.key(
    {},
    "XF86AudioNext",
    function()
      awful.spawn("playerctl next")
    end
  ),
  awful.key(
    {},
    "Print",
    function()
      awful.spawn("gnome-screenshot -c -a")
    end
  )
)

clientkeys =
  gears.table.join(
  awful.key(
    {modkey},
    "f",
    function(c)
      c.fullscreen = not c.fullscreen
      c:raise()
    end,
    {description = "toggle fullscreen", group = "client"}
  ),
  awful.key(
    {modkey},
    "q",
    function(c)
      c:kill()
    end,
    {description = "close", group = "client"}
  ),
  awful.key(
    {modkey, "Control"},
    "space",
    awful.client.floating.toggle,
    {description = "toggle floating", group = "client"}
  ),
  awful.key(
    {modkey, "Control"},
    "Return",
    function(c)
      c:swap(awful.client.getmaster())
    end,
    {description = "move to master", group = "client"}
  ),
  awful.key(
    {modkey},
    "o",
    function(c)
      c:move_to_screen()
    end,
    {description = "move to screen", group = "client"}
  ),
  awful.key(
    {modkey},
    "n",
    function(c)
      -- The client currently has the input focus, so it cannot be
      -- minimized, since minimized clients can't have the focus.
      c.minimized = true
    end,
    {description = "minimize", group = "client"}
  )
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
  globalkeys =
    gears.table.join(
    globalkeys,
    -- View tag only.
    awful.key(
      {modkey},
      "#" .. i + 9,
      function()
        local screen = awful.screen.focused()
        local tag = screen.tags[i]
        if tag then
          tag:view_only()
        end
      end,
      {description = "view tag #" .. i, group = "tag"}
    ),
    -- Toggle tag display.
    awful.key(
      {modkey, "Control"},
      "#" .. i + 9,
      function()
        local screen = awful.screen.focused()
        local tag = screen.tags[i]
        if tag then
          awful.tag.viewtoggle(tag)
        end
      end,
      {description = "toggle tag #" .. i, group = "tag"}
    ),
    -- Move client to tag.
    awful.key(
      {modkey, "Shift"},
      "#" .. i + 9,
      function()
        if client.focus then
          local tag = client.focus.screen.tags[i]
          if tag then
            client.focus:move_to_tag(tag)
          end
        end
      end,
      {description = "move focused client to tag #" .. i, group = "tag"}
    ),
    -- Toggle tag on focused client.
    awful.key(
      {modkey, "Control", "Shift"},
      "#" .. i + 9,
      function()
        if client.focus then
          local tag = client.focus.screen.tags[i]
          if tag then
            client.focus:toggle_tag(tag)
          end
        end
      end,
      {description = "toggle focused client on tag #" .. i, group = "tag"}
    )
  )
end

clientbuttons =
  gears.table.join(
  awful.button(
    {},
    1,
    function(c)
      c:emit_signal("request::activate", "mouse_click", {raise = true})
    end
  ),
  awful.button(
    {modkey},
    1,
    function(c)
      c:emit_signal("request::activate", "mouse_click", {raise = true})
      awful.mouse.client.move(c)
    end
  ),
  awful.button(
    {modkey},
    3,
    function(c)
      c:emit_signal("request::activate", "mouse_click", {raise = true})
      awful.mouse.client.resize(c)
    end
  )
)

-- Set keys
root.keys(globalkeys)

-- Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
  -- All clients will match this rule.
  {
    rule = {},
    properties = {
      border_width = beautiful.border_width,
      border_color = beautiful.border_normal,
      focus = awful.client.focus.filter,
      raise = true,
      keys = clientkeys,
      buttons = clientbuttons,
      screen = awful.screen.preferred,
      placement = awful.placement.no_overlap + awful.placement.no_offscreen
    }
  },
  -- Floating clients.
  {
    rule_any = {
      instance = {
        "DTA", -- Firefox addon DownThemAll.
        "copyq", -- Includes session name in class.
        "pinentry"
      },
      class = {
        "Arandr",
        "Blueman-manager",
        "Gpick",
        "Kruler",
        "MessageWin", -- kalarm.
        "Sxiv",
        "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
        "Wpa_gui",
        "veromix",
        "xtightvncviewer"
      },
      -- Note that the name property shown in xprop might be set slightly after creation of the client
      -- and the name shown there might not match defined rules here.
      name = {
        "Event Tester" -- xev.
      },
      role = {
        "pop-up" -- e.g. Google Chrome's (detached) Developer Tools.
      }
    },
    properties = {floating = true}
  }
}

-- Signals
-- Signal function to execute when a new client appears.
client.connect_signal(
  "manage",
  function(c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    if not awesome.startup then
      awful.client.setslave(c)
    end

    if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
      -- Prevent clients from being unreachable after screen count changes.
      awful.placement.no_offscreen(c)
    end
  end
)

client.connect_signal(
  "focus",
  function(c)
    c.border_color = "#CECE9E"
    c.border_width = 3
  end
)
client.connect_signal(
  "unfocus",
  function(c)
    c.border_color = "#7aa2f7"
    c.border_width = 3
  end
)

-- Autostart Applications
awful.spawn.with_shell("xrandr --auto --output eDP-1 --right-of DP-1")
awful.spawn.with_shell("xinput set-prop 'DELL07EC:00 06CB:7E92 Touchpad' 'libinput Tapping Enabled' 1")
awful.spawn.with_shell("xinput set-prop 13 322 1")
awful.spawn.with_shell("$HOME/.config/polybar/launch.sh")

-- Gaps within panes
beautiful.useless_gap = 5
