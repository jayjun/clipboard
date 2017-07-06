defmodule ClipboardTest do
  use ExUnit.Case

  test "copy returns the same value" do
    string = "Hello, World!"
    list = ["Hello", "World"]

    assert string == Clipboard.copy(string)
    assert list == Clipboard.copy(list)
  end

  test "raise when copying values that don't conform to String.Chars" do
    assert_raise Protocol.UndefinedError, fn ->
      Clipboard.copy({"Hello", "World"})
    end

    assert_raise Protocol.UndefinedError, fn ->
      Clipboard.copy(%{"hello" => "world"})
    end
  end

  test "copy followed by paste should be the same value" do
    string = "Hello, World!"
    Clipboard.copy(string)

    # Wait for input to flush
    :timer.sleep(100)

    assert string == Clipboard.paste()
  end
end
