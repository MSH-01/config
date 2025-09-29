-- Clear existing highlights
vim.cmd('highlight clear')
if vim.fn.exists('syntax_on') then
  vim.cmd('syntax reset')
end

vim.g.colors_name = 'mytheme'

-- Define your colors
local colors = {
  bg = '#1a1a1a',
  fg = '#e0e0e0',
  red = '#ff6b6b',
  green = '#51cf66',
  yellow = '#ffd93d',
  blue = '#4dabf7',
  purple = '#b197fc',
  cyan = '#22b8cf',
  orange = '#ff922b',
  gray = '#6c757d',
}

-- Helper function to set highlights
local function hi(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

-- Editor colors
hi('Normal', { fg = colors.fg, bg = colors.bg })
hi('LineNr', { fg = colors.gray })
hi('CursorLine', { bg = '#252525' })
hi('CursorLineNr', { fg = colors.yellow, bold = true })
hi('Visual', { bg = '#2d3748' })
hi('Search', { bg = colors.yellow, fg = colors.bg })
hi('IncSearch', { bg = colors.orange, fg = colors.bg })

-- Syntax highlighting
hi('Comment', { fg = colors.gray, italic = true })
hi('Constant', { fg = colors.orange })
hi('String', { fg = colors.green })
hi('Number', { fg = colors.orange })
hi('Boolean', { fg = colors.orange })
hi('Identifier', { fg = colors.blue })
hi('Function', { fg = colors.yellow })
hi('Statement', { fg = colors.purple })
hi('Keyword', { fg = colors.purple, bold = true })
hi('Type', { fg = colors.cyan })
hi('Special', { fg = colors.red })
hi('Operator', { fg = colors.fg })

-- Treesitter highlights (for better syntax)
hi('@variable', { fg = colors.fg })
hi('@property', { fg = colors.blue })
hi('@function', { fg = colors.yellow })
hi('@keyword', { fg = colors.purple })
hi('@string', { fg = colors.green })
hi('@number', { fg = colors.orange })
hi('@comment', { fg = colors.gray, italic = true })
hi('@type', { fg = colors.cyan })
hi('@constant', { fg = colors.orange })

-- LSP highlights
hi('DiagnosticError', { fg = colors.red })
hi('DiagnosticWarn', { fg = colors.yellow })
hi('DiagnosticInfo', { fg = colors.blue })
hi('DiagnosticHint', { fg = colors.cyan })

-- Git signs
hi('GitSignsAdd', { fg = colors.green })
hi('GitSignsChange', { fg = colors.yellow })
hi('GitSignsDelete', { fg = colors.red })
