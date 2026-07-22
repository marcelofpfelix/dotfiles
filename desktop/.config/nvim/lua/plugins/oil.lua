return {
  {
    "stevearc/oil.nvim",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
      { "<leader>fo", "<cmd>Oil<cr>", desc = "Open Oil" },
      { "<leader>fO", "<cmd>Oil .<cr>", desc = "Open Oil at cwd" },
    },
    opts = {
      default_file_explorer = true,
      columns = { "icon" },
      delete_to_trash = true,
      skip_confirm_for_simple_edits = false,
      watch_for_changes = true,
      lsp_file_methods = {
        enabled = true,
        timeout_ms = 1000,
        autosave_changes = "unmodified",
      },
      view_options = {
        show_hidden = true,
        natural_order = "fast",
        sort = {
          { "type", "asc" },
          { "name", "asc" },
        },
        is_always_hidden = function(name)
          return name == ".DS_Store"
        end,
      },
      win_options = {
        wrap = false,
        signcolumn = "no",
        spell = false,
        list = false,
        conceallevel = 3,
      },
    },
  },
}
