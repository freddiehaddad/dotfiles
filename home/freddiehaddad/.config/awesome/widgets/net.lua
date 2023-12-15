-------------------------------------------------
-- Network Widget for Awesome Window Manager
-- Shows the current network tx/rx rates

-- @author Freddie Haddad
-- @copyright 2023 Freddie Haddad
-------------------------------------------------

local awful = require('awful')
local watch = require('awful.widget.watch')
local wibox = require('wibox')
local beautiful = require('beautiful')
local gears = require('gears')

local HOME_DIR = os.getenv('HOME')
local WIDGET_DIR = HOME_DIR .. '/.config/awesome/widgets'
local CMD_DEVICE = [[sh -c "ip -brief route | grep --max-count=1 default | awk '{print $5}'"]]
local CMD_RX = [[sh -c "cat /sys/class/net/enp6s0/statistics/rx_bytes"]]
local CMD_TX = [[sh -c "cat /sys/class/net/enp6s0/statistics/tx_bytes"]]

local net_widget = {}
local net_rows = {
	spacing = 4,
	layout = wibox.layout.fixed.vertical,
}
local is_update = true
local process_rows = {
	layout = wibox.layout.fixed.vertical,
}

-- Remove spaces at end and beggining of a string
local function trim(s) return (s:gsub('^%s*(.-)%s*$', '%1')) end

-- Checks if a string starts with a another string
local function starts_with(str, start) return str:sub(1, #start) == start end

local function create_textbox(args)
	return wibox.widget({
		text = args.text,
		align = args.align or 'left',
		markup = args.markup,
		forced_width = args.forced_width or 40,
		widget = wibox.widget.textbox,
	})
end

local function create_process_header()
	local res = wibox.widget({
		create_textbox({ markup = '<b>PID</b>' }),
		create_textbox({ markup = '<b>Name</b>' }),
		{
			create_textbox({ markup = '<b>%CPU</b>' }),
			create_textbox({ markup = '<b>%MEM</b>' }),
			layout = wibox.layout.align.horizontal,
		},
		layout = wibox.layout.ratio.horizontal,
	})
	res:ajust_ratio(2, 0.2, 0.47, 0.33)

	return res
end

local function worker(user_args)
	local args = user_args or {}

	local mode = args.mode or 'rx'
	local width = args.width or 50
	local step_width = args.step_width or 2
	local step_spacing = args.step_spacing or 1
	local slow = args.slow or beautiful.fg_normal
	local medium = args.medium or '#FFFF00'
	local fast = args.fast or '#FF0000'
	local background_color = args.background_color or '#00000000'
	local timeout = args.timeout or 1

	local netrxgraph_widget = wibox.widget({
		max_value = 100,
		background_color = background_color,
		forced_width = width,
		step_width = step_width,
		step_spacing = step_spacing,
		widget = wibox.widget.graph,
		color = 'linear:0,0:0,20:0,' .. fast .. ':0.3,' .. medium .. ':0.6,' .. slow,
	})

	--- By default graph widget goes from left to right, so we mirror it and push up a bit
	net_widget = wibox.widget({
		{
			netrxgraph_widget,
			reflection = { horizontal = true },
			layout = wibox.container.mirror,
		},
		bottom = 2,
		color = background_color,
		widget = wibox.container.margin,
	})

	-- This part runs constantly, also when the popup is closed.
	-- It updates the graph widget in the bar.
	local netstats = {
		rx_prev = 0,
	}

	local cmd
	if mode == 'rx' then
		cmd = CMD_RX
	else
		cmd = CMD_TX
	end

	watch(cmd, timeout, function(widget, stdout)
		local link_speed = args.max or 1000 -- Mbits/sec
		local megabit = 1 << 20 -- 1,048,576
		local max_bps = link_speed * megabit

		local rx_bytes = stdout:match('(%d+)')
		local rx_delta = rx_bytes - netstats.rx_prev
		netstats.rx_prev = rx_bytes

		local rx_rate = rx_delta * 8 -- bits/sec
		local speed_percent = rx_rate / max_bps * 100.0

		widget:add_value(speed_percent)
	end, netrxgraph_widget)

	return net_widget
end

return setmetatable(net_widget, { __call = function(_, ...) return worker(...) end })
