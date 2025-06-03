defmodule Difftastic.Assertions do
  defmacro difft_assert_equal(value1, value2, opts \\ []) do
    format = Keyword.get(opts, :format, :ex)

    quote do
      left = unquote(value1)
      right = unquote(value2)

      cond do
        not Difftastic.available?() ->
          assert left == right

        left != right ->
          message = Difftastic.diff(left, right, unquote(format))
          flunk(message)

        true ->
          assert true
      end
    end
  end

  defmacro difft_assert_against_file(value, file_path) do
    quote do
      file_contents = File.read!(unquote(file_path))

      cond do
        not Difftastic.available?() ->
          assert unquote(value) == file_contents

        unquote(value) != file_contents ->
          message = Difftastic.diff_with_file(unquote(value), unquote(file_path))
          flunk(message)

        true ->
          assert true
      end
    end
  end
end
