if vim.g.loaded_logline then return end
vim.g.loaded_logline = true

local subcommands = {
  delete = function() require('logline').delete() end,
  commenttoggle = function() require('logline').comment_toggle() end,
  search = function() require('logline').search() end,
  log = function() require('logline').log('log') end,
  info = function() require('logline').log('info') end,
  error = function() require('logline').log('error') end,
}

vim.api.nvim_create_user_command('Logline', function(opts)
  local name = opts.fargs[1]
  local action = subcommands[name]
  if not action then
    vim.notify(('logline: unknown subcommand %q'):format(name or ''), vim.log.levels.ERROR)
    return
  end
  action()
end, {
  nargs = 1,
  desc = 'Insert or manage logline debug statements',
  complete = function(lead)
    return vim.tbl_filter(function(name)
      return name:find(lead, 1, true) == 1
    end, vim.tbl_keys(subcommands))
  end,
})
