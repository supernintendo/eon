defmodule PeonTest.Reading do
  use ExUnit.Case

  test "loading data from a .peon file" do
    {:ok, data} = Peon.from_file("test/fixtures/basic.peon")
    spec = %{
      hello: "world"
    }
    assert Map.equal?(data, spec)
  end

  test "interpolating values" do
    {:ok, data} = Peon.from_file_unsafe("test/fixtures/bindings.peon", [bar: 42])
    assert data.foo == 42
  end

  test "different types" do
    {:ok, data} = Peon.from_file("test/fixtures/types.peon")

    assert is_integer data.integer
    assert is_float data.float
    assert is_number data.number
    assert is_binary data.string
    assert is_boolean data.bool
    assert is_atom data.atom
    assert is_nil data.nothing
    assert is_list data.list
    assert is_tuple data.tuple
    assert is_map data.map
  end
end
