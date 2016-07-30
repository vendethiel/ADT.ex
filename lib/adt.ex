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
    parts |> format_parts(__CALLER__) |> generate_code
  end

  defp generate_code(values) do
    variants_definition = quote do
      Module.register_attribute __MODULE__, :variants, accumulate: true
    end
    variants_reader = quote do
      def variants do
        @variants
      end
    end
    modules = values |> Enum.map(&generate_defmodule/1)
    Enum.concat([[variants_definition], modules, [variants_reader, case_macro(values)]])
  end

  defp case_macro(values) do
    quote do
      defmacro case(a, statements \\ []) do
        possible_variants = unquote(values) |> Enum.map(
          fn {variant, _} ->
            ADT._shorten(variant)
          end
        ) |> Enum.sort
        given_variants = statements |> Enum.map(fn {k, v} -> { to_string(k), v } end) |> Enum.sort
        given_variant_names = given_variants |> Enum.map(fn {k, _} -> k end)
        if possible_variants != given_variant_names do
          raise ADT._exhaustive_error(possible_variants, given_variant_names)
        end
        rules = Enum.flat_map(given_variants, fn {k, v} ->
          quote do
            unquote(k) == ADT._shorten(unquote(a)) -> unquote(v).(unquote(a))
          end
        end)
        quote do
          cond do: unquote(rules)
        end
      end
    end
  end

  # Maps a module like Foo.Bar.Baz into a short string "Baz"
  def _shorten(name) do
    Regex.named_captures(~r/\.(?<short>[^.{]+)($|{)/, inspect(name), include_captures: true) |> Map.fetch!("short")
  end

  def _exhaustive_error(possible_variants, given_variants) do
    "case macro not exhaustive.\nGiven #{inspect(given_variants)}.\nPossible: #{inspect(possible_variants)}."
  end

  # Flatten "one | two | three" ("one | (two | three)" in the AST
  # to "[one, two, three]"
  defp format_parts({:|, _, [elem, rest]}, caller) do
    format_parts(elem, caller) ++ format_parts(rest, caller)
  end
  defp format_parts({name, _, [content]}, caller) do
    [{create_full_name(name, caller), content}]
  end
  defp format_parts({name, _, _}, caller) do
    [{create_full_name(name, caller), []}]
  end

  # Generates an AST for the module definition
  # based on the ADT alternative, like:
  #
  #  foo(a: "default")
  defp generate_defmodule({name, fields}) do
    quote do
      @variants unquote(name)
      defmodule unquote(name) do
        defstruct unquote(fields)
      end
    end
  end

  defp create_full_name(name, caller) do
    # name is lowercase atom, need to capitalize + re-atom
    # fields is [name: val, name: val]
    module_name = name |> to_string |> format_module_name
    # then, generate a module name from the string
    Module.concat([caller.module, module_name])
  end

  # Helper code that really shouldn't be here.
  # Transforms "foo_bar" to "FooBar"
  defp format_module_name(str) do
    Regex.replace(~r/_([a-z])/, String.capitalize(str),
      fn _, l -> String.upcase(l) end)
  end
end
