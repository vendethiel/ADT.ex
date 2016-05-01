defmodule ADT do
  @moduledoc """
  Pseudo-ADT definition generator
  """

  @doc """
  Use it like this:

    > ADT.define foo(a: "default") | bar(b: "value")
    > %Foo{a:"value"}
    %Foo{a: "value"}
  """
  defmacro define(parts) do
    parts |> format_parts(__CALLER__) |> Enum.map(&generate_defmodule/1)
  end

  # Flatten "one | two | three" ("one | (two | three)" in the AST
  # to "[one, two, three]"
  defp format_parts({:|, _, [elem, rest]}, caller) do
    format_parts(elem, caller) ++ format_parts(rest, caller)
  end
  defp format_parts({name, _, [content]}, caller) do
    # name is lowercase atom, need to capitalize + re-atom
    # fields is [name: val, name: val]
    module_name = name |> to_string |> format_module_name
    # then, generate a module name from the string
    module_name = Module.concat([caller.module, module_name])

    [{module_name, content}]
  end
  defp format_parts({name, _, []}, _) do
    raise "Unable to generate ADT variant #{name}: no fields declared"
  end

  # Generates an AST for the module definition
  # based on the ADT alternative, like:
  #
  #  foo(a: "default")
  defp generate_defmodule({name, fields}) do
    quote do
      defmodule unquote(name) do
        defstruct unquote(fields)
      end
    end
  end

  # Helper code that really shouldn't be here.
  # Transforms "foo_bar" to "FooBar"
  defp format_module_name(str) do
    Regex.replace(~r/_([a-z])/, String.capitalize(str),
      fn _, l -> String.upcase(l) end)
  end
end
