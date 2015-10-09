defmodule Peon do
  def from_file(filename), do: from_file(filename, [])
  def from_file(filename, bindings) do
    {:ok, file} = File.read filename
    {contents, results} = Code.eval_string(file, bindings)
    map = Map.merge %{}, contents
    {:ok, map}
  end

  def to_file(map, filename) do
    map = Map.merge(%{}, map)
    contents =  Macro.to_string(quote do: unquote(map))
    {:ok, file} = File.open filename, [:write]
    IO.binwrite file, contents
    {:ok, filename}
  end
end
