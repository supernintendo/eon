defmodule EONTest.Reading do
  use ExUnit.Case

  test "loading data from an .eon file" do
    {:ok, data} = EON.from_file("test/fixtures/basic.eon")
    spec = %{
      hello: "world"
    }
    assert Map.equal?(data, spec)
  end

  test "interpolating values" do
    {:ok, data} = EON.from_file_unsafe("test/fixtures/bindings.eon", [bar: 42])
    assert data.foo == 42
  end

  test "different types" do
    {:ok, data} = EON.from_file("test/fixtures/types.eon")

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
