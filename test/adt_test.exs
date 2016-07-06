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
end
