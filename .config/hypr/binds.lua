local mod = "SUPER"

-- ─── Programas ──────────────────────────────────────────────
hl.bind(mod .. " + Return",    hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + D",         hl.dsp.exec_cmd(menu))
hl.bind(mod .. " + E",         hl.dsp.exec_cmd(fileManager))
hl.bind(mod .. " + N",         hl.dsp.exec_cmd(home .. "/.config/neon/pick.sh"))   -- cor do neon

-- ─── Janelas ────────────────────────────────────────────────
hl.bind(mod .. " + Q", function()
    local w = hl.get_active_window()
    if w then
        hl.dispatch(hl.dsp.window.close())
    else
        hl.exec_cmd(home .. "/.config/wofi/scripts/powermenu.sh")
    end
end)
hl.bind(mod .. " + V",         hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + P",         hl.dsp.window.pseudo())
hl.bind(mod .. " + J",         hl.dsp.layout("togglesplit"))   -- dwindle only

-- ─── Foco ───────────────────────────────────────────────────
hl.bind(mod .. " + left",      hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + right",     hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + up",        hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + down",      hl.dsp.focus({ direction = "down" }))

-- ─── Workspaces ─────────────────────────────────────────────
for i = 1, 10 do
    local key = i % 10  -- 10 → "0"
    hl.bind(mod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Workspace especial (scratchpad)
hl.bind(mod .. " + TAB",                hl.dsp.workspace.toggle_special("magic"))
hl.bind(mod .. " + SHIFT + TAB",        hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll no mouse = trocar workspace
hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- ─── Mouse: mover / redimensionar ───────────────────────────
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- ─── Sessão ─────────────────────────────────────────────────
hl.bind(mod .. " + L",         hl.dsp.exec_cmd("hyprlock"))

-- Salva na pasta de imagens do idioma do sistema (Imagens, Pictures…)
local screenshot = '"$(xdg-user-dir PICTURES)/screenshot-$(date +%Y%m%d-%H%M%S).png"'
hl.bind(mod .. " + PRINT",           hl.dsp.exec_cmd("grim " .. screenshot))
hl.bind(mod .. " + SHIFT + PRINT",   hl.dsp.exec_cmd("slurp | grim -g - " .. screenshot))

-- ─── Mídia e brilho ─────────────────────────────────────────
local locked = { locked = true, repeating = true }

hl.bind("XF86AudioRaiseVolume",   hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), locked)
hl.bind("XF86AudioLowerVolume",   hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      locked)
hl.bind("XF86AudioMute",          hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     locked)
hl.bind("XF86AudioMicMute",       hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   locked)
hl.bind("XF86MonBrightnessUp",    hl.dsp.exec_cmd("brightnessctl set 5%+"),                          locked)
hl.bind("XF86MonBrightnessDown",  hl.dsp.exec_cmd("brightnessctl set 5%-"),                          locked)

-- Playerctl (requer `playerctl` instalado)
local lockedNoRepeat = { locked = true }
hl.bind("XF86AudioNext",      hl.dsp.exec_cmd("playerctl next"),       lockedNoRepeat)
hl.bind("XF86AudioPrev",      hl.dsp.exec_cmd("playerctl previous"),   lockedNoRepeat)
hl.bind("XF86AudioPlay",      hl.dsp.exec_cmd("playerctl play-pause"), lockedNoRepeat)
hl.bind("XF86AudioPause",     hl.dsp.exec_cmd("playerctl play-pause"), lockedNoRepeat)