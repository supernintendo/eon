# Peon

Peon (**P**ure **E**lixir **O**bject **N**otation) is a simple library for using Elixir maps as a document storage format. Maps are simply saved and loaded as files without the need to encode or decode.

[![Build Status](https://travis-ci.org/supernintendo/peon.svg?branch=master)](https://travis-ci.org/supernintendo/peon)
[![Hex.pm](https://img.shields.io/hexpm/v/peon.svg?style=flat)](https://hex.pm/packages/peon/1.0.0)
[![Hex.pm](https://img.shields.io/hexpm/dt/peon.svg?style=flat)](https://hex.pm/packages/peon/1.0.0)

## Usage

Map data can be written to and read from files with the `.peon` extension:

```elixir
data = %{
  hello: {"world", 42, :foo}
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

```elixir
{:ok, data} = Peon.from_file("unbound.peon", [name: "Yoshimi P-We", age: 47])
Map.equal?(data, %{
  name: "Yoshimi P-We",
  age: 47,
  group: :users
}
```

## License
MIT
