defmodule Year2022.Day7 do
  def run1(), do: part1(input())
  def test1(), do: part1(test_input())

  defp part1(str), do:
    str
    |> String.split("\n$ ")
    |> tl()
    |> build_directory_map(%{"/" => []}, %{})
    |> to_size_map()
    |> find_total_size_max(100000)

  defp build_directory_map(commands, dir_map, rev_map), do:
    commands
    |> Enum.reduce({"/", {dir_map, rev_map}}, &to_directory_map(String.split(&1, "\n"), &2))

  defp to_directory_map([cmd|results], {current_dir, {dir_map, rev_map}}) do
    case cmd do
      "ls" -> {current_dir, Enum.reduce(results, {dir_map, rev_map}, &add_to_dir(&1, &2, current_dir))}
      "cd .." -> {Map.get(rev_map, current_dir), {dir_map, rev_map}}
      "cd " <> d ->
        {Enum.find(Map.get(dir_map, current_dir), fn v ->
          case v do
            v when v == d -> true
            v when is_tuple(v) -> false
            v -> String.starts_with?(v, d)
          end
        end), {dir_map, rev_map}}
    end
  end

  defp add_to_dir(res, {map, rev_map}, cd) do
    obj = case res do
      "dir " <> d ->
        if Map.has_key?(rev_map, d) do
          d <> Integer.to_string(:rand.uniform(256))
        else
          d
        end
      str -> str |> String.split(" ") |> List.to_tuple()
    end
    {Map.put(map, cd, [obj | Map.get(map, cd, [])]), Map.put(rev_map, obj, cd)}
  end

  defp to_size_map({_, {map, _}}), do:
    to_size_map(%{}, "/", map) |> elem(0)

  defp to_size_map(size_map, dir, dir_map) do
    if Map.has_key?(size_map, dir) do
      {size_map, Map.get(size_map, dir)}
    else
      subs = Map.get(dir_map, dir, [])
      {files, dirs} = Enum.split_with(subs, fn n -> is_tuple(n) end)
      file_size = files |> Enum.map(fn {s, _} -> String.to_integer(s) end) |> Enum.sum()
      case dirs do
        [] -> {Map.put(size_map, dir, file_size), file_size}
        dirs ->
          {new_size_map, new_size} = Enum.reduce(dirs, {size_map, 0},
            fn d, {sm, s} ->
              {new_sm, add_s} = to_size_map(sm, d, dir_map)
              {new_sm, add_s + s}
            end)
          {Map.put(new_size_map, dir, new_size + file_size), new_size + file_size}
      end
    end
  end

  defp find_total_size_max(map, n), do:
    map |> Map.values() |> Enum.filter(fn x -> x <= n end) |> Enum.sum()

  ## part 2

  def run2(), do: part2(input())
  def test2(), do: part2(test_input())

  defp part2(str) do
    size_map = str
    |> String.split("\n$ ")
    |> tl()
    |> build_directory_map(%{"/" => []}, %{})
    |> to_size_map()
    min_size = 30000000 - (70000000 - Map.get(size_map, "/"))
    size_map
    |> Map.values()
    |> Enum.sort()
    |> IO.inspect()
    |> Enum.find(fn v -> v >= min_size end)
  end

  # utils

  defp input(), do: Utils.read_input_from_file(2022, 7)
  defp test_input(), do: Utils.read_test_input_from_file(2022, 7)
end
