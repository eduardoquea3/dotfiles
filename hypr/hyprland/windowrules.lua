-- Window Rules Configuration
-- See https://wiki.hypr.land/Configuring/Window-Rules/ for more

-- Example windowrules that are useful

hl.window_rule({
  name = "suppress-maximize-events",
  match = {
    class = ".*",
  },
  suppress_event = "maximize",
})

hl.window_rule({
  name = "fix-xwayland-drags",
  match = {
    class = "^$",
    title = "^$",
    xwayland = true,
    float = true,
    fullscreen = false,
    pin = false,
  },
  no_focus = true,
})

-- Hyprland-run windowrule
hl.window_rule({
  name = "move-hyprland-run",
  match = {
    class = "hyprland-run",
  },
  move = { 20, "monitor_h-120" },
  float = true,
})

-- Picture-in-Picture windowrule
hl.window_rule({
  name = "pip-video",
  match = {
    class = "zen",
    title = "Picture-in-Picture",
  },
  -- float = true
  -- pin = true
  -- size = { 488, 346 }
  -- center = true
  workspace = "1",
  fullscreen = true,
})

-- Satty screenshot editor
hl.window_rule({
  name = "satty-float",
  match = {
    class = "com.gabm.satty",
  },
  float = true,
  fullscreen = false,
  size = { "90%", "90%" },
  center = true,
  suppress_event = "fullscreen",
})

-- Startup apps are now handled in init.conf with bracket syntax
