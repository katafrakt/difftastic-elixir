defmodule Difftastic.SnapshotTestTest do
  use ExUnit.Case

  @snapshot_dir Path.join(System.tmp_dir!(), "difftastic_snapshot_test_#{:os.system_time()}")

  use Difftastic.SnapshotTest, dir: @snapshot_dir

  setup do
    File.mkdir_p!(@snapshot_dir)

    on_exit(fn ->
      File.rm_rf!(@snapshot_dir)
    end)

    :ok
  end

  describe "assert_snapshot_match/2" do
    test "create a new snapshot when it doesn't exist" do
      snapshot_name = "new_snapshot.txt"
      snapshot_content = "This is a new snapshot"
      snapshot_path = Path.join(@snapshot_dir, snapshot_name)

      refute File.exists?(snapshot_path)

      assert_snapshot_match(snapshot_name, snapshot_content)

      assert File.exists?(snapshot_path)
      assert File.read!(snapshot_path) == snapshot_content
    end

    test "pass when snapshot matches" do
      snapshot_name = "matching_snapshot.txt"
      snapshot_content = "This content should match"
      snapshot_path = Path.join(@snapshot_dir, snapshot_name)

      File.write!(snapshot_path, snapshot_content)

      assert_snapshot_match(snapshot_name, snapshot_content)
    end

    test "handle non-string content by inspecting it" do
      snapshot_name = "map_snapshot.txt"
      snapshot_content = %{foo: "bar", baz: 123}
      snapshot_path = Path.join(@snapshot_dir, snapshot_name)

      assert_snapshot_match(snapshot_name, snapshot_content)

      assert File.exists?(snapshot_path)
      assert File.read!(snapshot_path) == inspect(snapshot_content, pretty: true)
    end
  end

  # Test update behavior by setting the environment variable
  describe "with UPDATE_SNAPSHOTS=1" do
    setup do
      System.put_env("UPDATE_SNAPSHOTS", "1")

      on_exit(fn ->
        System.delete_env("UPDATE_SNAPSHOTS")
      end)

      :ok
    end

    test "update existing snapshots" do
      snapshot_name = "update_snapshot.txt"
      original_content = "Original content"
      updated_content = "Updated content"
      snapshot_path = Path.join(@snapshot_dir, snapshot_name)

      File.write!(snapshot_path, original_content)

      assert_snapshot_match(snapshot_name, updated_content)

      assert File.read!(snapshot_path) == updated_content
    end
  end
end
