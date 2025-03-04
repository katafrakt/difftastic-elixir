defmodule DifftasticTest do
  use ExUnit.Case

  describe "diff/3" do
    test "diff same elixir values" do
      diff = Difftastic.diff([a: 1, b: nil], [a: 1, b: nil], "ex")
      assert diff == "\e[1m\e[93m\e[39m\e[0m\e[2m --- Elixir\e[0m\nNo changes.\n\n"
    end
  end
end
