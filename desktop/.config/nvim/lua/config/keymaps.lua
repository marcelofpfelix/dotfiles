vim.api.nvim_set_keymap("i", "jj", "<Esc>", {noremap=false})
-- buffers
vim.api.nvim_set_keymap("n", "tk", ":blast<enter>", {noremap=false})
vim.api.nvim_set_keymap("n", "tj", ":bfirst<enter>", {noremap=false})
vim.api.nvim_set_keymap("n", "th", ":bprev<enter>", {noremap=false})
vim.api.nvim_set_keymap("n", "tl", ":bnext<enter>", {noremap=false})
vim.api.nvim_set_keymap("n", "td", ":bdelete<enter>", {noremap=false})
-- files
vim.api.nvim_set_keymap("n", "QQ", ":q!<enter>", {noremap=false})
vim.api.nvim_set_keymap("n", "TT", ":TransparentToggle<CR>", {noremap=true})
vim.api.nvim_set_keymap("n", "ss", ":noh<CR>", {noremap=true})
-- splits
vim.api.nvim_set_keymap("n", "<C-W>,", ":vertical resize -10<CR>", {noremap=true})
vim.api.nvim_set_keymap("n", "<C-W>.", ":vertical resize +10<CR>", {noremap=true})
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
-- Quicker close split
vim.keymap.set("n", "<leader>qq", ":q<CR>",
  {silent = true, noremap = true}
)
-- Keymaps for better default experience
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })


vim.keymap.set("n", "<leader>ee", "<cmd>GoIfErr<cr>",
  {silent = true, noremap = true}
)

-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- better indenting
vim.keymap.set("v", "<", "<gv")                                              -- reselect visual after shift-left
vim.keymap.set("v", ">", ">gv")                                              -- reselect visual after shift-right

-- save file
vim.keymap.set({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save File" })

vim.keymap.set("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All" })      -- quit all

-- Terminal Mappings
vim.keymap.set("t", "<C-/>", "<cmd>close<cr>", { desc = "Hide Terminal" })   -- close terminal with Ctrl-/
vim.keymap.set("t", "<C-_>", "<cmd>close<cr>", { desc = "which_key_ignore" })-- alt form of Ctrl-/

-- windows
vim.keymap.set("n", "<leader>-", "<C-W>s", { desc = "Split Window Below", remap = true })
vim.keymap.set("n", "<leader>|", "<C-W>v", { desc = "Split Window Right", remap = true })
vim.keymap.set("n", "<leader>wd", "<C-W>c", { desc = "Delete Window", remap = true })

-- tabs
vim.keymap.set("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last Tab" })
vim.keymap.set("n", "<leader><tab>o", "<cmd>tabonly<cr>", { desc = "Close Other Tabs" })
vim.keymap.set("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First Tab" })
vim.keymap.set("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
vim.keymap.set("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next Tab" })
vim.keymap.set("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })
vim.keymap.set("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })

-- twilight
vim.api.nvim_set_keymap("n", "tw", ":Twilight<enter>", {noremap=false})
-- Noice
vim.api.nvim_set_keymap("n", "<leader>nn", ":Noice dismiss<CR>", {noremap=true})
