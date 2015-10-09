defmodule PeonTest.Writing do
  use ExUnit.Case

  test "writing a map to a .peon file" do
    filename = "test/fixtures/foo.temp.peon"
    map = %{
      foo: "bar"
    }
    {:ok, filename} = Peon.to_file map, filename
    {:ok, read} = Peon.from_file filename
    assert Map.equal?(read, map)
  end
end
