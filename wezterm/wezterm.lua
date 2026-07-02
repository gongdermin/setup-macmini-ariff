-- WezTerm: Nord terminal theme
local wezterm = require 'wezterm'

return {
    color_scheme = 'Nord',

    font_size = 14.0,
    font = wezterm.font_with_fallback({
        'JetBrains Mono',
        'FiraCode Nerd Font',
        'Menlo',
        'monospace',
    }),

    window_background_opacity = 0.94,
    macos_window_background_blur = 10,
    window_decorations = 'RESIZE',
    window_padding = { left = 8, right = 8, top = 4, bottom = 4 },

    enable_tab_bar = true,
    hide_tab_bar_if_only_one_tab = true,
    use_fancy_tab_bar = true,
    tab_max_width = 32,

    colors = {
        tab_bar = {
            background = '#3B4252',
            active_tab = {
                bg_color = '#434C5E',
                fg_color = '#ECEFF4',
            },
            inactive_tab = {
                bg_color = '#3B4252',
                fg_color = '#D8DEE9',
            },
            inactive_tab_hover = {
                bg_color = '#434C5E',
                fg_color = '#E5E9F0',
            },
            new_tab = {
                bg_color = '#434C5E',
                fg_color = '#D8DEE9',
            },
        },
    },
}
