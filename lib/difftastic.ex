defmodule Difftastic do
  @moduledoc """
  Documentation for `Difftastic`.
  """

  @doc """
  Returns whether or not the Difftastic binary is available.
  """
  @spec available? :: boolean()
  def available?, do: Difftastic.CLI.available?()

  @doc """
  Runs a diff for two provided values in a given `format`. If any of them is not a string,
  it gets `inspect`ed first.
  """
  @spec diff(any(), any(), String.t()) :: String.t()
  def diff(value1, value2, format)

  def diff(v1, v2, format) when not is_binary(v1) do
    diff(inspect(v1, pretty: true), v2, format)
  end

  def diff(v1, v2, format) when not is_binary(v2) do
    diff(v1, inspect(v2, pretty: true), format)
  end

  def diff(str1, str2, format) do
    t1 = Difftastic.Tempfile.create(format, str1)
    t2 = Difftastic.Tempfile.create(format, str2)

    case Difftastic.CLI.run(t1, t2) do
      {:ok, result} -> result
      {:error, error} -> inspect(error)
    end
    |> tap(fn _ ->
      File.rm(t1)
      File.rm(t2)
    end)
  end
end
