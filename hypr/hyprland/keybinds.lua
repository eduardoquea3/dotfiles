--###################
--### KEYBINDINGS ###
--###################

local mainMod = "SUPER"
local home = os.getenv "HOME" or ""
local scripts = home .. "/.config/hypr/scripts"

local function group(name)
  return "[" .. name .. "]"
end

local function bind(keys, description, dispatcher, opts)
  opts = opts or {}
  opts.description = description
  hl.bind(keys, dispatcher, opts)
end

-- =============================================================================
-- Launcher
-- =============================================================================
bind(mainMod .. " + RETURN", group "Launcher" .. " open terminal", hl.dsp.exec_cmd "ghostty")
bind(mainMod .. " + E", group "Launcher" .. " open file manager", hl.dsp.exec_cmd "thunar")
bind(
  mainMod .. " + D",
  group "Launcher" .. " application launcher",
  hl.dsp.exec_cmd("pkill -x rofi || " .. scripts .. "/launcher")
)
-- bind(
--   mainMod .. " + D",
--   group "Launcher" .. " application launcher",
--   hl.dsp.exec_cmd "qs ipc --path $HOME/.config/quickshell call launcher toggle"
-- )
bind(mainMod .. " + V", group "Launcher" .. " clipboard history", hl.dsp.exec_cmd "qs ipc call clipboard toggle")
bind(mainMod .. " + slash", group "Launcher" .. " keybindings hint", hl.dsp.exec_cmd(scripts .. "/keybinds_hint.sh"))
bind(mainMod .. " + W", group "Launcher" .. " wallpaper picker", hl.dsp.exec_cmd "qs ipc call wallpaper toggle")

-- =============================================================================
-- Window Management
-- =============================================================================
bind(mainMod .. " + Q", group "Window Management" .. " close window", hl.dsp.window.close())
bind(
  mainMod .. " + F",
  group "Window Management" .. " toggle fullscreen",
  hl.dsp.window.fullscreen { action = "toggle" }
)
bind(mainMod .. " + T", group "Window Management" .. " toggle float", hl.dsp.window.float { action = "toggle" })
bind(
  mainMod .. " + M",
  group "Window Management" .. " logout menu",
  hl.dsp.exec_cmd("pkill -x wlogout || " .. scripts .. "/wlogout 2")
)

bind(mainMod .. " + h", group "Window Management|Move Focus" .. " focus left", hl.dsp.focus { direction = "l" })
bind(mainMod .. " + l", group "Window Management|Move Focus" .. " focus right", hl.dsp.focus { direction = "r" })
bind(mainMod .. " + k", group "Window Management|Move Focus" .. " focus up", hl.dsp.focus { direction = "u" })
bind(mainMod .. " + j", group "Window Management|Move Focus" .. " focus down", hl.dsp.focus { direction = "d" })

bind(
  mainMod .. " + mouse:272",
  group "Window Management|Move/Resize" .. " move window",
  hl.dsp.window.drag(),
  { drag = true }
)
bind(
  mainMod .. " + mouse:273",
  group "Window Management|Move/Resize" .. " resize window",
  hl.dsp.window.resize(),
  { drag = true }
)

-- =============================================================================
-- Workspaces
-- =============================================================================
bind(mainMod .. " + 1", group "Workspaces|Switch" .. " workspace 1", hl.dsp.focus { workspace = 1 })
bind(mainMod .. " + 2", group "Workspaces|Switch" .. " workspace 2", hl.dsp.focus { workspace = 2 })
bind(mainMod .. " + 3", group "Workspaces|Switch" .. " workspace 3", hl.dsp.focus { workspace = 3 })
bind(mainMod .. " + 4", group "Workspaces|Switch" .. " workspace 4", hl.dsp.focus { workspace = 4 })
bind(mainMod .. " + 5", group "Workspaces|Switch" .. " workspace 5", hl.dsp.focus { workspace = 5 })
bind(mainMod .. " + 6", group "Workspaces|Switch" .. " workspace 6", hl.dsp.focus { workspace = 6 })
bind(mainMod .. " + 7", group "Workspaces|Switch" .. " workspace 7", hl.dsp.focus { workspace = 7 })
bind(mainMod .. " + 8", group "Workspaces|Switch" .. " workspace 8", hl.dsp.focus { workspace = 8 })
bind(mainMod .. " + 9", group "Workspaces|Switch" .. " workspace 9", hl.dsp.focus { workspace = 9 })
bind(mainMod .. " + 0", group "Workspaces|Switch" .. " workspace 10", hl.dsp.focus { workspace = 10 })

bind(
  mainMod .. " + SHIFT + 1",
  group "Workspaces|Move Window" .. " move to workspace 1",
  hl.dsp.window.move { workspace = 1 }
)
bind(
  mainMod .. " + SHIFT + 2",
  group "Workspaces|Move Window" .. " move to workspace 2",
  hl.dsp.window.move { workspace = 2 }
)
bind(
  mainMod .. " + SHIFT + 3",
  group "Workspaces|Move Window" .. " move to workspace 3",
  hl.dsp.window.move { workspace = 3 }
)
bind(
  mainMod .. " + SHIFT + 4",
  group "Workspaces|Move Window" .. " move to workspace 4",
  hl.dsp.window.move { workspace = 4 }
)
bind(
  mainMod .. " + SHIFT + 5",
  group "Workspaces|Move Window" .. " move to workspace 5",
  hl.dsp.window.move { workspace = 5 }
)
bind(
  mainMod .. " + SHIFT + 6",
  group "Workspaces|Move Window" .. " move to workspace 6",
  hl.dsp.window.move { workspace = 6 }
)
bind(
  mainMod .. " + SHIFT + 7",
  group "Workspaces|Move Window" .. " move to workspace 7",
  hl.dsp.window.move { workspace = 7 }
)
bind(
  mainMod .. " + SHIFT + 8",
  group "Workspaces|Move Window" .. " move to workspace 8",
  hl.dsp.window.move { workspace = 8 }
)
bind(
  mainMod .. " + SHIFT + 9",
  group "Workspaces|Move Window" .. " move to workspace 9",
  hl.dsp.window.move { workspace = 9 }
)
bind(
  mainMod .. " + SHIFT + 0",
  group "Workspaces|Move Window" .. " move to workspace 10",
  hl.dsp.window.move { workspace = 10 }
)

bind(mainMod .. " + S", group "Workspaces|Special" .. " toggle scratchpad", hl.dsp.workspace.toggle_special "magic")
bind(
  mainMod .. " + SHIFT + S",
  group "Workspaces|Special" .. " move to scratchpad",
  hl.dsp.window.move { workspace = "special:magic" }
)

bind(mainMod .. " + mouse_down", group "Workspaces|Navigation" .. " next workspace", hl.dsp.focus { workspace = "e+1" })
bind(
  mainMod .. " + mouse_up",
  group "Workspaces|Navigation" .. " previous workspace",
  hl.dsp.focus { workspace = "e-1" }
)

-- =============================================================================
-- Utilities
-- =============================================================================
bind(mainMod .. " + P", group "Utilities" .. " screenshot", hl.dsp.exec_cmd(scripts .. "/screenshot.sh s"))
bind(mainMod .. " + SHIFT + R", group "Utilities" .. " reload config", hl.dsp.exec_cmd "hyprctl reload")
bind(mainMod .. " + B", group "Utilities" .. " toggle quickshell", hl.dsp.exec_cmd "qs ipc call bar toggle")

-- =============================================================================
-- Hardware Controls
-- =============================================================================
bind(
  "XF86AudioRaiseVolume",
  group "Hardware Controls|Audio" .. " volume up",
  hl.dsp.exec_cmd "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+",
  { repeating = true }
)
bind(
  "XF86AudioLowerVolume",
  group "Hardware Controls|Audio" .. " volume down",
  hl.dsp.exec_cmd "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-",
  { repeating = true }
)
bind(
  "XF86AudioMute",
  group "Hardware Controls|Audio" .. " toggle mute",
  hl.dsp.exec_cmd "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle",
  { locked = true }
)
bind(
  "XF86AudioMicMute",
  group "Hardware Controls|Audio" .. " toggle mic mute",
  hl.dsp.exec_cmd "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle",
  { locked = true }
)

bind(
  "XF86MonBrightnessUp",
  group "Hardware Controls|Brightness" .. " brightness up",
  hl.dsp.exec_cmd "brightnessctl -e4 -n2 set 5%+",
  { repeating = true }
)
bind(
  "XF86MonBrightnessDown",
  group "Hardware Controls|Brightness" .. " brightness down",
  hl.dsp.exec_cmd "brightnessctl -e4 -n2 set 5%-",
  { repeating = true }
)

bind(
  "XF86AudioNext",
  group "Hardware Controls|Media" .. " next track",
  hl.dsp.exec_cmd "playerctl next",
  { locked = true }
)
bind(
  "XF86AudioPause",
  group "Hardware Controls|Media" .. " play/pause",
  hl.dsp.exec_cmd "playerctl play-pause",
  { locked = true }
)
bind(
  "XF86AudioPlay",
  group "Hardware Controls|Media" .. " play/pause",
  hl.dsp.exec_cmd "playerctl play-pause",
  { locked = true }
)
bind(
  "XF86AudioPrev",
  group "Hardware Controls|Media" .. " previous track",
  hl.dsp.exec_cmd "playerctl previous",
  { locked = true }
)
bind(
  mainMod .. " + SHIFT + L",
  group "Hardware Controls|Media" .. " lock screen",
  hl.dsp.exec_cmd(scripts .. "/lockscreen")
)

-- bind = ALT, TAB, exec, qs ipc -c overview call overview toggle
bind("ALT + TAB", "Miscellaneous toggle overview", hl.dsp.exec_cmd "qs ipc -c overview call overview toggle")
