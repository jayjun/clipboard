defmodule Clipboard do
  @moduledoc """
  Copy and paste from system clipboard.

  Wraps ports to system-specific utilities responsible for clipboard access. It uses the default
  clipboard utilities on macOS, Linux and Windows but can be configured to call any executable.
  """

  @doc """
  Copy `value` to system clipboard.

  `value` can be any type that conforms to `String.Chars` (e.g. binaries, iodata), so
  `Kernel.to_string/1` is used to serialize input before copying to clipboard. The original `value`
  is always returned, so `copy/1` can be used in pipelines.

  # Examples

      iex> Clipboard.copy("Hello, World!")
      "Hello, World!"

      iex> Clipboard.copy(["Hello", "World!"])
      ["Hello", "World!"]

      iex> "Hello, World!" |> Clipboard.copy() |> IO.puts()
      "Hello, World"

  """
  @spec copy(iodata) :: iodata
  def copy(value) do
    copy(:os.type(), to_string(value))
    value
  end

  @doc """
  Copy `value` to system clipboard but throw exception if it fails.

  Identical to `copy/1`, except raise an exception if the operation fails.

  The operation may fail when running Clipboard on unsupported operating systems or with missing
  executables (check your config).
  """
  @spec copy!(iodata) :: iodata | no_return
  def copy!(value) do
    case copy(:os.type(), to_string(value)) do
      :ok ->
        value
      {:error, reason} ->
        raise reason
    end
  end

  defp copy({:unix, :darwin}, value) do
    command = Application.get_env(:clipboard, :macos)[:copy] || {"pbcopy", []}
    do_copy(command, value)
  end

  defp copy({:unix, _os_name}, value) do
    command = Application.get_env(:clipboard, :unix)[:copy] || {"xclip", []}
    do_copy(command, value)
  end

  defp copy({:win32, _os_name}, value) do
    command = Application.get_env(:clipboard, :windows)[:copy] || {"clip", []}
    do_copy(command, value)
  end

  defp copy({_unsupported_family, _unsupported_name}, _value) do
    {:error, "Unsupported operating system"}
  end

  defp do_copy({executable, args}, value) when is_binary(executable) and is_list(args) do
    case System.find_executable(executable) do
      nil ->
        {:error, "Cannot find #{executable}"}
      path ->
        port = Port.open({:spawn_executable, path}, [:binary, args: args])
        send port, {self(), {:command, value}}
        send port, {self(), :close}
        :ok
    end
  end

  defp do_copy(nil, _value) do
    {:error, "Unsupported operating system"}
  end

  @doc """
  Return the contents of system clipboard.

  # Examples

      iex> Clipboard.paste()
      "Hello, World!"

  """
  @spec paste() :: String.t
  def paste() do
    case paste(:os.type()) do
      {:error, _reason} ->
        nil
      output ->
        output
    end
  end

  @doc """
  Return the contents of system clipboard but throw exception if it fails.

  Identical to `paste/1`, except raise an exception if the operation fails.

  The operation may fail when running Clipboard on unsupported operating systems or with missing
  executables (check your config).
  """
  @spec paste!() :: String.t | no_return
  def paste!() do
    case paste(:os.type()) do
      {:error, reason} ->
        raise reason
      output ->
        output
    end
  end

  defp paste({:unix, :darwin}) do
    command = Application.get_env(:clipboard, :macos)[:paste] || {"pbpaste", []}
    do_paste(command)
  end

  defp paste({:unix, _os_name}) do
    command = Application.get_env(:clipboard, :unix)[:paste] || {"xclip", ["-o"]}
    do_paste(command)
  end

  defp paste(_unsupported_os) do
    {:error, "Unsupported operating system"}
  end

  defp do_paste({executable, args}) when is_binary(executable) and is_list(args) do
    case System.find_executable(executable) do
      nil ->
        {:error, "Cannot find #{executable}"}
      _ ->
        case System.cmd(executable, args) do
          {output, 0} ->
            output
          {error, _} ->
            {:error, error}
        end
    end
  end
end
