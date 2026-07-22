-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

local kamailio_filetype_group = vim.api.nvim_create_augroup('KamailioFiletype', { clear = true })
vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufNewFile' }, {
  callback = function(args)
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(args.buf) then
        return
      end

      local first_line = vim.api.nvim_buf_get_lines(args.buf, 0, 1, false)[1] or ''
      if first_line:match('^#!%s*KAMAILIO%s*$') then
        vim.bo[args.buf].filetype = 'kamailio'
      end
    end)
  end,
  group = kamailio_filetype_group,
  pattern = '*',
})
