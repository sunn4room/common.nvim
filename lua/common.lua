local opts_fallback = {
  options = {},
  globals = {},
  mappings = {},
  commands = {},
  autocmds = {},
  colors = {
    "Black",
    "DarkRed",
    "DarkGreen",
    "DarkYellow",
    "DarkBlue",
    "DarkMagenta",
    "DarkCyan",
    "LightGray",
    "DarkGray",
    "Red",
    "Green",
    "Yellow",
    "Blue",
    "Magenta",
    "Cyan",
    "White",
  },
  highlights = {},
}

local M = {}

M.setup = function(opts)
  opts = vim.tbl_deep_extend("force", opts_fallback, opts or {})

  for key, value in pairs(opts.options) do
    while type(value) == "function" do
      value = value()
    end
    if value ~= nil then
      vim.opt[key] = value
    end
  end

  for key, value in pairs(opts.globals) do
    while type(value) == "function" do
      value = value()
    end
    if value ~= nil then
      vim.g[key] = value
    end
  end

  for mode, items in pairs(opts.mappings) do
    local mode_list = {}
    for m in string.gmatch(mode, ".") do
      table.insert(mode_list, m)
    end
    for key, value in pairs(items) do
      while type(value) == "function" do
        value = value()
      end
      if value ~= nil then
        local action = value.command or value.callback
        if action ~= nil then
          value.command = nil
          value.callback = nil
          vim.keymap.set(mode_list, key, action, vim.tbl_extend("force", {
            remap = false,
            nowait = true,
          }, value))
        end
      end
    end
  end

  for key, value in pairs(opts.commands) do
    while type(value) == "function" do
      value = value()
    end
    if value ~= nil then
      local action = value.command or value.callback
      if action ~= nil then
        value.command = nil
        value.callback = nil
        vim.api.nvim_create_user_command(key, action,
          vim.tbl_extend("force", {}, value))
      end
    end
  end

  for group, cmds in pairs(opts.autocmds) do
    while type(cmds) == "function" do
      cmds = cmds()
    end
    group = vim.api.nvim_create_augroup(group, { clear = true })
    for _, cmd in ipairs(cmds) do
      local event = cmd.event
      cmd.event = nil
      cmd.group = group
      vim.api.nvim_create_autocmd(event, cmd)
    end
  end

  for key, value in pairs(opts.highlights) do
    while type(value) == "function" do
      value = value()
    end
    if value ~= nil then
      if type(value) == "string" then
        value = { link = value }
      end
      if value.fg then
        value.ctermfg = value.fg
        value.fg = opts.colors[value.ctermfg + 1]
      end
      if value.bg then
        value.ctermbg = value.bg
        value.bg = opts.colors[value.ctermbg + 1]
      end
      vim.api.nvim_set_hl(0, key, value)
    end
  end
end

return M
