hl.config({
    input = {
        -- ABNT2 keyboard (Brazil)
        kb_layout  = "br",
        kb_variant = "abnt2",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        -- Focus follows the mouse (1 = follows the cursor)
        follow_mouse = 1,

        -- Mouse sensitivity: -1.0 to 1.0 (0 = default)
        sensitivity = 0,

        touchpad = {
            natural_scroll = false,
        },
    },
})

-- ThinkPad built-in keyboard
hl.device({
    name = "at-translated-set-2-keyboard",
    kb_layout = "br",
    kb_variant = "thinkpad",
})

-- Gestures: 3-finger horizontal swipe = switch workspace
hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})