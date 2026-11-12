-- Migrated from Zellij and WezTerm. cmd+k keeps Rex's session picker.
-- Zellij clears its own defaults; Rex defaults remain unless replaced below.

rex.action{
  name  = "then_normal",
  title = "Run an action and return to normal mode",
  args  = { action = "string", args = "object?" },
  run   = function(ctx, args)
    rex.client.queue(args.action, args.args or {})
    rex.client.queue("client.mode.exit_all")
  end,
}

rex.mode("locked", { exclusive = true })
rex.mode("pane", { exclusive = true })
rex.mode("tab", { exclusive = true })
rex.mode("resize", { exclusive = true })
rex.mode("move", { exclusive = true })
rex.mode("scroll", { exclusive = true })
rex.mode("search", { exclusive = true })
rex.mode("session", { exclusive = true })
rex.mode("entersearch", { exclusive = true })
rex.mode("renametab", { exclusive = true })
rex.mode("renamepane", { exclusive = true })
rex.mode("tmux", { exclusive = true })

-- /Users/basavaraj/.config/zellij/config.kdl:7
rex.bind("locked/ctrl+g", "client.mode.exit_all")
-- /Users/basavaraj/.config/zellij/config.kdl:10
rex.bind("pane/left", "pane.focus", { direction = "left" })
-- /Users/basavaraj/.config/zellij/config.kdl:11
rex.bind("pane/down", "pane.focus", { direction = "down" })
-- /Users/basavaraj/.config/zellij/config.kdl:12
rex.bind("pane/up", "pane.focus", { direction = "up" })
-- /Users/basavaraj/.config/zellij/config.kdl:13
rex.bind("pane/right", "pane.focus", { direction = "right" })
-- /Users/basavaraj/.config/zellij/config.kdl:15
rex.bind("pane/d", "then_normal", { action = "pane.split", args = { direction = "down" } })
-- /Users/basavaraj/.config/zellij/config.kdl:17
rex.bind("pane/f", "then_normal", { action = "pane.zoom" })
-- /Users/basavaraj/.config/zellij/config.kdl:18
rex.bind("pane/h", "pane.focus", { direction = "left" })
-- /Users/basavaraj/.config/zellij/config.kdl:20
rex.bind("pane/j", "pane.focus", { direction = "down" })
-- /Users/basavaraj/.config/zellij/config.kdl:21
rex.bind("pane/k", "pane.focus", { direction = "up" })
-- /Users/basavaraj/.config/zellij/config.kdl:22
rex.bind("pane/l", "pane.focus", { direction = "right" })
-- /Users/basavaraj/.config/zellij/config.kdl:23
rex.bind("pane/n", "then_normal", { action = "pane.split", args = { direction = "auto" } })
-- /Users/basavaraj/.config/zellij/config.kdl:25
rex.bind("pane/ctrl+p", "client.mode.exit_all")
-- /Users/basavaraj/.config/zellij/config.kdl:26
rex.bind("pane/r", "then_normal", { action = "pane.split", args = { direction = "right" } })
-- /Users/basavaraj/.config/zellij/config.kdl:32
rex.bind("tab/left", "client.tab.previous")
-- /Users/basavaraj/.config/zellij/config.kdl:33
rex.bind("tab/down", "client.tab.next")
-- /Users/basavaraj/.config/zellij/config.kdl:34
rex.bind("tab/up", "client.tab.previous")
-- /Users/basavaraj/.config/zellij/config.kdl:35
rex.bind("tab/right", "client.tab.next")
-- /Users/basavaraj/.config/zellij/config.kdl:36
rex.bind("tab/1", "then_normal", { action = "client.tab.goto", args = { index = 1 } })
-- /Users/basavaraj/.config/zellij/config.kdl:37
rex.bind("tab/2", "then_normal", { action = "client.tab.goto", args = { index = 2 } })
-- /Users/basavaraj/.config/zellij/config.kdl:38
rex.bind("tab/3", "then_normal", { action = "client.tab.goto", args = { index = 3 } })
-- /Users/basavaraj/.config/zellij/config.kdl:39
rex.bind("tab/4", "then_normal", { action = "client.tab.goto", args = { index = 4 } })
-- /Users/basavaraj/.config/zellij/config.kdl:40
rex.bind("tab/5", "then_normal", { action = "client.tab.goto", args = { index = 5 } })
-- /Users/basavaraj/.config/zellij/config.kdl:41
rex.bind("tab/6", "then_normal", { action = "client.tab.goto", args = { index = 6 } })
-- /Users/basavaraj/.config/zellij/config.kdl:42
rex.bind("tab/7", "then_normal", { action = "client.tab.goto", args = { index = 7 } })
-- /Users/basavaraj/.config/zellij/config.kdl:43
rex.bind("tab/8", "then_normal", { action = "client.tab.goto", args = { index = 8 } })
-- /Users/basavaraj/.config/zellij/config.kdl:44
rex.bind("tab/9", "then_normal", { action = "client.tab.goto", args = { index = 9 } })
-- /Users/basavaraj/.config/zellij/config.kdl:47
rex.bind("tab/b", "then_normal", { action = "pane.move_to_new_tab" })
-- /Users/basavaraj/.config/zellij/config.kdl:48
rex.bind("tab/h", "client.tab.previous")
-- /Users/basavaraj/.config/zellij/config.kdl:49
rex.bind("tab/j", "client.tab.next")
-- /Users/basavaraj/.config/zellij/config.kdl:50
rex.bind("tab/k", "client.tab.previous")
-- /Users/basavaraj/.config/zellij/config.kdl:51
rex.bind("tab/l", "client.tab.next")
-- /Users/basavaraj/.config/zellij/config.kdl:52
rex.bind("tab/n", "then_normal", { action = "client.tab.new" })
-- /Users/basavaraj/.config/zellij/config.kdl:55
rex.bind("tab/ctrl+t", "client.mode.exit_all")
-- /Users/basavaraj/.config/zellij/config.kdl:56
rex.bind("tab/x", "then_normal", { action = "client.tab.close" })
-- /Users/basavaraj/.config/zellij/config.kdl:60
rex.bind("resize/left", "pane.resize", { direction = "left" })
-- /Users/basavaraj/.config/zellij/config.kdl:61
rex.bind("resize/down", "pane.resize", { direction = "down" })
-- /Users/basavaraj/.config/zellij/config.kdl:62
rex.bind("resize/up", "pane.resize", { direction = "up" })
-- /Users/basavaraj/.config/zellij/config.kdl:63
rex.bind("resize/right", "pane.resize", { direction = "right" })
-- /Users/basavaraj/.config/zellij/config.kdl:67
rex.bind("resize/shift+h", "pane.resize", { direction = "left", amount = -1 })
-- /Users/basavaraj/.config/zellij/config.kdl:68
rex.bind("resize/shift+j", "pane.resize", { direction = "down", amount = -1 })
-- /Users/basavaraj/.config/zellij/config.kdl:69
rex.bind("resize/shift+k", "pane.resize", { direction = "up", amount = -1 })
-- /Users/basavaraj/.config/zellij/config.kdl:70
rex.bind("resize/shift+l", "pane.resize", { direction = "right", amount = -1 })
-- /Users/basavaraj/.config/zellij/config.kdl:71
rex.bind("resize/h", "pane.resize", { direction = "left" })
-- /Users/basavaraj/.config/zellij/config.kdl:72
rex.bind("resize/j", "pane.resize", { direction = "down" })
-- /Users/basavaraj/.config/zellij/config.kdl:73
rex.bind("resize/k", "pane.resize", { direction = "up" })
-- /Users/basavaraj/.config/zellij/config.kdl:74
rex.bind("resize/l", "pane.resize", { direction = "right" })
-- /Users/basavaraj/.config/zellij/config.kdl:75
rex.bind("resize/;>r", "client.mode.exit_all")
-- /Users/basavaraj/.config/zellij/config.kdl:78
rex.bind("move/left", "pane.move", { direction = "left" })
-- /Users/basavaraj/.config/zellij/config.kdl:79
rex.bind("move/down", "pane.move", { direction = "down" })
-- /Users/basavaraj/.config/zellij/config.kdl:80
rex.bind("move/up", "pane.move", { direction = "up" })
-- /Users/basavaraj/.config/zellij/config.kdl:81
rex.bind("move/right", "pane.move", { direction = "right" })
-- /Users/basavaraj/.config/zellij/config.kdl:82
rex.bind("move/h", "pane.move", { direction = "left" })
-- /Users/basavaraj/.config/zellij/config.kdl:83
rex.bind("move/;>shift+r", "client.mode.exit_all")
-- /Users/basavaraj/.config/zellij/config.kdl:84
rex.bind("move/j", "pane.move", { direction = "down" })
-- /Users/basavaraj/.config/zellij/config.kdl:85
rex.bind("move/k", "pane.move", { direction = "up" })
-- /Users/basavaraj/.config/zellij/config.kdl:86
rex.bind("move/l", "pane.move", { direction = "right" })
-- /Users/basavaraj/.config/zellij/config.kdl:124
rex.bind("session/ctrl+shift+o", "client.mode.exit_all")
-- /Users/basavaraj/.config/zellij/config.kdl:148
rex.bind("alt+left", "pane.focus", { direction = "left" })
rex.bind("pane/alt+left", "pane.focus", { direction = "left" })
rex.bind("tab/alt+left", "pane.focus", { direction = "left" })
rex.bind("resize/alt+left", "pane.focus", { direction = "left" })
rex.bind("move/alt+left", "pane.focus", { direction = "left" })
rex.bind("scroll/alt+left", "pane.focus", { direction = "left" })
rex.bind("search/alt+left", "pane.focus", { direction = "left" })
rex.bind("session/alt+left", "pane.focus", { direction = "left" })
rex.bind("entersearch/alt+left", "pane.focus", { direction = "left" })
rex.bind("renametab/alt+left", "pane.focus", { direction = "left" })
rex.bind("renamepane/alt+left", "pane.focus", { direction = "left" })
rex.bind("tmux/alt+left", "pane.focus", { direction = "left" })
-- /Users/basavaraj/.config/zellij/config.kdl:149
rex.bind("alt+down", "pane.focus", { direction = "down" })
rex.bind("pane/alt+down", "pane.focus", { direction = "down" })
rex.bind("tab/alt+down", "pane.focus", { direction = "down" })
rex.bind("resize/alt+down", "pane.focus", { direction = "down" })
rex.bind("move/alt+down", "pane.focus", { direction = "down" })
rex.bind("scroll/alt+down", "pane.focus", { direction = "down" })
rex.bind("search/alt+down", "pane.focus", { direction = "down" })
rex.bind("session/alt+down", "pane.focus", { direction = "down" })
rex.bind("entersearch/alt+down", "pane.focus", { direction = "down" })
rex.bind("renametab/alt+down", "pane.focus", { direction = "down" })
rex.bind("renamepane/alt+down", "pane.focus", { direction = "down" })
rex.bind("tmux/alt+down", "pane.focus", { direction = "down" })
-- /Users/basavaraj/.config/zellij/config.kdl:150
rex.bind("alt+up", "pane.focus", { direction = "up" })
rex.bind("pane/alt+up", "pane.focus", { direction = "up" })
rex.bind("tab/alt+up", "pane.focus", { direction = "up" })
rex.bind("resize/alt+up", "pane.focus", { direction = "up" })
rex.bind("move/alt+up", "pane.focus", { direction = "up" })
rex.bind("scroll/alt+up", "pane.focus", { direction = "up" })
rex.bind("search/alt+up", "pane.focus", { direction = "up" })
rex.bind("session/alt+up", "pane.focus", { direction = "up" })
rex.bind("entersearch/alt+up", "pane.focus", { direction = "up" })
rex.bind("renametab/alt+up", "pane.focus", { direction = "up" })
rex.bind("renamepane/alt+up", "pane.focus", { direction = "up" })
rex.bind("tmux/alt+up", "pane.focus", { direction = "up" })
-- /Users/basavaraj/.config/zellij/config.kdl:151
rex.bind("alt+right", "pane.focus", { direction = "right" })
rex.bind("pane/alt+right", "pane.focus", { direction = "right" })
rex.bind("tab/alt+right", "pane.focus", { direction = "right" })
rex.bind("resize/alt+right", "pane.focus", { direction = "right" })
rex.bind("move/alt+right", "pane.focus", { direction = "right" })
rex.bind("scroll/alt+right", "pane.focus", { direction = "right" })
rex.bind("search/alt+right", "pane.focus", { direction = "right" })
rex.bind("session/alt+right", "pane.focus", { direction = "right" })
rex.bind("entersearch/alt+right", "pane.focus", { direction = "right" })
rex.bind("renametab/alt+right", "pane.focus", { direction = "right" })
rex.bind("renamepane/alt+right", "pane.focus", { direction = "right" })
rex.bind("tmux/alt+right", "pane.focus", { direction = "right" })
-- /Users/basavaraj/.config/zellij/config.kdl:158
rex.bind("ctrl+g", "client.mode.enter", { name = "locked" })
rex.bind("pane/ctrl+g", "client.mode.enter", { name = "locked" })
rex.bind("tab/ctrl+g", "client.mode.enter", { name = "locked" })
rex.bind("resize/ctrl+g", "client.mode.enter", { name = "locked" })
rex.bind("move/ctrl+g", "client.mode.enter", { name = "locked" })
rex.bind("scroll/ctrl+g", "client.mode.enter", { name = "locked" })
rex.bind("search/ctrl+g", "client.mode.enter", { name = "locked" })
rex.bind("session/ctrl+g", "client.mode.enter", { name = "locked" })
rex.bind("entersearch/ctrl+g", "client.mode.enter", { name = "locked" })
rex.bind("renametab/ctrl+g", "client.mode.enter", { name = "locked" })
rex.bind("renamepane/ctrl+g", "client.mode.enter", { name = "locked" })
rex.bind("tmux/ctrl+g", "client.mode.enter", { name = "locked" })
-- /Users/basavaraj/.config/zellij/config.kdl:159
rex.bind("alt+h", "pane.focus", { direction = "left" })
rex.bind("pane/alt+h", "pane.focus", { direction = "left" })
rex.bind("tab/alt+h", "pane.focus", { direction = "left" })
rex.bind("resize/alt+h", "pane.focus", { direction = "left" })
rex.bind("move/alt+h", "pane.focus", { direction = "left" })
rex.bind("scroll/alt+h", "pane.focus", { direction = "left" })
rex.bind("search/alt+h", "pane.focus", { direction = "left" })
rex.bind("session/alt+h", "pane.focus", { direction = "left" })
rex.bind("entersearch/alt+h", "pane.focus", { direction = "left" })
rex.bind("renametab/alt+h", "pane.focus", { direction = "left" })
rex.bind("renamepane/alt+h", "pane.focus", { direction = "left" })
rex.bind("tmux/alt+h", "pane.focus", { direction = "left" })
-- /Users/basavaraj/.config/zellij/config.kdl:160
rex.bind("alt+i", "client.tab.move", { direction = "backward" })
rex.bind("pane/alt+i", "client.tab.move", { direction = "backward" })
rex.bind("tab/alt+i", "client.tab.move", { direction = "backward" })
rex.bind("resize/alt+i", "client.tab.move", { direction = "backward" })
rex.bind("move/alt+i", "client.tab.move", { direction = "backward" })
rex.bind("scroll/alt+i", "client.tab.move", { direction = "backward" })
rex.bind("search/alt+i", "client.tab.move", { direction = "backward" })
rex.bind("session/alt+i", "client.tab.move", { direction = "backward" })
rex.bind("entersearch/alt+i", "client.tab.move", { direction = "backward" })
rex.bind("renametab/alt+i", "client.tab.move", { direction = "backward" })
rex.bind("renamepane/alt+i", "client.tab.move", { direction = "backward" })
rex.bind("tmux/alt+i", "client.tab.move", { direction = "backward" })
-- /Users/basavaraj/.config/zellij/config.kdl:161
rex.bind("alt+j", "pane.focus", { direction = "down" })
rex.bind("pane/alt+j", "pane.focus", { direction = "down" })
rex.bind("tab/alt+j", "pane.focus", { direction = "down" })
rex.bind("resize/alt+j", "pane.focus", { direction = "down" })
rex.bind("move/alt+j", "pane.focus", { direction = "down" })
rex.bind("scroll/alt+j", "pane.focus", { direction = "down" })
rex.bind("search/alt+j", "pane.focus", { direction = "down" })
rex.bind("session/alt+j", "pane.focus", { direction = "down" })
rex.bind("entersearch/alt+j", "pane.focus", { direction = "down" })
rex.bind("renametab/alt+j", "pane.focus", { direction = "down" })
rex.bind("renamepane/alt+j", "pane.focus", { direction = "down" })
rex.bind("tmux/alt+j", "pane.focus", { direction = "down" })
-- /Users/basavaraj/.config/zellij/config.kdl:162
rex.bind("alt+k", "pane.focus", { direction = "up" })
rex.bind("pane/alt+k", "pane.focus", { direction = "up" })
rex.bind("tab/alt+k", "pane.focus", { direction = "up" })
rex.bind("resize/alt+k", "pane.focus", { direction = "up" })
rex.bind("move/alt+k", "pane.focus", { direction = "up" })
rex.bind("scroll/alt+k", "pane.focus", { direction = "up" })
rex.bind("search/alt+k", "pane.focus", { direction = "up" })
rex.bind("session/alt+k", "pane.focus", { direction = "up" })
rex.bind("entersearch/alt+k", "pane.focus", { direction = "up" })
rex.bind("renametab/alt+k", "pane.focus", { direction = "up" })
rex.bind("renamepane/alt+k", "pane.focus", { direction = "up" })
rex.bind("tmux/alt+k", "pane.focus", { direction = "up" })
-- /Users/basavaraj/.config/zellij/config.kdl:163
rex.bind("alt+l", "pane.focus", { direction = "right" })
rex.bind("pane/alt+l", "pane.focus", { direction = "right" })
rex.bind("tab/alt+l", "pane.focus", { direction = "right" })
rex.bind("resize/alt+l", "pane.focus", { direction = "right" })
rex.bind("move/alt+l", "pane.focus", { direction = "right" })
rex.bind("scroll/alt+l", "pane.focus", { direction = "right" })
rex.bind("search/alt+l", "pane.focus", { direction = "right" })
rex.bind("session/alt+l", "pane.focus", { direction = "right" })
rex.bind("entersearch/alt+l", "pane.focus", { direction = "right" })
rex.bind("renametab/alt+l", "pane.focus", { direction = "right" })
rex.bind("renamepane/alt+l", "pane.focus", { direction = "right" })
rex.bind("tmux/alt+l", "pane.focus", { direction = "right" })
-- /Users/basavaraj/.config/zellij/config.kdl:164
rex.bind("alt+n", "pane.split", { direction = "auto" })
rex.bind("pane/alt+n", "pane.split", { direction = "auto" })
rex.bind("tab/alt+n", "pane.split", { direction = "auto" })
rex.bind("resize/alt+n", "pane.split", { direction = "auto" })
rex.bind("move/alt+n", "pane.split", { direction = "auto" })
rex.bind("scroll/alt+n", "pane.split", { direction = "auto" })
rex.bind("search/alt+n", "pane.split", { direction = "auto" })
rex.bind("session/alt+n", "pane.split", { direction = "auto" })
rex.bind("entersearch/alt+n", "pane.split", { direction = "auto" })
rex.bind("renametab/alt+n", "pane.split", { direction = "auto" })
rex.bind("renamepane/alt+n", "pane.split", { direction = "auto" })
rex.bind("tmux/alt+n", "pane.split", { direction = "auto" })
-- /Users/basavaraj/.config/zellij/config.kdl:165
rex.bind("alt+o", "client.tab.move", { direction = "forward" })
rex.bind("pane/alt+o", "client.tab.move", { direction = "forward" })
rex.bind("tab/alt+o", "client.tab.move", { direction = "forward" })
rex.bind("resize/alt+o", "client.tab.move", { direction = "forward" })
rex.bind("move/alt+o", "client.tab.move", { direction = "forward" })
rex.bind("scroll/alt+o", "client.tab.move", { direction = "forward" })
rex.bind("search/alt+o", "client.tab.move", { direction = "forward" })
rex.bind("session/alt+o", "client.tab.move", { direction = "forward" })
rex.bind("entersearch/alt+o", "client.tab.move", { direction = "forward" })
rex.bind("renametab/alt+o", "client.tab.move", { direction = "forward" })
rex.bind("renamepane/alt+o", "client.tab.move", { direction = "forward" })
rex.bind("tmux/alt+o", "client.tab.move", { direction = "forward" })
-- User-selected move-mode leader shortcut, shared across unlocked modes.
rex.bind(";>shift+r", "client.mode.enter", { name = "move" })
rex.bind("pane/;>shift+r", "client.mode.enter", { name = "move" })
rex.bind("tab/;>shift+r", "client.mode.enter", { name = "move" })
rex.bind("resize/;>shift+r", "client.mode.enter", { name = "move" })
rex.bind("scroll/;>shift+r", "client.mode.enter", { name = "move" })
rex.bind("search/;>shift+r", "client.mode.enter", { name = "move" })
rex.bind("session/;>shift+r", "client.mode.enter", { name = "move" })
rex.bind("entersearch/;>shift+r", "client.mode.enter", { name = "move" })
rex.bind("renametab/;>shift+r", "client.mode.enter", { name = "move" })
rex.bind("renamepane/;>shift+r", "client.mode.enter", { name = "move" })
rex.bind("tmux/;>shift+r", "client.mode.enter", { name = "move" })
-- /Users/basavaraj/.config/zellij/config.kdl:172
rex.bind("ctrl+shift+o", "client.mode.enter", { name = "session" })
rex.bind("pane/ctrl+shift+o", "client.mode.enter", { name = "session" })
rex.bind("tab/ctrl+shift+o", "client.mode.enter", { name = "session" })
rex.bind("resize/ctrl+shift+o", "client.mode.enter", { name = "session" })
rex.bind("move/ctrl+shift+o", "client.mode.enter", { name = "session" })
rex.bind("scroll/ctrl+shift+o", "client.mode.enter", { name = "session" })
rex.bind("search/ctrl+shift+o", "client.mode.enter", { name = "session" })
rex.bind("entersearch/ctrl+shift+o", "client.mode.enter", { name = "session" })
rex.bind("renametab/ctrl+shift+o", "client.mode.enter", { name = "session" })
rex.bind("renamepane/ctrl+shift+o", "client.mode.enter", { name = "session" })
rex.bind("tmux/ctrl+shift+o", "client.mode.enter", { name = "session" })
-- /Users/basavaraj/.config/zellij/config.kdl:175
rex.bind("ctrl+b", "client.mode.enter", { name = "tmux" })
rex.bind("pane/ctrl+b", "client.mode.enter", { name = "tmux" })
rex.bind("tab/ctrl+b", "client.mode.enter", { name = "tmux" })
rex.bind("resize/ctrl+b", "client.mode.enter", { name = "tmux" })
rex.bind("move/ctrl+b", "client.mode.enter", { name = "tmux" })
rex.bind("session/ctrl+b", "client.mode.enter", { name = "tmux" })
rex.bind("entersearch/ctrl+b", "client.mode.enter", { name = "tmux" })
rex.bind("renametab/ctrl+b", "client.mode.enter", { name = "tmux" })
rex.bind("renamepane/ctrl+b", "client.mode.enter", { name = "tmux" })
-- /Users/basavaraj/.config/zellij/config.kdl:178
rex.bind("ctrl+s", "client.mode.enter", { name = "scroll" })
rex.bind("pane/ctrl+s", "client.mode.enter", { name = "scroll" })
rex.bind("tab/ctrl+s", "client.mode.enter", { name = "scroll" })
rex.bind("resize/ctrl+s", "client.mode.enter", { name = "scroll" })
rex.bind("move/ctrl+s", "client.mode.enter", { name = "scroll" })
rex.bind("session/ctrl+s", "client.mode.enter", { name = "scroll" })
rex.bind("entersearch/ctrl+s", "client.mode.enter", { name = "scroll" })
rex.bind("renametab/ctrl+s", "client.mode.enter", { name = "scroll" })
rex.bind("renamepane/ctrl+s", "client.mode.enter", { name = "scroll" })
rex.bind("tmux/ctrl+s", "client.mode.enter", { name = "scroll" })
-- /Users/basavaraj/.config/zellij/config.kdl:181
rex.bind("ctrl+t", "client.mode.enter", { name = "tab" })
rex.bind("pane/ctrl+t", "client.mode.enter", { name = "tab" })
rex.bind("resize/ctrl+t", "client.mode.enter", { name = "tab" })
rex.bind("move/ctrl+t", "client.mode.enter", { name = "tab" })
rex.bind("scroll/ctrl+t", "client.mode.enter", { name = "tab" })
rex.bind("search/ctrl+t", "client.mode.enter", { name = "tab" })
rex.bind("session/ctrl+t", "client.mode.enter", { name = "tab" })
rex.bind("entersearch/ctrl+t", "client.mode.enter", { name = "tab" })
rex.bind("renametab/ctrl+t", "client.mode.enter", { name = "tab" })
rex.bind("renamepane/ctrl+t", "client.mode.enter", { name = "tab" })
rex.bind("tmux/ctrl+t", "client.mode.enter", { name = "tab" })
-- /Users/basavaraj/.config/zellij/config.kdl:184
rex.bind("ctrl+p", "client.mode.enter", { name = "pane" })
rex.bind("tab/ctrl+p", "client.mode.enter", { name = "pane" })
rex.bind("resize/ctrl+p", "client.mode.enter", { name = "pane" })
rex.bind("move/ctrl+p", "client.mode.enter", { name = "pane" })
rex.bind("scroll/ctrl+p", "client.mode.enter", { name = "pane" })
rex.bind("search/ctrl+p", "client.mode.enter", { name = "pane" })
rex.bind("session/ctrl+p", "client.mode.enter", { name = "pane" })
rex.bind("entersearch/ctrl+p", "client.mode.enter", { name = "pane" })
rex.bind("renametab/ctrl+p", "client.mode.enter", { name = "pane" })
rex.bind("renamepane/ctrl+p", "client.mode.enter", { name = "pane" })
rex.bind("tmux/ctrl+p", "client.mode.enter", { name = "pane" })
-- /Users/basavaraj/.config/zellij/config.kdl:187
rex.bind(";>r", "client.mode.enter", { name = "resize" })
rex.bind("pane/;>r", "client.mode.enter", { name = "resize" })
rex.bind("tab/;>r", "client.mode.enter", { name = "resize" })
rex.bind("move/;>r", "client.mode.enter", { name = "resize" })
rex.bind("scroll/;>r", "client.mode.enter", { name = "resize" })
rex.bind("search/;>r", "client.mode.enter", { name = "resize" })
rex.bind("session/;>r", "client.mode.enter", { name = "resize" })
rex.bind("entersearch/;>r", "client.mode.enter", { name = "resize" })
rex.bind("renametab/;>r", "client.mode.enter", { name = "resize" })
rex.bind("renamepane/;>r", "client.mode.enter", { name = "resize" })
rex.bind("tmux/;>r", "client.mode.enter", { name = "resize" })
-- /Users/basavaraj/.config/zellij/config.kdl:190
rex.bind("pane/enter", "client.mode.exit_all")
rex.bind("tab/enter", "client.mode.exit_all")
rex.bind("resize/enter", "client.mode.exit_all")
rex.bind("move/enter", "client.mode.exit_all")
rex.bind("scroll/enter", "client.mode.exit_all")
rex.bind("search/enter", "client.mode.exit_all")
rex.bind("session/enter", "client.mode.exit_all")
rex.bind("renametab/enter", "client.mode.exit_all")
rex.bind("renamepane/enter", "client.mode.exit_all")
rex.bind("tmux/enter", "client.mode.exit_all")
-- /Users/basavaraj/.config/zellij/config.kdl:193
rex.bind("pane/esc", "client.mode.exit_all")
rex.bind("tab/esc", "client.mode.exit_all")
rex.bind("resize/esc", "client.mode.exit_all")
rex.bind("move/esc", "client.mode.exit_all")
rex.bind("scroll/esc", "client.mode.exit_all")
rex.bind("search/esc", "client.mode.exit_all")
rex.bind("session/esc", "client.mode.exit_all")
rex.bind("tmux/esc", "client.mode.exit_all")
-- /Users/basavaraj/.config/zellij/config.kdl:196
rex.bind("pane/x", "then_normal", { action = "pane.close" })
rex.bind("tmux/x", "then_normal", { action = "pane.close" })
-- /Users/basavaraj/.config/zellij/config.kdl:213
rex.bind("scroll/ctrl+s", "client.mode.exit_all")
rex.bind("search/ctrl+s", "client.mode.exit_all")
-- /Users/basavaraj/.config/zellij/config.kdl:217
rex.bind("entersearch/ctrl+c", "client.mode.enter", { name = "scroll" })
-- /Users/basavaraj/.config/zellij/config.kdl:218
rex.bind("entersearch/esc", "client.mode.enter", { name = "scroll" })
-- /Users/basavaraj/.config/zellij/config.kdl:219
rex.bind("entersearch/enter", "client.mode.enter", { name = "search" })
-- /Users/basavaraj/.config/zellij/config.kdl:225
rex.bind("renametab/ctrl+c", "client.mode.exit_all")
rex.bind("renamepane/ctrl+c", "client.mode.exit_all")
-- /Users/basavaraj/.config/zellij/config.kdl:234
rex.bind("tmux/left", "then_normal", { action = "pane.focus", args = { direction = "left" } })
-- /Users/basavaraj/.config/zellij/config.kdl:235
rex.bind("tmux/down", "then_normal", { action = "pane.focus", args = { direction = "down" } })
-- /Users/basavaraj/.config/zellij/config.kdl:236
rex.bind("tmux/up", "then_normal", { action = "pane.focus", args = { direction = "up" } })
-- /Users/basavaraj/.config/zellij/config.kdl:237
rex.bind("tmux/right", "then_normal", { action = "pane.focus", args = { direction = "right" } })
-- /Users/basavaraj/.config/zellij/config.kdl:239
rex.bind("tmux/shift+'", "then_normal", { action = "pane.split", args = { direction = "down" } })
-- /Users/basavaraj/.config/zellij/config.kdl:240
rex.bind("tmux/shift+5", "then_normal", { action = "pane.split", args = { direction = "right" } })
-- /Users/basavaraj/.config/zellij/config.kdl:241
rex.bind("tmux/,", "client.mode.enter", { name = "renametab" })
-- /Users/basavaraj/.config/zellij/config.kdl:242
rex.bind("tmux/[", "client.mode.enter", { name = "scroll" })
-- /Users/basavaraj/.config/zellij/config.kdl:243
rex.bind("tmux/ctrl+b", "then_normal", { action = "pane.send_key", args = { key = "ctrl+b" } })
-- /Users/basavaraj/.config/zellij/config.kdl:244
rex.bind("tmux/c", "then_normal", { action = "client.tab.new" })
-- /Users/basavaraj/.config/zellij/config.kdl:245
rex.bind("tmux/h", "then_normal", { action = "pane.focus", args = { direction = "left" } })
-- /Users/basavaraj/.config/zellij/config.kdl:246
rex.bind("tmux/j", "then_normal", { action = "pane.focus", args = { direction = "down" } })
-- /Users/basavaraj/.config/zellij/config.kdl:247
rex.bind("tmux/k", "then_normal", { action = "pane.focus", args = { direction = "up" } })
-- /Users/basavaraj/.config/zellij/config.kdl:248
rex.bind("tmux/l", "then_normal", { action = "pane.focus", args = { direction = "right" } })
-- /Users/basavaraj/.config/zellij/config.kdl:249
rex.bind("tmux/n", "then_normal", { action = "client.tab.next" })
-- /Users/basavaraj/.config/zellij/config.kdl:250
rex.bind("tmux/o", "pane.focus_next")
-- /Users/basavaraj/.config/zellij/config.kdl:251
rex.bind("tmux/p", "then_normal", { action = "client.tab.previous" })
-- /Users/basavaraj/.config/zellij/config.kdl:252
rex.bind("tmux/z", "then_normal", { action = "pane.zoom" })
-- /Users/basavaraj/.wezterm.lua:41
rex.bind("ctrl+shift+r", "client.config.reload")

-- Herdr-style leader shortcuts: press ;, then the action key.
rex.bind(";>h", "pane.focus", { direction = "left" })
rex.bind(";>j", "pane.focus", { direction = "down" })
rex.bind(";>k", "pane.focus", { direction = "up" })
rex.bind(";>l", "pane.focus", { direction = "right" })

-- Exclusive modes need their own leader bindings.
for _, mode in ipairs({
  "pane", "tab", "resize", "move", "scroll", "search", "session",
  "entersearch", "renametab", "renamepane", "tmux",
}) do
  for _, binding in ipairs({
    { "h", "left" }, { "j", "down" }, { "k", "up" }, { "l", "right" },
  }) do
    rex.bind(mode .. "/;>" .. binding[1], "pane.focus", { direction = binding[2] })
  end
  rex.bind(mode .. "/;>shift+n", "session.new")
  rex.bind(mode .. "/;>shift+w", "session.rename")
  rex.bind(mode .. "/;>shift+p", "pane.rename")
  rex.bind(mode .. "/;>shift+t", "client.tab.rename")
  rex.bind(mode .. "/;>z", "pane.zoom")
  rex.bind(mode .. "/;>x", "pane.close")
end

rex.bind(";>v", "pane.split", { direction = "right" })
rex.bind(";>-", "pane.split", { direction = "down" })
rex.bind(";>c", "client.tab.new")
rex.bind(";>n", "client.tab.next")
rex.bind(";>p", "client.tab.previous")
rex.bind(";>g", "session.switch")
rex.bind(";>z", "pane.zoom")
rex.bind(";>x", "pane.close")
rex.bind(";>shift+n", "session.new")
rex.bind(";>shift+w", "session.rename")
rex.bind(";>shift+p", "pane.rename")
rex.bind(";>shift+t", "client.tab.rename")
-- Codex's shared daemon lists its agents even when they do not emit OSC 7501.
rex.action{
  name = "show_codex_agents",
  title = "Show Codex Agents",
  run = function(ctx, args)
    if not ctx.session_id then
      error("Open a Rex session before viewing agents", 0)
    end
    local view, err = rex.session.view{}
    if view == nil then error(err, 0) end
    for _, window in ipairs(view.windows or {}) do
      if window.label == "Codex Agents" then
        local focused, focus_err = rex.session.focus_window{
          window_id = window.window_id,
        }
        if focused == nil then error(focus_err, 0) end
        return { window_id = window.window_id }
      end
    end
    local created, create_err = rex.session.new_window{
      window_label = "Codex Agents",
      layout = rex.layout.block{
        flavor = "com.superlogical.terminal.shell",
        options = { command = { "/opt/homebrew/bin/codex", "agents" } },
      },
    }
    if created == nil then error(create_err, 0) end
    return created
  end,
}
rex.bind(";>a", "show_codex_agents")
rex.bind(";>shift+a", "client.sidebar.activity.by_priority")
rex.unbind("cmd+/")
rex.bind(";>b", "client.sidebar.toggle")
rex.bind(";>;", "pane.send_key", { key = ";" })

-- Vim selection and yanking in a read-only snapshot of the focused pane.
rex.action{
  name = "return_from_vim_copy",
  title = "Close Vim Copy Viewer and Return",
  args = { source_block_id = "string", viewer_block_id = "string" },
  run = function(ctx, args)
    if not ctx.session_id or args.viewer_block_id == args.source_block_id then
      error("Return must be requested from the Vim copy viewer", 0)
    end
    -- The terminal may already have disappeared after Neovim exited.
    local viewer = rex.session.describe_block{ block_id = args.viewer_block_id }
    if viewer ~= nil then
      if viewer.block.label ~= "Copy pane (Vim)" then
        error("Only the Vim copy viewer can be closed by this action", 0)
      end
      local closed, close_err = rex.call("block.close", {
        session_id = ctx.session_id,
        block_id = args.viewer_block_id,
      })
      if closed == nil then error(close_err, 0) end
    end
    local focused, focus_err = rex.session.focus_block{ block_id = args.source_block_id }
    if focused == nil then error(focus_err, 0) end
    return focused
  end,
}

rex.action{
  name = "copy_pane_vim",
  title = "Copy Pane with Vim",
  run = function(ctx, args)
    if not ctx.session_id or not ctx.block_id then
      error("Focus a terminal pane before opening Vim copy mode", 0)
    end
    local source, err = rex.session.describe_block{ block_id = ctx.block_id }
    if source == nil then error(err, 0) end
    if not source.block.window_id then
      error("Focus a terminal in a tab before opening Vim copy mode", 0)
    end
    local view, view_err = rex.session.view{}
    if view == nil then error(view_err, 0) end
    local function pane_rect(node)
      if not node then return nil end
      if node.block_id == ctx.block_id then return node.rect end
      if node.split then
        return pane_rect(node.split.before) or pane_rect(node.split.after)
      end
    end
    local bounds
    for _, window in ipairs(view.windows or {}) do
      if window.window_id == source.block.window_id then
        if window.zoomed_block_id == ctx.block_id then
          bounds = { 0, 0, 1, 1 }
        else
          for _, layer in ipairs(window.layers or {}) do
            -- Layout rects already use window coordinates, even in floating layers.
            bounds = pane_rect(layer.layout)
            if bounds then break end
          end
        end
        break
      end
    end
    if not bounds then error("Could not find the source pane's bounds", 0) end
    local result, create_err = rex.session.new_layer{
      window_id = source.block.window_id,
      bounds = bounds,
      focus = true,
      layout = {
        block = {
          flavor = "com.superlogical.terminal.shell",
          label = "Copy pane (Vim)",
          options = {
            shell = "none",
            command = {
              "/bin/sh", "/Users/basavaraj/.config/rex/copy-pane.sh",
              ctx.session_id, ctx.block_id,
            },
          },
        },
      },
    }
    if result == nil then error(create_err, 0) end
    return result
  end,
}
rex.bind(";>[", "copy_pane_vim")
rex.bind(";>y", "pane.copy")

-- Open tools in the focused terminal's directory, using the normal shell/editor setup.
rex.action{
  name = "open_pane_tool",
  title = "Open a Pane Tool",
  args = { tool = "string" },
  run = function(ctx, args)
    local tools = {
      terminal = { label = "Floating terminal", floating = true },
      lazygit = {
        label = "LazyGit", floating = true,
        command = { "/opt/homebrew/bin/lazygit" },
      },
      oil = {
        label = "Oil (Neovim)",
        command = { "/opt/homebrew/bin/nvim", "-c", "Oil" },
      },
    }
    local tool = tools[args.tool]
    if not tool then error("Unknown pane tool: " .. args.tool, 0) end
    if not ctx.session_id or not ctx.block_id then
      error("Focus a terminal pane before opening a tool", 0)
    end
    local source, source_err = rex.session.describe_block{ block_id = ctx.block_id }
    if source == nil then error(source_err, 0) end
    if not source.block.window_id then
      error("Focus a terminal in a tab before opening a tool", 0)
    end
    local process, process_err = rex.block.call("com.superlogical.terminal", "process", {
      block_id = ctx.block_id,
    })
    if process == nil then error(process_err, 0) end
    local cwd = (process.foreground or {}).cwd or (process.child or {}).cwd or process.home
    if not cwd then error("Could not find the focused terminal's directory", 0) end
    local layout = {
      block = {
        flavor = "com.superlogical.terminal.shell",
        label = tool.label,
        options = { cwd = cwd, command = tool.command },
      },
    }
    local created, create_err
    if tool.floating then
      created, create_err = rex.session.new_layer{
        window_id = source.block.window_id,
        bounds = { 0.1, 0.1, 0.8, 0.8 },
        focus = true,
        layout = layout,
      }
    else
      created, create_err = rex.session.new_split{
        anchor_id = ctx.block_id,
        direction = "horizontal",
        side = "after",
        focus = true,
        layout = layout,
      }
    end
    if created == nil then error(create_err, 0) end
    return created
  end,
}

-- Keep these leader shortcuts available in every unlocked key mode.
for _, prefix in ipairs({
  "", "pane/", "tab/", "resize/", "move/", "scroll/", "search/", "session/",
  "entersearch/", "renametab/", "renamepane/", "tmux/",
}) do
  rex.bind(prefix .. ";>f", "open_pane_tool", { tool = "terminal" })
  rex.bind(prefix .. ";>shift+g", "open_pane_tool", { tool = "lazygit" })
  rex.bind(prefix .. ";>e", "open_pane_tool", { tool = "oil" })
end

-- Pane marks and last-active navigation, including focus changes made with the mouse.
dofile(os.getenv("HOME") .. "/.config/rex/pane-navigation.lua")(
  os.getenv("HOME") .. "/.config/rex/pane-navigation-state.json"
)
