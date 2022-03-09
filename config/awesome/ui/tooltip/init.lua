-- Standard awesome library
local gears = require("gears")
local awful = require("awful")

-- Theme handling library
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

-- Widget library
local wibox = require("wibox")

-- rubato
local rubato = require("module.rubato")

-- Helpers
local helpers = require("helpers")

-- Get screen geometry
local screen_width = awful.screen.focused().geometry.width
local screen_height = awful.screen.focused().geometry.height


-- Tooltip
------------

-- Helpers
local function create_boxed_widget(widget_to_be_boxed, width, height, inner_pad)
    local box_container = wibox.container.background()
    box_container.bg = beautiful.xcolor0
    box_container.forced_height = height
    box_container.forced_width = width
    box_container.shape = helpers.rrect(beautiful.tooltip_box_border_radius)

    local inner = dpi(0)

    if inner_pad then inner = beautiful.tooltip_box_margin end

    local boxed_widget = wibox.widget {
        -- Add margins
        {
            -- Add background color
            {
                -- The actual widget goes here
                widget_to_be_boxed,
                margins = inner,
                widget = wibox.container.margin
            },
            widget = box_container,
        },
        margins = beautiful.tooltip_gap / 2,
        color = "#FF000000",
        widget = wibox.container.margin
    }

    return boxed_widget
end

    -- Battery
    local batt_bar = wibox.widget {
        max_value = 100,
        value = 20,
        background_color = beautiful.transparent,
        color = beautiful.xcolor8,
        widget = wibox.widget.progressbar
    }

    local batt_bar_container = wibox.widget {
        batt_bar,
        direction = "east",
        widget = wibox.container.rotate
    }

    local batt_icon = wibox.widget{
        markup = helpers.colorize_text("", beautiful.xcolor1),
        font = beautiful.icon_font_name .. "Round 18",
        align = "center",
        valign = "center",
        widget = wibox.widget.textbox
    }

    local batt_icon_container = wibox.widget{
        nil,
        {
            nil,
            batt_icon,
            expand = "none",
            layout = wibox.layout.align.vertical
        },
        expand = "none",
        layout = wibox.layout.align.horizontal
    }

    local batt = wibox.widget{
        batt_bar_container,
        batt_icon_container,
        layout = wibox.layout.stack
    }

    local batt_val = 0
    local batt_charger

    awesome.connect_signal("signal::battery", function(value)
        batt_val = value
        awesome.emit_signal("widget::battery")
    end)

    awesome.connect_signal("signal::charger", function(state)
        batt_charger = state
        awesome.emit_signal("widget::battery")
    end)

    awesome.connect_signal("widget::battery", function()
        local b = ""
        local fill_color = beautiful.xcolor2

        if batt_val >= 88 and batt_val <= 100 then
            b = ""
        elseif batt_val >= 76 and batt_val < 88 then
            b = ""
        elseif batt_val >= 64 and batt_val < 76 then
            b = ""
        elseif batt_val >= 52 and batt_val < 64 then
            b = ""
        elseif batt_val >= 40 and batt_val < 52 then
            b = ""
        elseif batt_val >= 28 and batt_val < 40 then
            b = ""
        elseif batt_val >= 16 and batt_val < 28 then
            b = ""
        else
            b = ""
        end

        if batt_charger then
            b = ""
                if batt_val >= 11 and batt_val <= 30 then
                    fill_color = beautiful.xcolor3
                elseif batt_val <= 10 then
                    fill_color = beautiful.xcolor1
                end
        else
            if batt_val >= 11 and batt_val <= 30 then
                fill_color = beautiful.xcolor3
            elseif batt_val <= 10 then
                fill_color = beautiful.xcolor1
            end
        end

        batt_bar.value = batt_val
        batt_icon.markup = helpers.colorize_text(b, fill_color)
    end)

---- Calendar

-- Date
local date_day = wibox.widget{
    font = beautiful.font_name .. "medium 9",
    format = helpers.colorize_text("%A", beautiful.xcolor4),
    valign = "center",
    widget = wibox.widget.textclock
}

local date_month = wibox.widget{
    font = beautiful.font_name .. "bold 14",
    format = "%d %B",
    valign = "center",
    widget = wibox.widget.textclock
}

local date = wibox.widget{
    date_day,
    nil,
    date_month,
    layout = wibox.layout.align.vertical
}

-- Separator
local separator = wibox.widget{
    {
    bg = beautiful.xcolor5,
    shape = helpers.rrect(dpi(3)),
    forced_width = dpi(3),
    widget = wibox.container.background
    },
    right = dpi(5),
    widget = wibox.container.margin
}

-- Time
local time_hour = wibox.widget{
    font = beautiful.font_name .. "bold 18",
    format = "%H",
    align = "center",
    widget = wibox.widget.textclock
}

local time_min = wibox.widget{
    font = beautiful.font_name .. "bold 18",
    format = "%M",
    align = "center",
    widget = wibox.widget.textclock
}

-- Wifi
local wifi_status_icon = wibox.widget{
    markup = "Offline",
    font = beautiful.icon_font_name .. "Round 15",
    valign = "center",
    align = "center",
    widget = wibox.widget.textbox
}

local wifi = wibox.widget{
    wifi_status_icon,
    forced_width = dpi(40),
    forced_height = dpi(40),
    bg = beautiful.xcolor0,
    shape = helpers.rrect(beautiful.tooltip_box_border_radius),
    shape_border_width = dpi(2.25),
    shape_border_color = beautiful.xcolor1,
    widget = wibox.container.background
}

local wifi_status = false

awesome.connect_signal("signal::network", function(status, ssid)
    wifi_status = status
    awesome.emit_signal("widget::network")
end)

awesome.connect_signal("widget::network", function ()
    local w, fill_color
    if wifi_status == true then
        w = ""
        fill_color = beautiful.xcolor2
    else
        w = ""
        fill_color = beautiful.xcolor1
    end

    wifi.shape_border_color = fill_color
    wifi_status_icon.markup = helpers.colorize_text(w, fill_color)
end)

-- UpTime
local uptime_label = wibox.widget{
    font = beautiful.font_name .. "medium 9",
    markup = helpers.colorize_text("Uptime", beautiful.xcolor5),
    valign = "center",
    widget = wibox.widget.textbox
}

local uptime_value = wibox.widget.textbox()
awful.widget.watch("sh -c 'uptime -p | sed 's/^...//' | sed 's/.d..../d/' | sed 's/.h...../h/' | sed 's/.m....../m/''", 60, function(_, stdout)
    local out = stdout:gsub("^%s*(.-)%s*$", "%1")
    uptime_value.text = out
end)

local uptime_text = wibox.widget {
    font = beautiful.font_name .. "bold 13",
    valign = "center",
    widget = uptime_value
}

local uptime_container = wibox.widget{
        separator,
        {
            uptime_label,
            nil,
            uptime_text,
            layout = wibox.layout.align.vertical
        },
        {
            wifi,
            layout = wibox.layout.align.vertical
        },
        layout = wibox.layout.align.horizontal
}

-- Widget
local date_boxed = create_boxed_widget(date, dpi(110), dpi(50), true)
local hour_boxed = create_boxed_widget(time_hour, dpi(50), dpi(50), true)
local min_boxed = create_boxed_widget(time_min, dpi(50), dpi(50), true)
local batt_boxed = create_boxed_widget(batt, dpi(50), dpi(110))
local uptime_boxed = create_boxed_widget(uptime_container, dpi(170), dpi(50), true)

-- Tooltip
cal_tooltip = wibox({
    type = "dock",
    screen = screen.primary,
    height = dpi(200),
    width = dpi(200),
    shape = helpers.rrect(beautiful.tooltip_border_radius - 1),
    bg = beautiful.transparent,
    ontop = true,
    visible = false
})

awful.placement.bottom_left(cal_tooltip, {honor_workarea = true, margins = {left = beautiful.wibar_width + 11, bottom = dpi(44)}})

cal_tooltip_show = function()
    cal_tooltip.visible = true
end

cal_tooltip_hide = function()
    cal_tooltip.visible = false
end

cal_tooltip:setup {
    {
        {
            {
                {
                date_boxed,
                    {
                        hour_boxed,
                        min_boxed,
                        layout = wibox.layout.fixed.horizontal
                    },
                    layout = wibox.layout.fixed.vertical
                },
                {
                    batt_boxed,
                    layout = wibox.layout.fixed.vertical
                },
                layout = wibox.layout.fixed.horizontal
            },
            {
                uptime_boxed,
                layout = wibox.layout.fixed.horizontal
            },
            layout = wibox.layout.fixed.vertical
        },
        margins = beautiful.tooltip_gap,
        widget = wibox.container.margin
    },
    shape = helpers.rrect(beautiful.tooltip_border_radius),
    bg = beautiful.xbackground,
    widget = wibox.container.background
}
