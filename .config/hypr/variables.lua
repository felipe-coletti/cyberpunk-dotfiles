-- ─── Caminhos ────────────────────────────────────────────────
home = os.getenv("HOME")

-- ─── Programas ───────────────────────────────────────────────
terminal    = "foot"
fileManager = "thunar"
menu        = "wofi --show drun"

-- ─── Variáveis de ambiente ──────────────────────────────────
hl.env("XCURSOR_SIZE",    "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Wayland nativo quando possível (evita apps pixelados via XWayland)
hl.env("GDK_BACKEND",                  "wayland,x11,*")
hl.env("QT_QPA_PLATFORM",              "wayland;xcb")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-- ─── Layouts ────────────────────────────────────────────────
hl.config({ dwindle  = { preserve_split = true } })
hl.config({ master   = { new_status = "master" } })
hl.config({ scrolling = { fullscreen_on_one_column = true } })
