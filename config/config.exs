use Mix.Config

config :clipboard,
  macos: [
    copy: {"pbcopy", []},
    paste: {"pbpaste", []},
  ],
  unix: [
    copy: {"xclip", []},
    paste: {"xclip", ["-o"]},
  ],
  windows: [
    copy: {"clip", []},
    paste: nil,
  ]
