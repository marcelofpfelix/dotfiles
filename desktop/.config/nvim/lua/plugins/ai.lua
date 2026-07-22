local litellm_base_url = vim.env.AVANTE_LITELLM_BASE_URL
    or vim.env.LITELLM_BASE_URL
    or "http://litellm-aiswe.query.prod.telnyx.io:4000"
local litellm_endpoint = litellm_base_url:gsub("/+$", "")
if not litellm_endpoint:match("/v1$") then
  litellm_endpoint = litellm_endpoint .. "/v1"
end

local avante_provider = vim.env.AVANTE_PROVIDER
    or (vim.env.LITELLM_API_KEY and "litellm" or "claude")

return {
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false,
    build = vim.fn.has("win32") ~= 0
        and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
        or "make",
    opts = {
      provider = avante_provider,
      auto_suggestions_provider = avante_provider,
      providers = {
        litellm = {
          __inherited_from = "openai",
          api_key_name = "LITELLM_API_KEY",
          endpoint = litellm_endpoint,
          model = vim.env.AVANTE_MODEL or "aiswe/coding-model",
          timeout = 60000,
          max_tokens = 8192,
          disable_tools = false,
        },
      },
      behaviour = {
        auto_suggestions = false,
        auto_set_highlight_group = true,
        auto_set_keymaps = true,
        auto_apply_diff_after_generation = false,
        support_paste_from_clipboard = true,
      },
      selector = {
        provider = "telescope",
      },
      input = {
        provider = "native",
      },
      windows = {
        position = "right",
        width = 35,
        wrap = true,
      },
    },
    ---@module 'avante'
    ---@type avante.Config
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-telescope/telescope.nvim",
      "saghen/blink.cmp",
      "nvim-tree/nvim-web-devicons",
      {
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            use_absolute_path = true,
          },
        },
      },
    }
  }
}
