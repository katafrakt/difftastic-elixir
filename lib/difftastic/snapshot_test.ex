defmodule Difftastic.SnapshotTest do
  @moduledoc """
  Provides snapshot testing functionality using Difftastic for rendering diffs.

  ## Usage

  First, use the module in your test file and specify a directory for snapshots:

  ```elixir
  use Difftastic.SnapshotTest, dir: "path/to/snapshots"
  ```

  Then, in your tests, use `assert_snapshot_match/2` to compare values with snapshots:

  ```elixir
  test "email renders correctly" do
    html = EmailRenderer.render_template(:welcome, user: user)
    assert_snapshot_match("welcome_email.html", html)
  end

  test "JSON API response is correct" do
    json = MyAPI.get_data() |> Jason.encode!(pretty: true)
    assert_snapshot_match("api_response.json", json)
  end
  ```

  ## How It Works

  - If the snapshot file doesn't exist, it will be created automatically.
  - If it exists, the contents will be compared with the current value.
  - When the values don't match, Difftastic is used to generate a visual diff.
  - Non-string values are automatically pretty-printed using `inspect/2`.

  ## Updating Snapshots

  When you intentionally change the expected output, run tests with:

  ```bash
  UPDATE_SNAPSHOTS=1 mix test
  ```

  This will update all snapshots with the current output values.

  ## File Format and Storage

  - Snapshots are stored as plain text files in the specified directory.
  - The file extension is used to determine the syntax highlighting in diffs.
  - Snapshots should be committed to version control.
  """
  require Difftastic.Assertions

  defmacro __using__(opts) do
    quote do
      require ExUnit.Assertions
      import Difftastic.SnapshotTest, only: [assert_snapshot_match: 2, assert_snapshot_match: 3]

      @difftastic_snapshot_dir unquote(opts)[:dir] || "test/snapshots"
    end
  end

  @doc """
  Compares content with a snapshot file.

  Creates the snapshot file if it doesn't exist. If it exists, compares the content
  using Difftastic and fails the test if they don't match.

  ## Parameters
    - name: Name of the snapshot file
    - content: Content to compare or save
    - opts: Options for snapshot comparison

  ## Options
    - :format - Format to use for diff (default is derived from file extension)
  """
  defmacro assert_snapshot_match(name, content, opts \\ []) do
    quote bind_quoted: [name: name, content: content, opts: opts] do
      snapshot_dir = @difftastic_snapshot_dir
      Difftastic.SnapshotTest.__match_snapshot__(name, content, opts, snapshot_dir)
    end
  end

  @doc false
  def __match_snapshot__(name, content, _opts, snapshot_dir) do
    snapshot_path = Path.join(snapshot_dir, name)
    File.mkdir_p!(Path.dirname(snapshot_path))

    update_snapshots? = System.get_env("UPDATE_SNAPSHOTS") == "1"
    content_str = if is_binary(content), do: content, else: inspect(content, pretty: true)

    cond do
      not File.exists?(snapshot_path) ->
        write_snapshot(snapshot_path, content_str)
        ExUnit.Assertions.assert(true, "Created new snapshot at #{snapshot_path}")

      update_snapshots? ->
        write_snapshot(snapshot_path, content_str)
        ExUnit.Assertions.assert(true, "Updated snapshot at #{snapshot_path}")

      true ->
        compare_snapshot(snapshot_path, content_str, name)
    end
  end

  defp write_snapshot(path, content) do
    File.write!(path, content)
  end

  defp compare_snapshot(path, content, name) do
    snapshot_content = File.read!(path)

    if snapshot_content == content do
      ExUnit.Assertions.assert(true, "Snapshot matches")
    else
      if Difftastic.available?() do
        diff_output = Difftastic.diff_with_file(content, path)

        ExUnit.Assertions.flunk("""
        Snapshot #{name} does not match:

        #{diff_output}
        """)
      else
        ExUnit.Assertions.assert(content == snapshot_content, """
        Snapshot #{name} does not match but Difftastic is not available.
        """)
      end
    end
  end
end
