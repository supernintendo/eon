defmodule EonTest.Eon do
  use ExUnit.Case

  setup do
    # Set up an ETS table for the read_unsafe
    # test to pollute
    :ets.new(:eon_test_bucket, [:named_table])

    :ok
  end

  test "loading data from a string" do
    string = ~s(
      %{
        id: 1,
        name: "Salad",
        ingredients: [
          :spinach,
          :tomatoes,
          :raddichio
        ]
      }
    )
    {:ok, data_a} = Eon.from_string(string)
    data_b = Eon.from_string!(string)
    spec = %{
      id: 1,
      name: "Salad",
      ingredients: [
        :spinach,
        :tomatoes,
        :raddichio
      ]
    }
    assert Map.equal?(data_a, spec)
    assert Map.equal?(data_b, spec)
  end

  test "rejecting to load data from an unsafe string" do
    {status, _} = Eon.from_string("%{ num: Enum.random(1..100) }")

    assert status == :error
    assert_raise Eon.Error, fn ->
      Eon.from_string!("%{ num: Enum.random(1..100) }")
    end
  end

  test "loading data from an unsafe string" do
    {:ok, data_a} = Eon.from_string_unsafe("%{ math: 4 * 4}")
    data_b = Eon.from_string_unsafe!("%{ math: 4 * 4}")

    assert data_a.math == 16
    assert data_b.math == 16
  end

  test "loading bad data from an unsafe string" do
    {status, _} = Eon.from_string("bad_data")

    assert status == :error
    assert_raise CompileError, fn -> Eon.from_string_unsafe!("bad_data") end
    assert_raise SyntaxError, fn -> Eon.from_string_unsafe!("${}") end
  end

  test "loading data with interpolated values" do
    {:ok, data_a} = Eon.from_string_unsafe(%{bar: 42}, "%{ foo: bar }")
    data_b = Eon.from_string_unsafe!(%{bar: 42}, "%{ foo: bar }")

    assert data_a.foo == 42
    assert data_b.foo == 42
  end

  test "loading data from an .exs file" do
    {:ok, data} = Eon.read("test/fixtures/basic.exs")
    spec = %{ hello: "world" }

    assert Map.equal?(data, spec)
  end

  test "trying to load an unsafe .eon file" do
    {status, _} = Eon.read("test/fixtures/unsafe.exs")

    assert status == :error
  end

  test "loading files with !" do
    assert Eon.read!("test/fixtures/basic.exs")
    assert_raise Eon.Error, fn -> Eon.read!("test/fixtures/unsafe.exs") end
  end

  test "loading an unsafe .exs file" do
    {:ok, data} = Eon.read_unsafe("test/fixtures/unsafe.exs")

    assert data.math == 16
    assert [{"unsafe", data.func}] == :ets.lookup(:eon_test_bucket, "unsafe")
  end

  test "interpolating values into a loaded .exs file" do
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
