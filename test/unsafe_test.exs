defmodule EONTest.Unsafe do
  use ExUnit.Case

  test "trying to load an unsafe .eon file without !" do
    {status, _} = EON.from_file("test/fixtures/unsafe.eon")
    assert status == :error
  end

  test "loading an unsafe .eon file" do
    {:ok, data} = EON.from_file_unsafe("test/fixtures/unsafe.eon")
  end
end
