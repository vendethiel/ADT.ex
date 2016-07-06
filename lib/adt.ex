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

  defmacro case(adt, name, [do: cases]) do
    #Code.ensure_loaded?(adt) # XXX something like this
    mentioned = Enum.reduce(cases, [], fn (caze, mentioned_acc) ->
      # note: head must have size=1. we only support "a -> x", not "a, b -> x"
      {:->, _, [[match], _body]} = caze
      # extract the name in "%Foo{}"
      if elem(match, 0) == :_ do
        IO.puts "catch all"
        [:_ | mentioned_acc] # this should act as a catch-all
      else
        # aliased_name will look like {:__aliases__, [...], [:NS, :NS2, :Module]}
        {:%, _, [aliased_name | _]} = match
        # not sure there's a more common mechanism to extract the name..?
        {:__aliases__, _, name_parts} = aliased_name # parts is an array i.e. [:ADT, :Variant]
        IO.puts "add named"
        IO.inspect name_parts
        [name_parts | mentioned_acc]
        end
    end)
    IO.puts "yo"
    IO.inspect mentioned
    quote do
      case unquote(name), do: unquote(cases)
    end
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
    Enum.concat([[variants_definition], modules, [variants_reader]])
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
