vim.api.nvim_create_user_command('SwitchCase',
  function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    local word = vim.fn.expand('<cword>')
    local word_start = vim.fn.matchstrpos(vim.fn.getline('.'), '\\k*\\%' .. (col+1) .. 'c\\k*')[2]

    local function to_snake_case(str)
      return str:gsub('([a-z])([A-Z])', '%1_%2'):lower()
    end

    local function to_camel_case(str)
      return str:gsub('_([a-z])', function(match) return match:upper() end):gsub('^%l', string.upper):gsub('^%u', string.lower)
    end

    local function to_pascal_case(str)
      return str:gsub('_([a-z])', function(match) return match:upper() end):gsub('^%l', string.upper)
    end

    local function is_snake_case(str)
      return str:find('_') and str:lower() == str
    end

    local function is_camel_case(str)
      return str:find('[a-z][A-Z]') and not str:find('_') and str:sub(1, 1):lower() == str:sub(1, 1)
    end

    local function is_pascal_case(str)
      return str:find('[A-Z]') and not str:find('_') and str:sub(1, 1):upper() == str:sub(1, 1)
    end

    local new_word
    if is_snake_case(word) then
      new_word = to_camel_case(word)
    elseif is_camel_case(word) then
      new_word = to_pascal_case(word)
    elseif is_pascal_case(word) then
      new_word = to_snake_case(word)
    else
      new_word = to_snake_case(word)
    end

    vim.api.nvim_buf_set_text(0, line - 1, word_start, line - 1, word_start + #word, {new_word})
  end,
  { nargs = 0 }
)
