# Peon

Peon (**P**ure **E**lixir **O**bject **N**otation) allows you to use native Elixir data structures as a document storage format.

[![Build Status](https://travis-ci.org/supernintendo/peon.svg?branch=master)](https://travis-ci.org/supernintendo/peon)
[![Hex.pm](https://img.shields.io/hexpm/v/peon.svg?style=flat)](https://hex.pm/packages/peon/1.0.0)
[![Hex.pm](https://img.shields.io/hexpm/dt/peon.svg?style=flat)](https://hex.pm/packages/peon/1.0.0)

## Usage

Maps can be written to and read from files using `&to_file/2` and `&from_file/1` respectively:

```elixir
data = %{
  hello: {"world", 42, :foo}
}
filename = "data.peon"
{:ok, filename} = Peon.to_file(data, filename)
{:ok, data} = Peon.from_file("data.peon")

```

## Safety

`from_file` will return `{:error, message}` when attempting to load a file that could execute arbitrary code. Peon traverses a map's AST and rejects it if it finds any expression tuple that doesn't have `:{}` or `%{}` as its first element.

You can bypass this using `Peon.from_file_unsafe`. This function also allows passing a keyword list as a second argument, which is used to bind unbound variables found in the loaded file. For example, given the following file `unsafe.peon`:

```elixir
%{
  group: :users,
  language: String.capitalize(language),
  name: name
}
```

...the following will return `true`:

```elixir
{:ok, data} = Peon.from_file_unsafe("unsafe.peon", [name: "José Valim", language: "elixir"])

Map.equal?(%{
  group: :users,
  language: "Elixir",
  name: "José Valim"
}
```

## License
MIT
