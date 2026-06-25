local zen_columns = {}

local function hide_columns(win)
  zen_columns[win] = {
    number = vim.wo[win].number,
    relativenumber = vim.wo[win].relativenumber,
    signcolumn = vim.wo[win].signcolumn,
  }

  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = "no"
end

require("zen-mode").setup({
  window = {
    backdrop = 0.95,
    width = 120, -- width of the Zen window
    height = 1, -- height of the Zen window
    options = {
      signcolumn = "no", -- disable signcolumn
      number = false, -- disable number column
      relativenumber = false, -- disable relative numbers
      -- cursorline = false, -- disable cursorline
      -- cursorcolumn = false, -- disable cursor column
      -- foldcolumn = "0", -- disable fold column
      -- list = false, -- disable whitespace characters
    },
  },
  plugins = {
    -- disable some global vim options (vim.o...)
    options = {
      enabled = true,
      ruler = true, -- disables the ruler text in the cmd line area
      showcmd = false, -- disables the command in the last line of the screen
      -- you may turn on/off statusline in zen mode by setting 'laststatus'
      -- statusline will be shown only if 'laststatus' == 3
      laststatus = 0, -- turn off the statusline in zen mode
    },
    twilight = { enabled = false }, -- enable to start Twilight when zen mode opens
    gitsigns = { enabled = true }, -- disable git signs while Zen Mode is active
    tmux = { enabled = true }, -- disables the tmux statusline
    wezterm = {
      enabled = true,
      font = "+20", -- (10% increase per step)
    },
  },
  on_open = function(win)
    zen_columns = {}
    for _, visible_win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      hide_columns(visible_win)
    end
    hide_columns(win)
  end,
  on_close = function()
    for win, opts in pairs(zen_columns) do
      if vim.api.nvim_win_is_valid(win) then
        vim.wo[win].number = opts.number
        vim.wo[win].relativenumber = opts.relativenumber
        vim.wo[win].signcolumn = opts.signcolumn
      end
    end
    zen_columns = {}
  end,
})
