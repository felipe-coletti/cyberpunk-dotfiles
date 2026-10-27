-- cyberpunk: monochrome neon colorscheme from cyberpunk-dotfiles
--
-- The neon is the color picked on the color wheel (~/.config/neon/color);
-- code is told apart by brightness and style, and the accent colors are
-- only used where color means something (errors, warnings, diffs)

local function read_neon()
    local file = io.open(vim.fn.expand("~/.config/neon/color"))
    if not file then
        return "ffffff"
    end
    local hex = file:read("*l") or ""
    file:close()
    return hex:match("^%x%x%x%x%x%x$") and hex:lower() or "ffffff"
end

-- The neon at a given brightness (0–100), mixed with the black background
local neon = read_neon()
local function shade(percent)
    local channels = {}
    for i = 1, 5, 2 do
        local value = tonumber(neon:sub(i, i + 1), 16)
        table.insert(channels, string.format("%02x", math.floor(value * percent / 100)))
    end
    return "#" .. table.concat(channels)
end

local c = {
    bg      = "#000000",
    neon    = shade(100),
    text    = shade(85),
    dim     = shade(60),
    faint   = shade(40),
    line    = shade(25),
    surface = shade(12),

    -- Same accents as the foot terminal
    red     = "#ff2a6d",
    green   = "#05ffa1",
    yellow  = "#ffd300",
    blue    = "#3d8bff",
    magenta = "#b026ff",
    cyan    = "#00e5ff",
}

vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then
    vim.cmd("syntax reset")
end
vim.o.termguicolors = true
vim.o.background = "dark"
vim.g.colors_name = "cyberpunk"

local groups = {
    -- Editor
    Normal       = { fg = c.text, bg = c.bg },
    NormalNC     = { fg = c.text, bg = c.bg },
    NormalFloat  = { fg = c.text, bg = c.bg },
    FloatBorder  = { fg = c.neon, bg = c.bg },
    FloatTitle   = { fg = c.neon, bg = c.bg, bold = true },
    Cursor       = { fg = c.bg, bg = c.neon },
    CursorLine   = { bg = c.surface },
    CursorColumn = { bg = c.surface },
    ColorColumn  = { bg = c.surface },
    LineNr       = { fg = c.line },
    CursorLineNr = { fg = c.neon, bold = true },
    SignColumn   = { bg = c.bg },
    FoldColumn   = { fg = c.line, bg = c.bg },
    Folded       = { fg = c.dim, bg = c.surface, italic = true },
    WinSeparator = { fg = c.line },
    VertSplit    = { fg = c.line },
    NonText      = { fg = c.line },
    Whitespace   = { fg = c.line },
    EndOfBuffer  = { fg = c.bg },
    Visual       = { bg = c.line },
    Search       = { fg = c.bg, bg = c.dim },
    IncSearch    = { fg = c.bg, bg = c.neon },
    CurSearch    = { fg = c.bg, bg = c.neon },
    MatchParen   = { fg = c.neon, bold = true, underline = true },
    Directory    = { fg = c.neon, bold = true },
    Title        = { fg = c.neon, bold = true },
    Conceal      = { fg = c.faint },

    -- Menus and bars
    Pmenu        = { fg = c.text, bg = c.surface },
    PmenuSel     = { fg = c.bg, bg = c.neon, bold = true },
    PmenuSbar    = { bg = c.surface },
    PmenuThumb   = { bg = c.neon },
    StatusLine   = { fg = c.neon, bg = c.surface },
    StatusLineNC = { fg = c.faint, bg = c.bg },
    TabLine      = { fg = c.faint, bg = c.bg },
    TabLineFill  = { bg = c.bg },
    TabLineSel   = { fg = c.bg, bg = c.neon, bold = true },
    WildMenu     = { fg = c.bg, bg = c.neon },

    -- Messages
    ModeMsg      = { fg = c.neon, bold = true },
    MoreMsg      = { fg = c.neon },
    Question     = { fg = c.neon },
    ErrorMsg     = { fg = c.red, bold = true },
    WarningMsg   = { fg = c.yellow },

    -- Code: brightness and style instead of colors
    Comment      = { fg = c.faint, italic = true },
    Constant     = { fg = c.neon },
    String       = { fg = c.dim },
    Character    = { fg = c.dim },
    Number       = { fg = c.neon },
    Boolean      = { fg = c.neon, bold = true },
    Float        = { fg = c.neon },
    Identifier   = { fg = c.text },
    Function     = { fg = c.neon, bold = true },
    Statement    = { fg = c.neon, bold = true },
    Keyword      = { fg = c.neon, bold = true },
    Conditional  = { fg = c.neon, bold = true },
    Repeat       = { fg = c.neon, bold = true },
    Operator     = { fg = c.dim },
    Exception    = { fg = c.neon, bold = true },
    PreProc      = { fg = c.dim, italic = true },
    Type         = { fg = c.neon, italic = true },
    Special      = { fg = c.neon },
    Delimiter    = { fg = c.faint },
    Underlined   = { fg = c.neon, underline = true },
    Error        = { fg = c.red },
    Todo         = { fg = c.bg, bg = c.neon, bold = true },

    -- Diagnostics and spelling
    DiagnosticError            = { fg = c.red },
    DiagnosticWarn             = { fg = c.yellow },
    DiagnosticInfo             = { fg = c.blue },
    DiagnosticHint             = { fg = c.cyan },
    DiagnosticOk               = { fg = c.green },
    DiagnosticUnderlineError   = { undercurl = true, sp = c.red },
    DiagnosticUnderlineWarn    = { undercurl = true, sp = c.yellow },
    DiagnosticUnderlineInfo    = { undercurl = true, sp = c.blue },
    DiagnosticUnderlineHint    = { undercurl = true, sp = c.cyan },
    SpellBad                   = { undercurl = true, sp = c.red },
    SpellCap                   = { undercurl = true, sp = c.yellow },
    SpellRare                  = { undercurl = true, sp = c.magenta },
    SpellLocal                 = { undercurl = true, sp = c.cyan },

    -- Diffs and git signs
    DiffAdd      = { fg = c.green },
    DiffChange   = { fg = c.yellow },
    DiffDelete   = { fg = c.red },
    DiffText     = { fg = c.bg, bg = c.yellow },
    Added        = { fg = c.green },
    Changed      = { fg = c.yellow },
    Removed      = { fg = c.red },
    GitSignsAdd    = { fg = c.green },
    GitSignsChange = { fg = c.yellow },
    GitSignsDelete = { fg = c.red },

    -- Tree-sitter groups that would otherwise look like plain text
    ["@variable"]        = { fg = c.text },
    ["@variable.builtin"] = { fg = c.neon, italic = true },
    ["@property"]        = { fg = c.text },
    ["@field"]           = { fg = c.text },
    ["@parameter"]       = { fg = c.text, italic = true },
    ["@punctuation"]     = { fg = c.faint },
    ["@tag"]             = { fg = c.neon, bold = true },
    ["@tag.attribute"]   = { fg = c.dim, italic = true },
    ["@markup.heading"]  = { fg = c.neon, bold = true },
    ["@text.title"]      = { fg = c.neon, bold = true },
    ["@markup.link"]     = { fg = c.neon, underline = true },
    ["@text.uri"]        = { fg = c.neon, underline = true },
}

for name, spec in pairs(groups) do
    vim.api.nvim_set_hl(0, name, spec)
end

-- Neovim's own terminal uses the same 16 colors as foot
local terminal = {
    "#000000", c.red, c.green, c.yellow, c.blue, c.magenta, c.cyan, shade(75),
    c.faint,   c.red, c.green, c.yellow, c.blue, c.magenta, c.cyan, c.neon,
}
for i, color in ipairs(terminal) do
    vim.g["terminal_color_" .. (i - 1)] = color
end