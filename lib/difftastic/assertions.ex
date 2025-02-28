defmodule Difftastic.Assertions do
  defmacro difft_assert_equal(value1, value2, opts \\ []) do
    format = Keyword.get(opts, :format, :ex)

    quote do
      left = unquote(value1)
      right = unquote(value2)

      if(left != right) do
        message = Difftastic.diff(left, right, unquote(format))
        flunk(message)
      else
        assert true
      end
    end
  end
end
