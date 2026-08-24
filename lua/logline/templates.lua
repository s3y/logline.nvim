local M = {}

M.defaults = {
  javascript = { log = 'console.log(%s)', info = 'console.info(%s)', error = 'console.error(%s)' },
  typescript = { log = 'console.log(%s)', info = 'console.info(%s)', error = 'console.error(%s)' },
  javascriptreact = { log = 'console.log(%s)', info = 'console.info(%s)', error = 'console.error(%s)' },
  typescriptreact = { log = 'console.log(%s)', info = 'console.info(%s)', error = 'console.error(%s)' },
  vue = { log = 'console.log(%s)', info = 'console.info(%s)', error = 'console.error(%s)' },
  lua = { log = 'vim.print(%s)', info = 'vim.print(%s)', error = 'vim.notify(%s, vim.log.levels.ERROR)' },
  php = { log = 'error_log(%s)', info = 'error_log(%s)', error = 'error_log(%s)' },
  python = { log = 'print(%s)', info = 'print(%s)', error = 'print(%s)' },
  go = { log = 'fmt.Printf("%%v\\n", %s)', info = 'fmt.Printf("%%v\\n", %s)', error = 'fmt.Printf("%%v\\n", %s)' },
  ruby = { log = 'puts(%s)', info = 'puts(%s)', error = 'warn(%s)' },
  sh = { log = 'echo %s', info = 'echo %s', error = 'echo %s >&2' },
}

---@param filetype string
---@param overrides table|nil
---@return table|nil
function M.for_filetype(filetype, overrides)
  local merged = vim.tbl_deep_extend('force', {}, M.defaults, overrides or {})
  return merged[filetype]
end

return M
