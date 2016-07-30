# Adt

A small/light ADT module for Elixir.

## Installation

The package can be installed as:

  1. Add adt to your list of dependencies in `mix.exs`:

        def deps do
          [{:adt, "~> 0.0.1"}]
        end

## Usage

### Definitions

You can define your ADTs this way:

```elixir
defmodule MyModule do
  ADT.define foo(a: 0) | bar(val: "hey")
end

%MyModule.Foo{a: 1}
```

### Case statement

You can use the `case` macro to interact with ADTs:

```elixir
value = %MyModule.Bar{}

result = MyModule.case value, [
  Foo: fn(x) -> x + 1 end,
  Bar: fn(x) -> x.val <> " there" end
]

# assert result == "hey there"
```

The case statement can detect when you don't provide enough statements. For example the following will not **expand**:

```elixir
value = %MyModule.Bar{}

result = MyModule.case value, [
  Foo: fn(x) -> x + 1 end
]

# This fails at build time with:
# case macro not exhaustive.\nGiven [\"Foo\"].\nPossible: [\"Bar\", \"Foo\"].
```
