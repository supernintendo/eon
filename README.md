# EON

EON (**E**lixir **O**bject **N**otation) allows you to use Elixir data structures as a document storage format.

[![Build Status](https://travis-ci.org/supernintendo/peon.svg?branch=master)](https://travis-ci.org/supernintendo/eon)
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

`from_file` will return an error tuple when attempting to load a file that could execute arbitrary code. Any map which contains an expression tuple starting with any value other than `:{}` or `%{}` is rejected.

You can bypass this using `EON.from_file_unsafe`. This function also allows passing a keyword list as a second argument, which binds unbound variables in the loaded file. For example, given the following file `unsafe.eon`:

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
