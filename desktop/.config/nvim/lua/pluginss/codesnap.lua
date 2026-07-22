
local ok, codesnap = pcall(require, "codesnap")
if not ok then
  return
end

codesnap.setup({
  border = "rounded",
  has_breadcrumbs = true,
  bg_theme = "grape",
  watermark = ""
})
