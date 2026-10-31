-- ─── Paths ───────────────────────────────────────────────────
home = os.getenv("HOME")

-- ─── Programs ────────────────────────────────────────────────
terminal    = "kitty"
fileManager = "thunar"
fileManagerTui = terminal .. " -e yazi"
menu        = home .. "/.config/wofi/scripts/launcher.sh"

-- ─── Environment variables ──────────────────────────────────
hl.env("XCURSOR_SIZE",    "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Native Wayland when possible (avoids blurry apps through XWayland)
hl.env("GDK_BACKEND",                  "wayland,x11,*")
hl.env("QT_QPA_PLATFORM",              "wayland;xcb")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-- ─── Layouts ────────────────────────────────────────────────
hl.config({ dwindle  = { preserve_split = true } })
hl.config({ master   = { new_status = "master" } })
hl.config({ scrolling = { fullscreen_on_one_column = true } })
