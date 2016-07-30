defmodule AdtTest do
  use ExUnit.Case
  doctest ADT

  defmodule AdtDefinition do
    ADT.define foo(a: 0) | bar(val: "hey")
  end

  defmodule AdtDefinitionThree do
    ADT.define foo(a: 0) | bar(val: "hey") | baz
  end

  defmodule AdtWithVariantWithoutFields do
    ADT.define foo(a: 0) | bar
  end

  test "creating an ADT instance" do
    foo = %AdtDefinition.Foo{a: 1}
    assert foo.a == 1

    bar = %AdtDefinition.Bar{val: "salut"}
    assert bar.val == "salut"
  end

  test "check the ADT is namespaced correctly" do
    catch_error Code.compile_string "%Foo{}"
    catch_error Code.compile_string "%AdtTest.Foo{}"

    catch_error Code.compile_string "%Bar{}"
    catch_error Code.compile_string "%AdtTest.Bar{}"
  end

  test "the ADT has the correct default values" do
    foo = %AdtDefinition.Foo{}
    assert foo.a == 0

    bar = %AdtDefinition.Bar{}
    assert bar.val == "hey"
  end

  test "creating an ADT instance for variants without fields" do
    assert Code.ensure_loaded?(AdtWithVariantWithoutFields.Bar)
    assert %AdtWithVariantWithoutFields.Foo{a: 1}.a == 1
  end

  test "an empty ADT is forbidden" do
    catch_error(Code.compile_quoted do
      ADT.define
    end)
  end

  test "getting variants from the Module" do
    assert AdtDefinition.variants == [AdtTest.AdtDefinition.Bar, AdtTest.AdtDefinition.Foo]
    assert AdtDefinitionThree.variants == [AdtTest.AdtDefinitionThree.Baz, AdtTest.AdtDefinitionThree.Bar, AdtTest.AdtDefinitionThree.Foo]
  end

  test "case" do
    require AdtTest.AdtDefinition

    foo = %AdtDefinition.Foo{}

    result = AdtDefinition.case foo, [
      Foo: fn(_) -> "1" end,
      Bar: fn(_) -> "2" end
    ]
    assert result == "1"

    bar = %AdtDefinition.Bar{}

    result = AdtDefinition.case bar, [
      Foo: fn(_) -> "1" end,
      Bar: fn(x) -> x.val <> " there" end
    ]
    assert result == "hey there"
  end

  test "non-exhaustive case" do
    error = catch_error Code.eval_string """
      require AdtTest.AdtDefinition

      result = AdtTest.AdtDefinition.case %AdtTest.AdtDefinition.Foo{}, [
        Foo: fn(x) -> "foo" end
      ]
    """
    assert error.message == "case macro not exhaustive.\nGiven [\"Foo\"].\nPossible: [\"Bar\", \"Foo\"]."
  end

  test "dead code in case statement" do
    error = catch_error Code.eval_string """
      require AdtTest.AdtDefinition

      result = AdtTest.AdtDefinition.case %AdtTest.AdtDefinition.Foo{}, [
        Foo: fn(x) -> "1" end,
        Bar: fn(x) -> "2" end,
        Baz: fn(x) -> "3" end
      ]
    """
    assert error.message == "case macro not exhaustive.\nGiven [\"Bar\", \"Baz\", \"Foo\"].\nPossible: [\"Bar\", \"Foo\"]."
  end

  test "case statement with no options" do
    error = catch_error Code.eval_string """
      require AdtTest.AdtDefinition

      result = AdtTest.AdtDefinition.case %AdtTest.AdtDefinition.Foo{}, []
    """
    assert error.message == "case macro not exhaustive.\nGiven [].\nPossible: [\"Bar\", \"Foo\"]."
  end

  test "case statement with missing second param" do
    error = catch_error Code.eval_string """
      require AdtTest.AdtDefinition

      result = AdtTest.AdtDefinition.case %AdtTest.AdtDefinition.Foo{}
    """
    assert error.message == "case macro not exhaustive.\nGiven [].\nPossible: [\"Bar\", \"Foo\"]."
  end

  test "you can pattern match an ADT" do
    foo = %AdtDefinition.Foo{}
    assert 0 == (case foo do
      %AdtDefinition.Foo{a: a} -> a
      _ -> false
    end)
  end
end
