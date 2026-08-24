vim.opt.runtimepath:append(vim.fn.getcwd())
vim.opt.runtimepath:append(vim.fn.expand('~/.local/share/nvim/lazy/plenary.nvim'))
vim.cmd('runtime plugin/plenary.vim')
