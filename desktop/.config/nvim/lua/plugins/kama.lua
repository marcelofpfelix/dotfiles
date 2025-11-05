
return {

  -- 1. vim-kamailio-syntax
  { "kamailio/vim-kamailio-syntax",
    ft = "kamailio", lazy = true
  },

  -- 2. vim-kamailio-autocomplete
  {
    "kamailio/vim-kamailio-autocomplete",
    ft = "kamailio",  -- load only for Kamailio files
    config = function()
      -- Set the completion function when editing Kamailio files
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "kamailio",
        callback = function()
          vim.bo.completefunc = "KamailioComplete"
          -- optional: nicer popup behavior
          vim.opt_local.completeopt = "menuone,noinsert,noselect"
        end,
      })
    end,
    dependencies = { "kamailio/vim-kamailio-syntax" },
  },
}
