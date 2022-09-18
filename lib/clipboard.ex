defmodule Clipboard do
  @moduledoc """
  Copy and paste from system clipboard.

  Wraps ports to system-specific utilities responsible for clipboard access. It uses the default
  clipboard utilities on macOS, Linux and Windows but can be configured to call any executable.
  """

  @doc """
  Copy `value` to system clipboard.

  The original `value` is always returned, so `copy/1` can be used in pipelines.

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
    copy(:os.type(), value)
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
    case copy(:os.type(), value) do
      :ok ->
        value

      {:error, reason} ->
        raise reason
    end
  end

  defp copy({:unix, :darwin}, value) do
    command = Application.get_env(:clipboard, :macos)[:copy] || {"pbcopy", []}
    execute(command, value)
  end

  defp copy({:unix, _os_name}, value) do
    command = Application.get_env(:clipboard, :unix)[:copy] || {"xclip", []}
    execute(command, value)
  end

  defp copy({:win32, _os_name}, value) do
    command = Application.get_env(:clipboard, :windows)[:copy] || {"clip", []}
    execute(command, value)
  end

  defp copy({_unsupported_family, _unsupported_name}, _value) do
    {:error, "Unsupported operating system"}
  end

  @doc """
  Return the contents of system clipboard.

  # Examples

      iex> Clipboard.paste()
      "Hello, World!"

  """
  @spec paste() :: String.t()
  def paste do
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
  @spec paste!() :: String.t() | no_return
  def paste! do
    case paste(:os.type()) do
      {:error, reason} ->
        raise reason

      output ->
        output
    end
  end

  defp paste({:unix, :darwin}) do
    command = Application.get_env(:clipboard, :macos)[:paste] || {"pbpaste", []}
    execute(command)
  end

  defp paste({:unix, _os_name}) do
    command = Application.get_env(:clipboard, :unix)[:paste] || {"xclip", ["-o"]}
    execute(command)
  end
  
  defp paste({:win32, _os_name}) do
    command = Application.get_env(:clipboard, :windows)[:paste] || {"powershell", ["Get-Clipboard"]}
    execute(command)
  end

  defp paste(_unsupported_os) do
    {:error, "Unsupported operating system"}
  end

  # Ports

  defp execute(nil), do: {:error, "Unsupported operating system"}

  defp execute({executable, args}) when is_binary(executable) and is_list(args) do
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

  defp execute(nil, _), do: {:error, "Unsupported operating system"}

  defp execute({executable, args}, value) when is_binary(executable) and is_list(args) do
    case System.find_executable(executable) do
      nil ->
        {:error, "Cannot find #{executable}"}

      path ->
        port = Port.open({:spawn_executable, path}, [:binary, args: args])

        case value do
          value when is_binary(value) ->
            send(port, {self(), {:command, value}})

          value ->
            send(port, {self(), {:command, format(value)}})
        end

        send(port, {self(), :close})
        :ok
    end
  end

  defp format(value) do
    doc = Inspect.Algebra.to_doc(value, %Inspect.Opts{limit: :infinity})
    Inspect.Algebra.format(doc, :infinity)
  end
end
