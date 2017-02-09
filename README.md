# Eon

Eon (**E**lixir **O**bject **N**otation) allows you to
use Elixir data structures as a document storage format.

[![Build Status](https://travis-ci.org/supernintendo/eon.svg)](https://travis-ci.org/supernintendo/eon)
[![Hex.pm](https://img.shields.io/hexpm/v/eon.svg?style=flat)](https://hex.pm/packages/eon/3.0.0)
[![Hex.pm](https://img.shields.io/hexpm/dt/eon.svg?style=flat)](https://hex.pm/packages/eon/3.0.0)

## Usage

Add to your mix.exs:

`{:eon, "~> 4.0"}`

Use `&write/2` / `&write!/2` and `&read/1` / `&read!/1` to
write and read maps respectively:

```elixir
data = %{
  time: 1485508490,
  type: "message",
  value: "Hello world."
}

data |> Eon.write("hello.exs")
{:ok, data} = Eon.read("hello.exs")
```

## Safety

`read` will return an error when attempting to load a file
that could execute arbitrary code. Evaluated files produce
an AST which is considered unsafe if at least one of the
AST's expression tuples contains a `:{}` or `%{}` as its
first element. This limits loaded files to native Elixir
data structures and constant values (numbers, atoms and
so on).

You can bypass the safety check using `Eon.read_unsafe/1`
and `Eon.read_unsafe!/1`. There are also counterparts to
both of these functions that have an arity of 2. These
functions take a map as the first argument and the filename
as the second argument. Unbound variables within the loaded
file will be bound according to key value pairs within the
map that is provided. For example, given the following file:

```elixir
# myuser.exs
%{
  group: :users,
  home: String.capitalize(home),
  name: name
}
```

...the following comparison will return `true`:

```elixir
result =
  %{ home: "hyrule", name: "Link" }
  |> Eon.read_unsafe("myuser.exs")

Map.equal?(result, %{
  group: :users,
  home: "Hyrule",
  name: "Link"
})
```

**Do not** use the unsafe functions for unsanitized user
data. Because files loaded with Eon are compiled into
runtime code, it is generally a good idea to apply this
same rule even to `read/1` and `read!/1`. The best use
cases for Eon are for data you trust - configuration
files, data shared between controlled nodes, etc.

## License

Eon is free software released under the [Apache License 2.0](LICENSE.md).
