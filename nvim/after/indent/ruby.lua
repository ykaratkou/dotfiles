-- The stock ruby indent script puts `.` in 'indentkeys' (for leading-dot method
-- chains). Since indenting is done by treesitter, typing `.` at the end of an
-- incomplete expression makes the parser fail and the line loses its indent.
vim.bo.indentkeys = vim.bo.indentkeys:gsub(',%.,', ','):gsub(',%.$', '')
