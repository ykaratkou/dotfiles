-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices
-- config.font = wezterm.font('CodeNewRoman Nerd Font Propo')
-- config.font = wezterm.font("Monaco")
config.font_size = 14
config.freetype_load_target = "Normal"
config.line_height = 1.05
config.status_update_interval = 10000

config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.tab_max_width = 100
config.enable_scroll_bar = true

-- For example, changing the color scheme:
config.color_scheme = 'Dracula (Official)'
config.colors = {
  ansi = {
    "#21222C",
    "#FF5555",
    "#50FA7B",
    "#F1FA8C",
    "#8BE9FD",
    "#FF79C6",
    "#BD93F9",
    "#F8F8F2",
  },
  brights = {
    "#6272A4",
    "#FF6E6E",
    "#69FF94",
    "#FFFFA5",
    "#A4FFFF",
    "#FF92DF",
    "#D6ACFF",
    "#FFFFFF",
  },
}

-- Slightly transparent and blurred background
-- config.window_background_opacity = 0.90
-- config.macos_window_background_blur = 30

config.window_frame = {
  font = wezterm.font({ family = 'CodeNewRoman Nerd Font' }),
  font_size = 14.0
}

config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}

--
-- Key bindings
--
config.keys = {
  {
    key = 'r',
    mods = 'CMD|SHIFT',
    action = wezterm.action.ReloadConfiguration,
  },
  {
    key = 'p',
    mods = 'CMD|SHIFT',
    action = wezterm.action.ActivateCommandPalette,
  },

  --
  -- Splitting panes
  --
  {
    key = 'd',
    mods = 'CMD',
    action = wezterm.action{ SplitHorizontal={ domain="CurrentPaneDomain" } },
  },
  {
    key = 'd',
    mods = 'CMD|SHIFT',
    action = wezterm.action{ SplitVertical={ domain="CurrentPaneDomain" } },
  },
  {
    key = 'Return',
    mods = 'CMD',
    action = wezterm.action.TogglePaneZoomState,
  },

  --
  -- Moving between panes
  --
  {
    key = 'h',
    mods = 'CMD',
    action = wezterm.action{ ActivatePaneDirection="Left" },
  },
  {
    key = 'l',
    mods = 'CMD',
    action = wezterm.action{ ActivatePaneDirection="Right" },
  },
  {
    key = 'k',
    mods = 'CMD',
    action = wezterm.action{ ActivatePaneDirection="Up" },
  },
  {
    key = 'j',
    mods = 'CMD',
    action = wezterm.action{ ActivatePaneDirection="Down" },
  },

  --
  -- Resizing panes
  --
  {
    key = 'h',
    mods = 'CMD|SHIFT',
    action = wezterm.action{ AdjustPaneSize={"Left", 5} },
  },
  {
    key = 'l',
    mods = 'CMD|SHIFT',
    action = wezterm.action{ AdjustPaneSize={"Right", 5} },
  },
  {
    key = 'k',
    mods = 'CMD|SHIFT',
    action = wezterm.action{ AdjustPaneSize={"Up", 5} },
  },
  {
    key = 'j',
    mods = 'CMD|SHIFT',
    action = wezterm.action{ AdjustPaneSize={"Down", 5} },
  },

  --
  -- Workspaces
  --
  -- Create a new workspace with a given name and switch to it
  {
    key = 'i',
    mods = 'CMD',
    action = wezterm.action.PromptInputLine({
      description = "Enter name for new workspace",
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					window:perform_action(wezterm.action.SwitchToWorkspace({ name = line }), pane)
				end
			end),
		}),
  },
  -- Show the launcher in fuzzy selection mode and have it list all workspaces
  -- and allow activating one.
  {
    key = 'p',
    mods = 'CMD',
    action = wezterm.action.ShowLauncherArgs {
      flags = 'FUZZY|WORKSPACES',
    },
  },
}

local function is_dark()
  if wezterm.gui then
    return wezterm.gui.get_appearance():find("Dark")
  end
  return true
end

local function execute(command)
  local handle = io.popen(command)

  if not handle then
    return ""
  end

  local result = handle:read("*a"):gsub('\n', '') -- Remove newline
  handle:close()
  return result
end

local function git_branch(pane)
  local file_path = pane:get_current_working_dir()

  -- local success, stdout, stderr = wezterm.run_child_process { "git", "-C", file_path, "branch", "--show-current", "2" }
  local success, result, _ = wezterm.run_child_process { "sh", "-c", "echo 'hello'" }
  -- wezterm.sleep_ms(1000)
  -- return execute("git -C " .. file_path .. " branch --show-current 2>/dev/null")
  -- return "abc"
  --
  -- return type(stdout)

  if not success then
    wezterm.log_error("Error running subprocess: " .. result)
  else
    wezterm.log_info("Subprocess output: " .. result)
  end

  return result
end

local function segments_for_right_status(window, pane)
  local segments = {}

  local success, result, _ = wezterm.run_child_process { "sh", "-c", "echo 'hello'" }
  table.insert(segments, result)

  table.insert(segments, wezterm.strftime('%a %b %-d %H:%M'))
  table.insert(segments, window:active_workspace())

  return segments
end

-- wezterm.on('update-status', function(window, pane)
--   local segments = segments_for_right_status(window, pane)
--
--   local color_scheme = window:effective_config().resolved_palette
--   -- Note the use of wezterm.color.parse here, this returns
--   -- a Color object, which comes with functionality for lightening
--   -- or darkening the colour (amongst other things).
--   local bg = wezterm.color.parse(color_scheme.background)
--   local fg = color_scheme.foreground
--
--   -- Each powerline segment is going to be coloured progressively
--   -- darker/lighter depending on whether we're on a dark/light colour
--   -- scheme. Let's establish the "from" and "to" bounds of our gradient.
--   local gradient_to, gradient_from = bg
--   if is_dark() then
--     gradient_from = gradient_to:lighten(0.2)
--   else
--     gradient_from = gradient_to:darken(0.2)
--   end
--
--   -- Yes, WezTerm supports creating gradients, because why not?! Although
--   -- they'd usually be used for setting high fidelity gradients on your terminal's
--   -- background, we'll use them here to give us a sample of the powerline segment
--   -- colours we need.
--   local gradient = wezterm.color.gradient(
--     {
--       orientation = 'Horizontal',
--       colors = { gradient_from, gradient_to },
--     },
--     #segments -- only gives us as many colours as we have segments.
--   )
--
--   -- We'll build up the elements to send to wezterm.format in this table.
--   local elements = {}
--
--   for i, seg in ipairs(segments) do
--     local is_first = i == 1
--
--     if is_first then
--       table.insert(elements, { Background = { Color = 'none' } })
--     end
--     table.insert(elements, { Foreground = { Color = gradient[i] } })
--     table.insert(elements, { Foreground = { Color = fg } })
--     table.insert(elements, { Background = { Color = gradient[i] } })
--     table.insert(elements, { Text = ' ' .. seg .. ' ' })
--   end
--   window:set_right_status(wezterm.format(elements))
-- end)


local function right_status_test()
  local date = wezterm.strftime("%a %b %-d %_I:%M:%S");
  local _, result, _ = wezterm.run_child_process { "echo", "hello" }

  return result .. " | " .. date
end

wezterm.on("update-status", function(window)
  window:set_right_status(wezterm.format({
    -- {Text= result .. " | " .. date},
    -- {Text= date .. " | " .. result},
    {Text= right_status_test()},
  }));
end)

-- and finally, return the configuration to wezterm
return config
