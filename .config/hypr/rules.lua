-- Ignore maximize requests (avoids windows "stuck" in fullscreen)
hl.window_rule({
    name           = "suppress-maximize",
    match          = { class = ".*" },
    suppress_event = "maximize",
})

-- Fix drag issues with XWayland
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

-- The neon color wheel opens floating
hl.window_rule({
    name  = "neon-picker-float",
    match = { class = "neon-picker" },
    float = true,
})

-- hyprland-run (confirmation menu) opens floating and centered
hl.window_rule({
    name  = "hyprland-run-position",
    match = { class = "hyprland-run" },
    move  = "20 monitor_h-120",
    float = true,
})