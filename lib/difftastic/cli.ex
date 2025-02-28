defmodule Difftastic.CLI do
  @doc """
  Checks if `difft` executable is available.
  """
  def available? do
    case System.cmd("difft", ["--version"], stderr_to_stdout: true) do
      {_output, 0} -> true
      _ -> false
    end
  rescue
    # Handle case where the executable is not found
    ErlangError -> false
  end

  @doc """
  Runs difft on two files and returns the result.

  ## Parameters
    - file1: Path to the first file
    - file2: Path to the second file
    
  ## Returns
    - {output, exit_code} tuple from System.cmd
  """
  def run(file1, file2) do
    case System.cmd("difft", [file1, file2, "--color=always", "--display=inline"],
           stderr_to_stdout: true
         ) do
      {result, 0} ->
        {:ok, result |> String.replace(file1, "") |> String.replace(file2, "")}

      {error, _} ->
        {:error, error}
    end
  end
end
