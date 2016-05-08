defmodule EONTest.Writing do
  use ExUnit.Case

  test "writing a map to an .eon file" do
    filename = "test/fixtures/foo.temp.eon"
    map = %{
      foo: "bar"
    }
    {:ok, filename} = EON.to_file(map, filename)
    {:ok, read} = EON.from_file(filename)
    assert Map.equal?(read, map)
  end
end
