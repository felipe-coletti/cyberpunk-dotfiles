-- Ignora pedidos de maximizar (evita janelas "travadas" em fullscreen)
hl.window_rule({
    name           = "suppress-maximize",
    match          = { class = ".*" },
    suppress_event = "maximize",
})

-- Corrige problemas de drag com XWayland
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

-- Roda de cores do neon aparece flutuante
hl.window_rule({
    name  = "neon-picker-float",
    match = { class = "neon-picker" },
    float = true,
})

-- hyprland-run (menu de confirmação) aparece flutuante e centralizado
hl.window_rule({
    name  = "hyprland-run-position",
    match = { class = "hyprland-run" },
    move  = "20 monitor_h-120",
    float = true,
})