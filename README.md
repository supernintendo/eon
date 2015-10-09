# Peon

Peon is a simple library for using Elixir maps as a document storage format. Maps are simply saved and loaded as files without the need to encode or decode.

## Usage

Map data can be written to and read from files with the `.peon` extension:

```elixir
data = %{
  integer: 1,
  float: 1.0,
  number: 0x1F,
  string: "foo",
  bool: true,
  atom: :foo,
  nothing: nil,
  list: ["foo", "bar", 1, 2],
  tuple: {"lorem", "ipsum", 3, 4},
  map: %{
    hello => "world"
  }
}
filename = "data.peon"
{:ok, filename} = Peon.to_file(data, filename)
{:ok, data} = Peon.from_file("data.peon")

```

Unbound variables are allowed and can be bound when read. For example, given the following file `unbound.peon`:

```elixir
%{
  group: :users,
  name: name,
  age: age
}
```

The following will produce `true`:

```
{:ok, data} = Peon.from_file("unbound.peon", [name: "Yoshimi P-We", age: 47])
Map.equal?(data, %{
  name: "Yoshimi P-We",
  age: 47,
  group: :users
}
```

## License
MIT