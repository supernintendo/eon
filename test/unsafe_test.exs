defmodule PeonTest.Unsafe do
  use ExUnit.Case

  test "trying to load an unsafe .peon file without !" do
    {status, _} = Peon.from_file("test/fixtures/unsafe.peon")
    assert status == :error
  end

  test "loading an unsafe .peon file" do
    {:ok, data} = Peon.from_file!("test/fixtures/unsafe.peon")
  end
end
