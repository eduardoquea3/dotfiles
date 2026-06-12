hl.config {
  input = {
    kb_layout = "us",
    follow_mouse = 1,
    sensitivity = 0,
    touchpad = {
      natural_scroll = false,
    },
  },

  xwayland = {
    force_zero_scaling = true,
  },

  misc = {
    force_default_wallpaper = -1,
    disable_hyprland_logo = false,
  },

  dwindle = {
    preserve_split = true,
  },

  master = {
    new_status = "master",
  },

  decoration = {
    rounding = 6,
    rounding_power = 2,

    active_opacity = 1.0,
    inactive_opacity = 1.0,

    shadow = {
      enabled = true,
      range = 4,
      render_power = 3,
      color = "#1a1a1aee",
    },

    blur = {
      enabled = true,
      size = 3,
      passes = 1,
      vibrancy = 0.1696,
    },
  },

  general = {
    gaps_in = 2,
    gaps_out = 2,

    border_size = 2,

    resize_on_border = false,
    allow_tearing = false,

    layout = "dwindle",

    col = {
      active_border = "#7fb4caff",
      inactive_border = "#5c6066aa",
    },
  },
}

hl.gesture {
  fingers = 3,
  direction = "horizontal",
  action = "workspace",
}
