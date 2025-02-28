defmodule Difftastic.Tempfile do
  @doc """
  Creates a temporary file with the given extension and content.
  Returns the full path to the created file.
  """
  def create(ext, content) when is_binary(content) do
    tmp_dir = System.tmp_dir!()
    random_name = :crypto.strong_rand_bytes(16) |> Base.encode16(case: :lower)
    filename = Path.join(tmp_dir, "difftastic-ex-#{random_name}.#{ext}")

    File.write!(filename, content)
    filename
  end
end
