require("obsidian").setup({
  ui = { enable = false },
  workspaces = {
    {
      name = "Notes",
      path = vim.fn.expand("~/git/marcelofpfelix/wiki"),
    },
  },
})
