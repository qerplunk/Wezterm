local wezterm = require "wezterm"

local io = require "io"
local os = require "os"
local json = require "json"

local scrollback_lines = 200000;

local COLORS = {
	"#3c1361",
	"#52307c",
	"#663a82",
	"#7c5295",
	"#b491c8"
}

if wezterm.target_triple == "x86_64-pc-windows-msvc" then
    font_dirs = {
        "C:\\Users\\edgar\\.dotfiles\\.fonts"
    }
    default_prog = {
        "nu"
    }
    window_background_image = ""
end

if wezterm.target_triple == "x86_64-apple-darwin" then
    font_dirs = {
        "/home/mib/.dotfiles/.fonts"
    }
    default_prog = {
        "nu"
    }
    window_background_image = ""
end

if wezterm.target_triple == "x86_64-unknown-linux-gnu" then
    font_dirs = {
        "/home/mib/.dotfiles/.fonts"
    }
    default_prog = {
        "/home/mib/.rustup/bin/nu"
    }
    window_background_image = ""
end

function font_with_fallback(name, params)
    local names = {name, "Fairfax Nerd Font"}
    return wezterm.font_with_fallback(names, params)
end

function recompute_padding(window)
    local window_dims = window:get_dimensions()
    local overrides = window:get_config_overrides() or {}
    if not window_dims.is_full_screen then
        if not overrides.window_padding then
            return
        end
        overrides.window_padding = nil
    else
        local third = math.floor(window_dims.pixel_width / 3)
        local new_padding = {
            left = third,
            right = third,
            top = 0,
            bottom = 0
        }
        if overrides.window_padding and new_padding.left == overrides.window_padding.left then
            return
        end
        overrides.window_padding = new_padding
    end
    window:set_config_overrides(overrides)
end

wezterm.on(
    "update-right-status",
    function(window, pane)
        local success, data, stderr =
            wezterm.run_child_process(
            {"deno", "run", "-A", "--reload", "c:\\Users\\mib\\.dotfiles\\wezterm\\index.ts"}
        )
        local cells = {}
        local cwd_uri = pane:get_current_working_dir()
        if cwd_uri then
            cwd_uri = cwd_uri:sub(8)
            local slash = cwd_uri:find("/")
            local cwd = ""
            local hostname = ""
            if slash then
                hostname = cwd_uri:sub(1, slash - 1)
                local dot = hostname:find("[.]")
                if dot then
                    hostname = hostname:sub(1, dot - 1)
                end
                cwd = cwd_uri:sub(slash)

                table.insert(cells, cwd:sub(2))
            end
        end

        table.insert(cells, date)
        table.insert(cells, data:sub(0, 11))

        local text_fg = "#c0c0c0"
        local elements = {}
        local num_cells = 0

        table.insert(elements, {Foreground = {Color = "#3c1361"}})
        table.insert(elements, {Text = SOLID_LEFT_ARROW})

        function push(text, is_last)
            local cell_no = num_cells + 1
            table.insert(elements, {Foreground = {Color = text_fg}})
            table.insert(elements, {Background = {Color = COLORS[cell_no]}})
            table.insert(elements, {Text = " " .. text .. " "})
            if not is_last then
                table.insert(elements, {Foreground = {Color = COLORS[cell_no + 1]}})
                table.insert(elements, {Text = SOLID_LEFT_ARROW})
            end
            num_cells = num_cells + 1
        end

        while #cells > 0 do
            local cell = table.remove(cells, 1)
            push(cell, #cells == 0)
        end

        window:set_right_status(wezterm.format(elements))
    end
)

wezterm.on(
    "trigger-nvim-with-scrollback",
    function(window, pane)
        local scrollback = pane:get_lines_as_text(scrollback_lines)
        local name = os.tmpname()
        local f = io.open(name, "w+")
        f:write(scrollback)
        f:flush()
        f:close()
        window:perform_action(wezterm.action {SpawnCommandInNewTab = {args = {"nvim", name}}}, pane)

        wezterm.sleep_ms(1000)
        os.remove(name)
    end
)

wezterm.on(
    "open-uri",
    function(window, pane, uri)
        local start, match_end = uri:find("file://")
        if start == 1 then
            local file = uri:sub(match_end + 1)
            window:perform_action(
                wezterm.action {SpawnCommandInNewWindow = {args = {"nu", "-c", "nvim " .. file}}},
                pane
            )
            return false
        end
    end
)

wezterm.on(
    "toggle-ligature",
    function(window, pane)
        local overrides = window:get_config_overrides() or {}
        if not overrides.font then
            overrides.font = font_with_fallback("Fira Code", {})
            overrides.font_rules = {
                {
                    italic = false,
                    intensity = "Normal",
                    font = font_with_fallback("Fira Code", {})
                },
                {
                    italic = false,
                    intensity = "Bold",
                    font = font_with_fallback("Fira Code", {})
                },
                {
                    italic = true,
                    intensity = "Normal",
                    font = font_with_fallback("Fira Code", {})
                },
                {
                    italic = true,
                    intensity = "Bold",
                    font = font_with_fallback("Fira Code", {})
                }
            }
        else
            overrides.font = nil
            overrides.font_rules = nil
            overrides.font_antialias = nil
        end
        window:set_config_overrides(overrides)
    end
)

wezterm.on(
    "toggle-opacity",
    function(window, pane)
        local overrides = window:get_config_overrides() or {}
        if not overrides.window_background_opacity then
            overrides.window_background_opacity = 0.5
        else
            overrides.window_background_opacity = nil
        end
        window:set_config_overrides(overrides)
    end
)

wezterm.on(
    "window-resized",
    function(window, pane)
        recompute_padding(window)
    end
)

wezterm.on(
    "window-config-reloaded",
    function(window)
        recompute_padding(window)
    end
)

return {
    font_dirs = font_dirs,
    font_size = 9.0,
    font = font_with_fallback("Fairfax Nerd Font", {}),

    ssh_domains = {
		{
		  name = "mib",
		  remote_address = "mibbox.eminds.de",
		  username = "mib",
		},
        {
            name = "localssh",
            remote_address = "127.0.0.1",
            username = "mib"
        },
		{
		  name = "user.lan",
		  remote_address = "10.13.100.29",
		  username = "mib",
		}
    },
    font_rules = {
        {
            italic = false,
            intensity = "Normal",
            font = font_with_fallback("Fairfax Nerd Font", {})
        },
        {
            italic = false,
            intensity = "Bold",
            font = font_with_fallback("Fairfax Nerd Font", {})
        },
        {
            italic = true,
            intensity = "Normal",
            font = font_with_fallback("Fairfax Nerd Font", {})
        },
        {
            italic = true,
            intensity = "Bold",
            font = font_with_fallback("Fairfax Nerd Font", {})
        }
    },
    selection_word_boundary = ' \t\n{[}]()"\'',
	exit_behavior = "Hold",
    harfbuzz_features = {"calt=1", "clig=1", "liga=1"},
    status_update_interval = 2000,
    custom_block_glyphs = true,
    allow_square_glyphs_to_overflow_width = "Always",
    freetype_load_target = "Light",
    freetype_load_flags = "FORCE_AUTOHINT|NO_AUTOHINT",
    bold_brightens_ansi_colors = true,
    front_end = "OpenGL",
    prefer_egl = true,
    color_scheme = "Dracula",
	colors = {
		tab_bar = {
			background = "#0b0022",
			active_tab = {
				bg_color = "#3c1361",
				fg_color = "#c0c0c0",
				intensity = "Normal"
			},
			inactive_tab = {
				bg_color = "#1b1032",
				fg_color = "#808080",
			},
			inactive_tab_hover = {
				bg_color = "#3b3052",
				fg_color = "#909090"
			}
		}
	},
    tab_bar_style = {
        active_tab_left = wezterm.format(
            {
                {Background = {Color = "#0b0022"}},
                {Foreground = {Color = "#3c1361"}},
                {Text = SOLID_LEFT_ARROW}
            }
        ),
        active_tab_right = wezterm.format(
            {
                {Background = {Color = "#0b0022"}},
                {Foreground = {Color = "#3c1361"}},
                {Text = SOLID_RIGHT_ARROW}
            }
        ),
        inactive_tab_left = wezterm.format(
            {
                {Background = {Color = "#0b0022"}},
                {Foreground = {Color = "#1b1032"}},
                {Text = SOLID_LEFT_ARROW}
            }
        ),
        inactive_tab_right = wezterm.format(
            {
                {Background = {Color = "#0b0022"}},
                {Foreground = {Color = "#1b1032"}},
                {Text = SOLID_RIGHT_ARROW}
            }
        )
    },
    alternate_buffer_wheel_scroll_speed = 5,
    window_background_image = window_background_image,
    window_decorations = "RESIZE",
    window_close_confirmation = "NeverPrompt",
    window_background_opacity = 0.96,
    text_background_opacity = 1.0,
    window_padding = {
        left = 5,
        right = 5,
        top = 5,
        bottom = 5
    },
    window_background_image_hsb = {
        brightness = 0.8,
        hue = 1.0,
        saturation = 1.0
    },
    inactive_pane_hsb = {
        brightness = 0.8,
        hue = 1.0,
        saturation = 0.8
    },
    tab_max_width = 16,
    default_cursor_style = "BlinkingUnderline",
	cursor_blink_rate = 1000,
    hide_tab_bar_if_only_one_tab = false,
    initial_rows = 40,
    initial_cols = 180,
    scrollback_lines = scrollback_lines,
    enable_scroll_bar = false,
    default_prog = default_prog,
    check_for_updates = false,
    launch_menu = {
        {
            label = "-----"
        },
        {
            label = "cmd",
            args = {
                "wezterm",
                "start",
                "cmd"
            }
        },
        {
            label = "-----"
        }
    },
    ssh_domains = {
        {
            name = "localssh",
            remote_address = "127.0.0.1",
            username = "qerplunk"
        },
		{
		  name = "user.lan",
		  remote_address = "10.13.100.29",
		  username = "qerplunk",
		}
    },
    disable_default_key_bindings = true,
    leader = {key = "a", mods = "CTRL", timeout_milliseconds = 1000},

    keys = {
        {key = "a", mods = "LEADER|CTRL", action = wezterm.action {SendString = "\x01"}},
        {key = "C", mods = "LEADER", action = wezterm.action {CloseCurrentTab = {confirm = true}}},
        -- Search
        {key = "f", mods = "LEADER", action = wezterm.action {Search = {CaseInSensitiveString = ""}}},
        -- Pane Splitting
        {key = "F", mods = "LEADER", action = "TogglePaneZoomState"},
        {key = "h", mods = "LEADER", action = wezterm.action {SplitVertical = {domain = "CurrentPaneDomain"}}},
        {key = "v", mods = "LEADER", action = wezterm.action {SplitHorizontal = {domain = "CurrentPaneDomain"}}},
        {key = "c", mods = "LEADER", action = wezterm.action {CloseCurrentPane = {confirm = false}}},
        -- Move between panes
        {key = "l", mods = "ALT", action = wezterm.action {ActivatePaneDirection = "Right"}},
        {key = "h", mods = "ALT", action = wezterm.action {ActivatePaneDirection = "Left"}},
        {key = "k", mods = "ALT", action = wezterm.action {ActivatePaneDirection = "Up"}},
        {key = "j", mods = "ALT", action = wezterm.action {ActivatePaneDirection = "Down"}},
        -- Resize panes
        {key = "l", mods = "ALT|SHIFT", action = wezterm.action {AdjustPaneSize = {"Right", 1}}},
        {key = "h", mods = "ALT|SHIFT", action = wezterm.action {AdjustPaneSize = {"Left", 1}}},
        {key = "k", mods = "ALT|SHIFT", action = wezterm.action {AdjustPaneSize = {"Up", 1}}},
        {key = "j", mods = "ALT|SHIFT", action = wezterm.action {AdjustPaneSize = {"Down", 1}}},
        -- Tab Navigation
        {key = "L", mods = "LEADER", action = "ShowLauncher"},
        {key = "N", mods = "LEADER", action = "ShowTabNavigator"},
        {key = "n", mods = "LEADER", action = wezterm.action {SpawnTab = "CurrentPaneDomain"}},
        --
        {key = "1", mods = "LEADER", action = wezterm.action {ActivateTab = 0}},
        {key = "2", mods = "LEADER", action = wezterm.action {ActivateTab = 1}},
        {key = "3", mods = "LEADER", action = wezterm.action {ActivateTab = 2}},
        {key = "4", mods = "LEADER", action = wezterm.action {ActivateTab = 3}},
        {key = "5", mods = "LEADER", action = wezterm.action {ActivateTab = 4}},
        {key = "DownArrow", mods = "LEADER", action = "Hide"},
        -- Scrolling
        {key = "k", mods = "CTRL|SHIFT", action = wezterm.action {ScrollByLine = -10}},
        {key = "j", mods = "CTRL|SHIFT", action = wezterm.action {ScrollByLine = 10}},
        -- misc
        {key = "K", mods = "LEADER", action = wezterm.action {ClearScrollback = "ScrollbackOnly"}},
        {key = "r", mods = "LEADER", action = "ReloadConfiguration"},
        {key = "o", mods="LEADER", action = "ActivateLastTab"},
        --
        {key="9", mods="LEADER", action="ToggleFullScreen"},
    },

    mouse_bindings = {
        {event = {Up = {streak = 1, button = "Left"}}, mods = "SHIFT", action = {ExtendSelectionToMouseCursor = {}}},
        {event = {Down = {streak = 3, button = "Left"}}, mods = "NONE", action = {SelectTextAtMouseCursor = "SemanticZone"}}
    }
}
