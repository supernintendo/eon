defmodule Peon do
  def from_file(filename), do: load_file(filename, false, nil)
  def from_file!(filename), do: load_file(filename, true, [])
  def from_file!(filename, bindings), do: load_file(filename, true, bindings)

  def load_file(filename, allow_unsafe, bindings) do
    {:ok, file} = File.read filename
    safe = check_if_safe(file)

    cond do
      allow_unsafe ->
        {contents, results} = Code.eval_string(file, bindings)
        map = Map.merge %{}, contents
        {:ok, map}
      safe ->
        {contents, results} = Code.eval_string(file, [])
        map = Map.merge %{}, contents
        {:ok, map}
      true ->
        {:error, "#{filename} contains unsafe data. Load with Peon.from_file! to ignore this."}
    end
  end

  def to_file(map, filename) do
    map = Map.merge(%{}, map)
    contents =  Macro.to_string(quote do: unquote(map))
    {:ok, file} = File.open filename, [:write]
    IO.binwrite file, contents
    {:ok, filename}
  end

  def check_if_safe(file) do
    {:ok, contents} = Code.string_to_quoted(file)
    root = elem(contents, 2)
    root |> Enum.map(&is_safe?/1)
         |> List.flatten
         |> Enum.all?(&(&1))
  end

  def is_safe?(value) do
    case value do
      {key, {expression, line, value}} ->
        if expression != :{} and expression != :%{} do
          false
        else
          result = value |> Enum.filter(&(is_tuple(&1)))
                         |> Enum.map(&is_safe?/1)
        end
      {key, value} when is_list(value) ->
        only_tuples = value |> Enum.filter(&(is_tuple(&1)))
        results = only_tuples |> Enum.map(&is_safe?/1)
        Enum.all?(results, &(&1))
      {expression, line, value} ->
        expression == :{} or expression == :%{}
      _ ->
        true
    end
  end
end
