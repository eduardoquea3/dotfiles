hl.monitor {
  output = "HDMI-A-1",
  mode = "1920x1080@60",
  position = "0x0",
  scale = 1,
}

hl.monitor {
  output = "eDP-1",
  mode = "1920x1080@60",
  position = "0x1080",
  scale = 1.2,
}

hl.window_rule { workspace = "4", monitor = "HDMI-A-1" }
