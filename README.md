# EON

EON (**E**lixir **O**bject **N**otation) allows you to use Elixir data structures as a document storage format.

[![Build Status](https://travis-ci.org/supernintendo/eon.svg)](https://travis-ci.org/supernintendo/eon)
[![Hex.pm](https://img.shields.io/hexpm/v/eon.svg?style=flat)](https://hex.pm/packages/eon/3.0.0)
[![Hex.pm](https://img.shields.io/hexpm/dt/eon.svg?style=flat)](https://hex.pm/packages/eon/3.0.0)

## Usage

Add to your mix.exs:

`{:eon, "~> 3.0"}`

Use `&to_file/2` and `&from_file/1` to write and read maps respectively:

```elixir
data = %{
  hello: {"world", 42, :foo}
}
filename = "data.eon"
{:ok, filename} = EON.to_file(data, filename)
{:ok, data} = EON.from_file("data.eon")

```

## Safety

`from_file` will return an error tuple when attempting to load a .eon file that could execute arbitrary code. Loaded files produce an AST which is considered unsafe if at least one of the AST's expression tuples contains a `:{}` or `%{}` as its first element. This effectively limits loaded files to native Elixir data structures and constant values (numbers, atoms and so on).

You can bypass the safety check using `EON.from_file_unsafe`. This function also takes a keyword list as its second argument. Unbound variables will be bound according to the key value pairs within this list. For example, given the following file `unsafe.eon`:

```elixir
%{
  group: :users,
  language: String.capitalize(language),
  name: name
}
```

...the following will return `true`:

```elixir
{:ok, data} = EON.from_file_unsafe("unsafe.eon", [name: "José Valim", language: "elixir"])

Map.equal?(%{
  group: :users,
  language: "Elixir",
  name: "José Valim"
}
```

## License
[Apache License 2.0](LICENSE.md)
