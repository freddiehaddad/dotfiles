-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, 'luarocks.loader')

-- Standard awesome library
local gears = require('gears')
local awful = require('awful')
require('awful.autofocus')
-- Widget and layout library
local wibox = require('wibox')
-- Theme handling library
local beautiful = require('beautiful')
-- Notification library
local naughty = require('naughty')
local menubar = require('menubar')
local hotkeys_popup = require('awful.hotkeys_popup')
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require('awful.hotkeys_popup.keys')

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then naughty.notify({
	preset = naughty.config.presets.critical,
	title = 'Oops, there were errors during startup!',
	text = awesome.startup_errors,
}) end

-- Handle runtime errors after startup
do
	local in_error = false
	awesome.connect_signal('debug::error', function(err)
		-- Make sure we don't go into an endless error loop
		if in_error then return end
		in_error = true

		naughty.notify({
			preset = naughty.config.presets.critical,
			title = 'Oops, an error happened!',
			text = tostring(err),
		})
		in_error = false
	end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_configuration_dir() .. 'theme.lua')

-- This is used later as the default terminal and editor to run.
local terminal = 'alacritty'
local editor = 'nvim'
local editor_cmd = terminal .. ' -e ' .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
local modkey = 'Mod4'

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
	awful.layout.suit.tile,
	awful.layout.suit.tile.left,
	awful.layout.suit.tile.bottom,
	awful.layout.suit.tile.top,
	awful.layout.suit.fair,
	awful.layout.suit.fair.horizontal,
	awful.layout.suit.spiral,
	awful.layout.suit.spiral.dwindle,
	awful.layout.suit.max,
	awful.layout.suit.max.fullscreen,
	awful.layout.suit.magnifier,
	awful.layout.suit.corner.nw,
	awful.layout.suit.corner.ne,
	awful.layout.suit.corner.sw,
	awful.layout.suit.corner.se,
	awful.layout.suit.floating,
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
local myawesomemenu = {
	{ 'hotkeys', function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
	{ 'manual', terminal .. ' -e man awesome' },
	{ 'edit config', editor_cmd .. ' ' .. awesome.conffile },
	{ 'restart', awesome.restart },
	{ 'quit', function() awesome.quit() end },
}

local mymainmenu = awful.menu({
	items = {
		{ 'awesome', myawesomemenu, beautiful.awesome_icon },
		{ 'open terminal', terminal },
	},
})

local mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon, menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
-- local mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
local mytextclock = wibox.widget.textclock()

local function set_wallpaper(s)
	-- Wallpaper
	if beautiful.wallpaper then
		local wallpaper = beautiful.wallpaper
		-- If wallpaper is a function, call it with the screen
		if type(wallpaper) == 'function' then wallpaper = wallpaper(s) end
		gears.wallpaper.maximized(wallpaper, s, true)
	end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal('property::geometry', set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
	-- Wallpaper
	set_wallpaper(s)

	-- Each screen has its own tag table.
	awful.tag({ '1', '2', '3', '4' }, s, awful.layout.layouts[1])

	s.tags[1].master_width_factor = 0.73

	-- Create a promptbox for each screen
	s.mypromptbox = awful.widget.prompt()
	-- Create an imagebox widget which will contain an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	s.mylayoutbox = awful.widget.layoutbox(s)

	-- Create a taglist widget
	s.mytaglist = awful.widget.taglist({
		screen = s,
		filter = awful.widget.taglist.filter.all,
	})

	-- Create a tasklist widget
	s.mytasklist = awful.widget.tasklist({
		screen = s,
		filter = awful.widget.tasklist.filter.currenttags,
		-- buttons = tasklist_buttons,
	})

	-- Create the wibox
	s.mywibox = awful.wibar({ position = 'top', screen = s })

	-- Add widgets to the wibox
	s.mywibox:setup({
		layout = wibox.layout.align.horizontal,
		{ -- Left widgets
			layout = wibox.layout.fixed.horizontal,
			mylauncher,
			s.mytaglist,
			s.mypromptbox,
		},
		s.mytasklist, -- Middle widget
		{ -- Right widgets
			layout = wibox.layout.fixed.horizontal,
			mytextclock,
			wibox.widget.systray(),
			s.mylayoutbox,
		},
	})
end)
-- }}}

-- {{{ Mouse bindings
-- root.buttons(gears.table.join(awful.button({}, 3, function() mymainmenu:toggle() end), awful.button({}, 4, awful.tag.viewnext), awful.button({}, 5, awful.tag.viewprev)))
-- }}}

-- {{{ Key bindings
local globalkeys = gears.table.join(
	-- awful.key({ modkey }, 'w', function() mymainmenu:show() end, { description = 'show main menu', group = 'awesome' }),
	awful.key({ modkey }, 's', hotkeys_popup.show_help, { description = 'show help', group = 'awesome' }),

	-- focus navigation
	awful.key({ modkey, 'Control' }, 'h', function() awful.client.focus.bydirection('left') end, { description = 'focus next left', group = 'client' }),
	awful.key({ modkey, 'Control' }, 'j', function() awful.client.focus.bydirection('down') end, { description = 'focus next below', group = 'client' }),
	awful.key({ modkey, 'Control' }, 'k', function() awful.client.focus.bydirection('up') end, { description = 'focus next above', group = 'client' }),
	awful.key({ modkey, 'Control' }, 'l', function() awful.client.focus.bydirection('right') end, { description = 'focus next right', group = 'client' }),

	-- window movement
	awful.key({ modkey, 'Shift' }, 'h', function() awful.client.swap.bydirection('left') end, { description = 'swap with left client ', group = 'client' }),
	awful.key({ modkey, 'Shift' }, 'j', function() awful.client.swap.bydirection('down') end, { description = 'swap with lower client', group = 'client' }),
	awful.key({ modkey, 'Shift' }, 'k', function() awful.client.swap.bydirection('up') end, { description = 'swap with upper client', group = 'client' }),
	awful.key({ modkey, 'Shift' }, 'l', function() awful.client.swap.bydirection('right') end, { description = 'swap with right client', group = 'client' }),

	-- window minimize/maximize
	awful.key({ modkey, 'Control' }, 'n', function()
		local c = awful.client.restore()
		-- Focus restored client
		if c then c:emit_signal('request::activate', 'key.unminimize', { raise = true }) end
	end, { description = 'restore minimized', group = 'client' }),

	-- tag naviagation
	awful.key({ modkey }, '1', function()
		local screen = awful.screen.focused()
		local tag = screen.tags[1]
		if tag then tag:view_only() end
	end, { description = 'view tag #1', group = 'tag' }),

	awful.key({ modkey }, '2', function()
		local screen = awful.screen.focused()
		local tag = screen.tags[2]
		if tag then tag:view_only() end
	end, { description = 'view tag #2', group = 'tag' }),

	awful.key({ modkey }, '3', function()
		local screen = awful.screen.focused()
		local tag = screen.tags[3]
		if tag then tag:view_only() end
	end, { description = 'view tag #3', group = 'tag' }),

	awful.key({ modkey }, '4', function()
		local screen = awful.screen.focused()
		local tag = screen.tags[4]
		if tag then tag:view_only() end
	end, { description = 'view tag #4', group = 'tag' }),

	-- window/tag placement
	awful.key({ modkey, 'Control' }, '1', function()
		if client.focus then
			local tag = client.focus.screen.tags[1]
			if tag then client.focus:move_to_tag(tag) end
		end
	end, { description = 'move focused client to tag #1', group = 'tag' }),

	awful.key({ modkey, 'Control' }, '2', function()
		if client.focus then
			local tag = client.focus.screen.tags[2]
			if tag then client.focus:move_to_tag(tag) end
		end
	end, { description = 'move focused client to tag #2', group = 'tag' }),

	awful.key({ modkey, 'Control' }, '3', function()
		if client.focus then
			local tag = client.focus.screen.tags[3]
			if tag then client.focus:move_to_tag(tag) end
		end
	end, { description = 'move focused client to tag #3', group = 'tag' }),

	awful.key({ modkey, 'Control' }, '4', function()
		if client.focus then
			local tag = client.focus.screen.tags[4]
			if tag then client.focus:move_to_tag(tag) end
		end
	end, { description = 'move focused client to tag #4', group = 'tag' }),

	-- layout switching
	awful.key({ modkey, 'Control' }, ';', function() awful.layout.inc(1) end, { description = 'select next', group = 'layout' }),
	awful.key({ modkey, 'Control', 'Shift' }, ';', function() awful.layout.inc(-1) end, { description = 'select previous', group = 'layout' }),

	-- urgent window jumping
	awful.key({ modkey, 'Control' }, 'u', awful.client.urgent.jumpto, { description = 'jump to urgent client', group = 'client' }),
	awful.key({ modkey, 'Control', 'Shift' }, 'u', awful.client.focus.history.previous, { description = 'jump back to previuos focus', group = 'client' }),

	-- master grid sizing
	awful.key({ modkey, 'Control' }, 'Left', function() awful.tag.incmwfact(-0.002) end, { description = 'decrease master width factor', group = 'layout' }),
	awful.key({ modkey, 'Control' }, 'Right', function() awful.tag.incmwfact(0.002) end, { description = 'increase master width factor', group = 'layout' }),

	-- master increase/decrase
	awful.key({ modkey, 'Control' }, 'm', function() awful.tag.incnmaster(1) end, { description = 'increase the number of master clients', group = 'layout' }),
	awful.key({ modkey, 'Control', 'Shift' }, 'm', function() awful.tag.incnmaster(-1) end, { description = 'decrease the number of master clients', group = 'layout' }),

	-- grid increase/decrease
	awful.key({ modkey, 'Control' }, 'c', function() awful.tag.incncol(1) end, { description = 'increase the number of columns', group = 'layout' }),
	awful.key({ modkey, 'Control', 'Shift' }, 'c', function() awful.tag.incncol(-1) end, { description = 'decrease the number of columns', group = 'layout' }),

	-- standard programs
	awful.key({ modkey }, 'Return', function() awful.spawn(terminal) end, { description = 'open a terminal', group = 'launcher' }),
	awful.key({ modkey }, 'd', function() awful.screen.focused().mypromptbox:run() end, { description = 'run prompt', group = 'launcher' }),

	-- awesome controls
	awful.key({ modkey, 'Control', 'Shift' }, 'r', awesome.restart, { description = 'reload awesome', group = 'awesome' }),
	awful.key({ modkey, 'Control', 'Shift' }, 'q', awesome.quit, { description = 'quit awesome', group = 'awesome' })
)

local clientkeys = gears.table.join(
	-- full screen
	awful.key({ modkey }, 'f', function(c)
		c.fullscreen = not c.fullscreen
		c:raise()
	end, { description = 'toggle fullscreen', group = 'client' }),

	-- kill
	awful.key({ modkey, 'Shift' }, 'q', function(c) c:kill() end, { description = 'close', group = 'client' }),

	-- toggle float
	awful.key({ modkey, 'Control' }, 'f', awful.client.floating.toggle, { description = 'toggle floating', group = 'client' }),

	-- swap with master
	awful.key({ modkey, 'Shift' }, 'm', function(c) c:swap(awful.client.getmaster()) end, { description = 'move to master', group = 'client' }),

	-- maximize
	awful.key({ modkey, 'Control', 'Shift' }, 'k', function(c)
		c.maximized_vertical = not c.maximized_vertical
		c:raise()
	end, { description = 'toggle maximize vertically', group = 'client' }),

	awful.key({ modkey, 'Control', 'Shift' }, 'h', function(c)
		c.maximized_horizontal = not c.maximized_horizontal
		c:raise()
	end, { description = 'toggle maximize horizontally', group = 'client' }),

	-- unmaximize
	awful.key({ modkey, 'Control', 'Shift' }, 'j', function(c)
		c.maximized = false
		-- c:raise()
	end, { description = 'unmaximize', group = 'client' })
)

-- Mouse resize/move bindings
local clientbuttons = gears.table.join(
	awful.button({}, 1, function(c) c:emit_signal('request::activate', 'mouse_click', { raise = true }) end),
	awful.button({ modkey }, 1, function(c)
		c:emit_signal('request::activate', 'mouse_click', { raise = true })
		awful.mouse.client.move(c)
	end),
	awful.button({ modkey }, 3, function(c)
		c:emit_signal('request::activate', 'mouse_click', { raise = true })
		awful.mouse.client.resize(c)
	end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
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
			placement = awful.placement.no_overlap + awful.placement.no_offscreen,
			properties = { titlebars_enabled = false },
		},
	},

	-- OpenRGB
	{
		rule = { class = 'openrgb' },
		properties = { floating = true, placement = awful.placement.centered },
	},

	-- Zoom
	{
		rule = { class = 'zoom' },
		properties = { floating = true, placement = awful.placement.centered },
	},

	-- 1Password
	{
		rule = { class = '1Password' },
		properties = { floating = true, placement = awful.placement.top_right },
	},

	-- Dialogs, Popups, Open, Save, ...
	{
		rule = { class = 'firefox', name = 'Library' },
		properties = { floating = true, placement = awful.placement.centered },
	},
	{
		rule = { class = 'firefox', name = 'About Mozilla Firefox' },
		properties = { floating = true, placement = awful.placement.centered },
	},
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal('manage', function(c)
	-- Set the windows at the slave,
	-- i.e. put it at the end of others instead of setting it master.
	-- if not awesome.startup then awful.client.setslave(c) end

	if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
		-- Prevent clients from being unreachable after screen count changes.
		awful.placement.no_offscreen(c)
	end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal('request::titlebars', function(c)
	-- buttons for the titlebar
	local buttons = gears.table.join(
		awful.button({}, 1, function()
			c:emit_signal('request::activate', 'titlebar', { raise = true })
			awful.mouse.client.move(c)
		end),
		awful.button({}, 3, function()
			c:emit_signal('request::activate', 'titlebar', { raise = true })
			awful.mouse.client.resize(c)
		end)
	)

	awful.titlebar(c):setup({
		{ -- Left
			awful.titlebar.widget.iconwidget(c),
			buttons = buttons,
			layout = wibox.layout.fixed.horizontal,
		},
		{ -- Middle
			{ -- Title
				align = 'center',
				widget = awful.titlebar.widget.titlewidget(c),
			},
			buttons = buttons,
			layout = wibox.layout.flex.horizontal,
		},
		{ -- Right
			awful.titlebar.widget.floatingbutton(c),
			awful.titlebar.widget.maximizedbutton(c),
			awful.titlebar.widget.stickybutton(c),
			awful.titlebar.widget.ontopbutton(c),
			awful.titlebar.widget.closebutton(c),
			layout = wibox.layout.fixed.horizontal(),
		},
		layout = wibox.layout.align.horizontal,
	})
end)

client.connect_signal('focus', function(c) c.border_color = beautiful.border_focus end)
client.connect_signal('unfocus', function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- Startup Applications
for app, opts in pairs({
	['picom'] = {}, -- ~/.config/picom/picom.conf (see: /usr/share/doc/picom/picom.conf.example)
	-- ['xcompmgr'] = { args = '-- xcompmgr -c -l0 -t0 -r0 -o.00' },
	['1password'] = {},
	['openrgb'] = { args = '--startminimized' },
	['firefox'] = {},
	['alacritty'] = {},
}) do
	local args = opts.args or ''
	awful.spawn.with_shell(string.format('pgrep %s || %s %s', app, app, args))
end
