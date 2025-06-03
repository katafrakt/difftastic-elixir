defmodule Difftastic.AssertionsTest do
  use ExUnit.Case
  import Difftastic.Assertions

  describe "difft_assert_equal/3" do
    test "passe when values are equal" do
      assert difft_assert_equal("hello", "hello") == true
    end

    test "fail when values differ" do
      assert_raise ExUnit.AssertionError, fn ->
        difft_assert_equal("hello", "world")
      end
    end
  end

  describe "difft_match_against_file/2" do
    test "pass when values are equal" do
      assert difft_assert_against_file(
               ~s({ "hello": "world", "greeting": true }\n),
               "test/support/hello_world.json"
             )
    end

    test "fail when values differ" do
      assert_raise ExUnit.AssertionError, fn ->
        assert difft_assert_against_file(
                 ~s({ "hello": "world", "greeting": false }\n),
                 "test/support/hello_world.json"
               )
      end
    end
  end
end
