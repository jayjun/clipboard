# Clipboard

![](https://github.com/jayjun/clipboard/workflows/CI/badge.svg)

Copy and paste from system clipboard.

Sick of `IO.puts(json)` then manually selecting your terminal? Try `Clipboard.copy(json)`!

Wraps ports to system-specific utilities responsible for clipboard access. It uses the default
clipboard utilities on macOS, Linux and Windows but can be configured to call any executable.

## Examples

```elixir
Clipboard.copy("Hello, World!") # Copied to clipboard

"Hello, World!"
|> Clipboard.copy() # Insert into pipelines
|> business_as_usual()

# And paste too!
greeting = Clipboard.paste()
```

## Options

Clipboard uses these utilities by default.

| OS      | Utilities            |
| ------- | -------------------- |
| macOS   | `pbcopy` & `pbpaste` |
| Linux   | `xclip`              |
| Windows | `clip`               |

However, you can instruct Clipboard to use another command by setting `config.exs`.

```elixir
config :clipboard,
  unix: [
    copy: {"xsel", ["-i"]},
    paste: {"xsel", ["-o"]}
  ]
```

Supported operating systems are `:macos`, `:unix` and `:windows`.

## Installation

Add `clipboard` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:clipboard, ">= 0.0.0", only: [:dev]}
  ]
end
```

Don’t forget to update your dependencies.

```
$ mix deps.get
```

## Caveats

Pasting on Windows doesn’t work out of the box because `clip` only supports copying.

## Links

- [Documentation][1]
- [Hex][2]

## License

Clipboard is released under [MIT][3] license.

[1]: https://hexdocs.pm/clipboard/Clipboard.html
[2]: https://hex.pm/packages/clipboard
[3]: https://github.com/jayjun/clipboard/blob/master/LICENSE.md
