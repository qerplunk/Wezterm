local wezterm = require 'wezterm';

return {
    enable_wayland = true,
    native_macros_fullscreen_mode = false,

    font = wezterm.font("JetBrains Mono", {stretch="Expanded", weight="Regular"}),
    --font = wezterm.font("RandyGG", {stretch="Expanded", weight="Regular"}),
    font_size = 11,

    initial_cols = 194,
    initial_rows = 51,
    line_height = 0.9,

    exit_behavior = "Close",
    window_close_confirmation = "NeverPrompt",

    enable_tab_bar = true,
    hide_tab_bar_if_only_one_tab = true,

    scrollback_lines = 5000,
    enable_scroll_bar = false,

    default_cursor_style = "BlinkingBlock",
    cursor_blink_rate = 500,

    colors = {
        foreground = "#c5c5c5",
        background = "#1b2224",

        cursor_fg = "#111111",
        cursor_bg = "#6d6f7a", --cursor_bg = "#d78700",
        cursor_border = "#ffffff", --cursor_border = "#d78700",

        selection_fg = "black",
        selection_bg = "#fffacd",

		-- OLD
        --ansi =    { "#000000", "#b22222", "#008000", "#999900", "#0066ff", "#ba55d3", "#009999", "#dddddd" },
        --brights = { "#808080", "#df0000", "#00d700", "#ffd700", "#5f87ff", "#875faf", "#00ffff", "#ffffff" },

		-- NEW
        brights =    { "#000000", "#b22222", "#008000", "#999900", "#0066ff", "#ba55d3", "#009999", "#dddddd" },
        ansi = { "#808080", "#ca0000", "#00b000", "#ffd700", "#5f87ff", "#875faf", "#00ffff", "#ffffff" },
    },

    bypass_mouse_reporting_modifiers = "SHIFT",
    disable_default_mouse_bindings = false,
    mouse_bindings = {
        {
            event={Up={streak=1, button="Left"}},
            mods="SHIFT",
            action="OpenLinkAtMouseCursor",
        },
    },

    use_dead_keys = false,
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
}
