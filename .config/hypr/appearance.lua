-- ─── Look & Feel ────────────────────────────────────────────
hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 20,
        border_size = 1,

        col = {
            active_border   = "rgb(" .. neon .. ")",
            inactive_border = "rgba(" .. neon .. "99)",
        },

        resize_on_border = false,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding       = 0,
        rounding_power = 2,

        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            -- Neon glow around the active window
            range          = 8,
            render_power   = 3,
            color          = tonumber("99" .. neon, 16),
            color_inactive = 0x00000000,
        },

        blur = {
            enabled  = true,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },

    -- No default wallpaper or logo: the theme's pure black background
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
        background_color        = 0xff000000,
    },
})