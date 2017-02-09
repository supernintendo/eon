defmodule EonTest.Eon do
  use ExUnit.Case

  setup do
    # Set up an ETS table for the read_unsafe
    # test to use.
    :ets.new(:eon_test_bucket, [:named_table])

    :ok
  end

  test "trying to load an unsafe .eon file without !" do
    {status, _} = Eon.read("test/fixtures/unsafe.exs")

    assert status == :error
  end

  test "loading an unsafe .exs file" do
    {:ok, data} = Eon.read_unsafe("test/fixtures/unsafe.exs")

    assert data.math == 16
    assert [{"unsafe", data.func}] == :ets.lookup(:eon_test_bucket, "unsafe")
  end

  test "loading data from an .exs file" do
    {:ok, data} = Eon.read("test/fixtures/basic.exs")
    spec = %{ hello: "world" }

    assert Map.equal?(data, spec)
  end

  test "interpolating values" do
    {:ok, data} = Eon.read_unsafe(%{bar: 42}, "test/fixtures/bindings.exs")

    assert data.foo == 42
  end

  test "different types" do
    {:ok, data} = Eon.read("test/fixtures/types.exs")

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

  test "writing a map to an .exs file" do
    filename = "test/fixtures/foo.temp.exs"
    map = %{ foo: "bar" }
    Eon.write(map, filename)
    result = Eon.read(filename)

    assert elem(result, 0) == :ok
    assert Map.equal?(elem(result, 1), map)
  end
end