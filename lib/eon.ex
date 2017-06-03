defmodule Eon do
  @moduledoc """
  Eon is a small library for using .exs files as a
  document store. Files read with Eon are expected
  to contain only an Elixir map as well as execute
  no arbitary code unless specified to do so. Eon
  can also write maps and structs to file.

  Eon is useful for when you would normally store
  data as JSON but you need to preserve Elixir's
  datatypes. Functions, ports and other datatypes
  that cannot be represented as pure data are not
  supported by Eon.
  """

  defmodule Error do
    defexception message: "Unexpected Eon error."
  end

  @errors %{
    eacces: "Permission denied.",
    eexist: "File already exists.",
    eisdir: "The named file is a directory.",
    enoent: "No such file or directory.",
    enospc: "There is no space left on the device.",
    enotdir: "Path is invalid.",
    eval: "File invalid. This usually means there is a syntax error.",
    unsafe: "File results in code execution. Use Eon.read_unsafe! to bypass."
  }

  @doc """
  Takes a string, expecting the contents to be a
  single map that executes no arbitrary code. Returns a
  tuple which contains `:ok` or `:error` as the first
  element and the result or error message respectively.

  ## Examples

      iex> Eon.read("%{hello: \"world\"}")
      {:ok, %{hello: "world"}}

      iex> Eon.read("%{num: Enum.random(0..100)}")
      {:error, :unsafe}

  """
  def from_string(string) when is_bitstring(string) do
    process_body({string, false, %{}})
  end

  @doc """
  Same as from_string/1 except it returns the result
  rather than an `:ok` tuple containing it. In the case
  of an error, an exception is raised.

  ## Examples

      iex> Eon.read("%{hello: \"world\"}")
      {:ok, %{hello: "world"}}

      iex> Eon.read("%{num: Enum.random(0..100)}")
      ** (Eon.Error) File results in code execution. Use Eon.read_unsafe! to bypass.

  """
  def from_string!(string) when is_bitstring(string) do
    case from_string(string) do
      {:ok, result} -> result
      {:error, error} -> raise_error(error)
    end
  end

  @doc """
  Same as `from_string/1` except allows arbitrary code
  execution. This effectively bypasses the step which
  prohibits the execution of Elixir code containing
  potentially unsafe data structures.
  """
  def from_string_unsafe(string) when is_bitstring(string) do
    from_string_unsafe(%{}, string)
  end
  @doc """
  Same as `from_string_unsafe/1` except it takes a map as
  the first argument and pushes the filename to the second.
  Unbound variables within the loaded file that match a
  key within the passed map will be replaced with the
  corresponding value.
  """
  def from_string_unsafe(bindings, string) when is_map(bindings) and is_bitstring(string) do
    process_body({string, true, bindings})
  end

  @doc """
  Same as `from_string_unsafe/1` except it returns the result
  rather than an `:ok` tuple containing it. In the case of an
  error, an exception is raised.
  """
  def from_string_unsafe!(string) when is_bitstring(string) do
    from_string_unsafe!(%{}, string)
  end
  @doc """
  Same as `from_string_unsafe/2` except it returns the result
  rather than an `:ok` tuple containing it. In the case of an
  error, an exception is raised.
  """
  def from_string_unsafe!(bindings, string) when is_map(bindings) and is_bitstring(string) do
    case from_string_unsafe(bindings, string) do
      {:ok, result} -> result
      {:error, error} -> raise_error(error)
    end
  end

  @doc """
  Loads a file, expecting a file with a single map
  that executes no arbitrary code. Returns a tuple
  which contains `:ok` or `:error` as the first element
  and the result or error message respectively.

  ## Examples

      iex> Eon.read("test/fixtures/basic.exs")
      {:ok, %{hello: "world"}}

      iex> Eon.read("test/fixtures/unsafe.exs")
      {:error, :unsafe}

      iex> Eon.read("non_existent_file.exs")
      {:error, :enoent}

  """
  def read(filename) when is_bitstring(filename) do
    read_file(filename, false, nil)
  end

  @doc """
  Same as read/1 except it returns the result rather
  than an `:ok` tuple containing it. In the case of an
  error, an exception is raised.

  ## Examples

      iex> Eon.read!("test/fixtures/basic.exs")
      %{hello: "world"}

      iex> Eon.read!("test/fixtures/unsafe.exs")
      ** (Eon.Error) File results in code execution. Use Eon.read_unsafe! to bypass.

      iex> Eon.read!("non_existent_file.exs")
      ** (Eon.Error) No such file or directory.

  """
  def read!(filename) when is_bitstring(filename) do
    case read(filename) do
      {:ok, result} -> result
      {:error, error} -> raise_error(error)
    end
  end

  @doc """
  Same as `read/1` except allows arbitrary code execution.
  This effectively bypasses the step which prohibits the
  execution of Elixir code containing potentially unsafe
  data structures.
  """
  def read_unsafe(filename) when is_bitstring(filename) do
    read_unsafe(%{}, filename)
  end
  @doc """
  Same as `read_unsafe/1` except it takes a map as the
  first argument and pushes the filename to the second.
  Unbound variables within the loaded file that match a
  key within the passed map will be replaced with the
  corresponding value.
  """
  def read_unsafe(bindings, filename) when is_map(bindings) and is_bitstring(filename) do
    read_file(filename, true, bindings)
  end

  @doc """
  Same as `read_unsafe/1` except it returns the result rather
  than an `:ok` tuple containing it. In the case of an error,
  an exception is raised.
  """
  def read_unsafe!(filename) when is_bitstring(filename) do
    read_unsafe!(%{}, filename)
  end
  @doc """
  Same as `read_unsafe/2` except it returns the result rather
  than an `:ok` tuple containing it. In the case of an error,
  an exception is raised.
  """
  def read_unsafe!(bindings, filename) when is_map(bindings) and is_bitstring(filename) do
    case read_unsafe(bindings, filename) do
      {:ok, result} -> result
      {:error, error} -> raise_error(error)
    end
  end

  @doc """
  Takes a map and writes it to file, returning the port
  of the IO connection.

  ## Examples

      iex> Eon.write(%{hello: "world"}, "hello.exs")
      {:ok, #PID<0.159.0>}

      iex> Eon.write(%{hello: "world"}, "/hello.exs")
      {:error, :eacces}

  """
  def write(map, filename) when is_map(map) and is_bitstring(filename) do
    map = Map.merge(%{}, map)
    contents =  Macro.to_string(quote do: unquote(map))

    case File.open(filename, [:write]) do
      {:ok, file} ->
        IO.binwrite(file, contents)
        {:ok, file}
      {:error, error} ->
        {:error, error}
      _ ->
        {:error, :unknown}
    end
  end

  @doc """
  Same as `write/2` except it returns the result rather
  than an `:ok` tuple containing it. In the case of an
  error, an exception is raised.

  ## Examples

      iex> Eon.write(%{hello: "world"}, "hello.exs")
      #PID<0.159.0>

      iex> Eon.write(%{hello: "world"}, "/hello.exs")
      ** (Eon.Error) Permission denied.

  """
  def write!(map, filename) when is_map(map) and is_bitstring(filename) do
    case write(map, filename) do
      {:ok, result} -> result
      {:error, error} -> raise_error(error)
    end
  end

  defp raise_error(error) do
    case get_in(@errors, [error]) do
      message when is_bitstring(message) -> raise Eon.Error, message: message
      _ -> raise Eon.Error
    end
  end

  defp read_file(filename, allow_unsafe, bindings) do
    case File.read(filename) do
      {:ok, file}     -> process_body({file, allow_unsafe, bindings})
      {:error, error} -> {:error, error}
      _               -> {:error, :unknown}
    end
  end

  defp process_body({body, _allow_unsafe = true, bindings}) do
    case Code.eval_string(body, Enum.map(bindings, &(&1))) do
      {contents, _results} -> {:ok, Map.merge(%{}, contents)}
      _ -> {:error, :eval}
    end
  end

  defp process_body({file, _, _bindings}) do
    case check_if_safe(file) do
      true ->
        {contents, _results} = Code.eval_string(file, [])
        {:ok, Map.merge(%{}, contents)}
      false ->
        {:error, :unsafe}
    end
  end

  defp check_if_safe(file) do
    case Code.string_to_quoted(file) do
      {:ok, {_type, _line, contents}} when is_list(contents) ->
        contents
        |> Enum.map(&is_safe?/1)
        |> List.flatten
        |> Enum.all?(&(&1))
      _ ->
        false
    end
  end

  defp is_safe?(value) do
    case value do
      {_key, {expression, _line, value}} ->
        if expression != :{} and expression != :%{} do
          false
        else
          value
          |> Enum.filter(&(is_tuple(&1)))
          |> Enum.map(&is_safe?/1)
        end
      {_key, value} when is_list(value) ->
        value
        |> Enum.filter(&(is_tuple(&1)))
        |> Enum.map(&is_safe?/1)
        |> Enum.all?(&(&1))
      {expression, _line, _value} ->
        expression == :{} or expression == :%{}
      _ ->
        true
    end
  end
end
