defmodule Difftastic.TempfileTest do
  use ExUnit.Case

  describe "create/2" do
    test "create tempfile with a correct extension" do
      filename = Difftastic.Tempfile.create("ex", "")
      assert Path.extname(filename) == ".ex"
    end

    test "write content to a temporary file" do
      filename = Difftastic.Tempfile.create("html", "<div></div>")
      assert {:ok, content} = File.read(filename)
      assert content == "<div></div>"
      File.rm(filename)
    end
  end
end
