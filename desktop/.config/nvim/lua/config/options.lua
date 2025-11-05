vim.g.mapleader = " "                                   -- set <Space> as leader
vim.g.maplocalleader = " "                              -- set <Space> as localleader
vim.g.have_nerd_font = true                             -- enable Nerd Font glyphs
vim.opt.hlsearch = true                                 -- highlight search matches
vim.opt.number = true                                   -- show absolute line numbers
vim.opt.relativenumber = true                           -- show relative line numbers
vim.opt.mouse = "a"                                     -- enable mouse support (a = all modes)
vim.opt.breakindent = true                              -- wrapped lines keep indentation
vim.opt.undofile = true                                 -- persistent undo across sessions
vim.opt.ignorecase = true                               -- case-insensitive search by default
vim.opt.smartcase = true                                -- BUT become case-sensitive with capitals
vim.opt.signcolumn = "yes"                              -- always show sign column to avoid jump
vim.opt.clipboard = "unnamedplus"                       -- use system clipboard
vim.opt.timeoutlen = (vim.g.vscode and 1000) or 300     -- mapped sequence wait time (ms)
vim.opt.splitright = true                               -- vertical splits open to the right
vim.opt.splitbelow = true                               -- horizontal splits open below
vim.opt.list = true                                     -- render invisible characters
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" } -- glyphs for tab/trail/nbsp
vim.opt.cursorline = true                               -- highlight current line
vim.opt.scrolloff = 4                                   -- keep N context lines above/below cursor
vim.opt.confirm = true                                  -- prompt to save before actions like :q
vim.opt.completeopt = "menuone,noselect"                -- better completion behavior
vim.opt.conceallevel = 2                                -- hide markup (e.g., **bold**) where possible
vim.opt.expandtab = true                                -- insert spaces instead of tabs
vim.opt.tabstop = 2                                     -- visual width of a tab
vim.opt.shiftwidth = 2                                  -- indent width
vim.opt.softtabstop = 2                                 -- editing width of a tab
vim.opt.autowrite = true                                -- auto-write before running commands
vim.opt.showmode = false                                -- hide mode since statusline shows it
vim.opt.fillchars = {                                   -- UI glyphs for folds/diff/EOB
  foldopen = "", foldclose = "", fold = " ", foldsep = " ",
  diff = "╱", eob = " "
}
vim.opt.foldlevel = 99                                  -- open all folds by default
vim.opt.foldmethod = "indent"                           -- derive folds from indentation
vim.opt.foldtext = ""                                   -- use default/plugin fold text
vim.opt.formatoptions = "jcroqlnt"                      -- format behavior (join/comments/lists…)
vim.opt.grepformat = "%f:%l:%c:%m"                      -- quickfix format for grep results
vim.opt.grepprg = "rg --vimgrep"                        -- use ripgrep for :grep
vim.opt.inccommand = "nosplit"                          -- live preview of :substitute in place
vim.opt.jumpoptions = "view"                            -- keep view when jumping
vim.opt.laststatus = 3                                  -- global statusline
vim.opt.linebreak = true                                -- wrap at word boundaries
vim.opt.pumblend = 10                                   -- popup-menu transparency
vim.opt.pumheight = 10                                  -- max items in completion menu
vim.opt.ruler = false                                   -- disable default ruler
vim.opt.sessionoptions = {                              -- what to save in :mksession
  "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds"
}
vim.opt.shiftround = true                               -- round indents to shiftwidth
vim.opt.shortmess:append({ W = true, I = true, c = true, C = true }) -- reduce message noise
vim.opt.sidescrolloff = 8                               -- horizontal context columns
vim.opt.smartindent = true                              -- smarter auto-indenting
vim.opt.smoothscroll = true                             -- smooth scrolling
vim.opt.spelllang = { "en" }                            -- spelling language
vim.opt.splitkeep = "screen"                            -- stabilize splits on open/close
vim.opt.termguicolors = true                            -- enable truecolor
vim.opt.undolevels = 10000                              -- large undo history in-memory
vim.opt.updatetime = 200                                -- CursorHold/Swap write delay (ms)
vim.opt.virtualedit = "block"                           -- free-cursor in visual block mode
vim.opt.wildmode = "longest:full,full"                  -- command-line completion behavior
vim.opt.winminwidth = 5                                 -- minimum window width
vim.opt.wrap = false                                    -- no soft wrapping
-- vim.opt.swapfile = false
