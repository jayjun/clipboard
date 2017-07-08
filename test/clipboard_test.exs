defmodule ClipboardTest do
  use ExUnit.Case

  test "copy returns the same value" do
    string = "Hello, World!"
    list = ["Hello", "World"]
    map = %{hello: "world"}
    tuple = {"hello", "world"}

    assert string == Clipboard.copy(string)
    assert list == Clipboard.copy(list)
    assert map == Clipboard.copy(map)
    assert tuple == Clipboard.copy(tuple)
  end

  test "copy followed by paste should be the same value" do
    string = "Hello, World!"
    Clipboard.copy(string)

    # Wait for input to flush
    :timer.sleep(100)

    assert string == Clipboard.paste()
  end
end
