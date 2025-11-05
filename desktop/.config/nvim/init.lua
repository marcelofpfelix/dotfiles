local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('config.keymaps')
require('config.options')
require('config.autocmds')
require('pluginss.lazy')

require('pluginss.misc')
require('pluginss.lualine')
require('pluginss.dap')
require('pluginss.gitsigns')
require('pluginss.tele')
require('pluginss.treesitter')
require('pluginss.lsp')
require('pluginss.trouble')
require('pluginss.obsidian')
require('pluginss.zenmode')
require('pluginss.neogit')
require('pluginss.codesnap')
require('pluginss.harpoon')

