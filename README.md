# Adt

A small/light ADT module for Elixir.

## Installation

The package can be installed as:

  1. Add adt to your list of dependencies in `mix.exs`:

        def deps do
          [{:adt, "~> 0.0.1"}]
        end

## Usage

You can define your ADTs this way:

```elixir
defmodule MyModule do
  ADT.define foo(a: 0) | bar(val: "hey")
end

%MyModule.Foo{a: 1}
```
