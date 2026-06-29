-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
-- nvim-treesitter master's Markdown injection directive still assumes the
-- pre-0.12 single-node capture shape. Neovim 0.12 passes captures as node
-- lists, which breaks fenced code blocks while rendering Markdown.
if vim.fn.has('nvim-0.12') == 1 then
  local query = require('vim.treesitter.query')
  local aliases = {
    ex = 'elixir',
    pl = 'perl',
    sh = 'bash',
    ts = 'typescript',
    uxn = 'uxntal',
  }

  pcall(require, 'nvim-treesitter.query_predicates')
  query.add_directive('set-lang-from-info-string!', function(match, _, bufnr, pred, metadata)
    local capture_id = pred[2]
    local nodes = match[capture_id]
    local node = type(nodes) == 'table' and nodes[1] or nodes
    if not node then
      return
    end

    local lang = vim.treesitter.get_node_text(node, bufnr):lower()
    metadata['injection.language'] = vim.filetype.match({ filename = 'a.' .. lang }) or aliases[lang] or lang
  end, { force = true, all = false })
end

require('nvim-treesitter.configs').setup {
  -- Add languages to be installed here that you want installed for treesitter
  ensure_installed = {
    'go', 'lua', 'python', 'rust', 'typescript', 'regex',
    'bash', 'markdown', 'markdown_inline', 'kdl', 'sql', 'terraform',
    'html', 'css', 'javascript', 'yaml', 'json', 'toml',
  },

  highlight = { enable = true },
  indent = { enable = true },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<c-space>',
      node_incremental = '<c-space>',
      scope_incremental = '<c-s>',
      node_decremental = '<c-backspace>',
    },
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
        ['ii'] = '@conditional.inner',
        ['ai'] = '@conditional.outer',
        ['il'] = '@loop.inner',
        ['al'] = '@loop.outer',
        ['at'] = '@comment.outer',
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        [']f'] = '@function.outer',
        [']]'] = '@class.outer',
      },
      goto_next_end = {
        [']F'] = '@function.outer',
        [']['] = '@class.outer',
      },
      goto_previous_start = {
        ['[f'] = '@function.outer',
        ['[['] = '@class.outer',
      },
      goto_previous_end = {
        ['[F'] = '@function.outer',
        ['[]'] = '@class.outer',
      },
    },
    swap = {
      enable = true,
      swap_next = {
        ['<leader>a'] = '@parameter.inner',
      },
      swap_previous = {
        ['<leader>A'] = '@parameter.inner',
      },
    },
  },
}
