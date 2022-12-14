defmodule Year2022.Day12 do
  def run1(), do: part1(input())
  def test1(), do: part1(test_input())

  defp part1(str) do
    map =
      str
      |> Utils.to_coordinates_map(fn s -> String.to_charlist(s) |> Enum.at(0) end)

    {start_coor, _} = map |> Map.to_list() |> Enum.find(fn {_, v} -> v == ?S end)

    map
    |> find_path(start_coor, str, 0)
  end

  defp find_path(map, s, str, steps) do
    max_y = str |> String.split("\n") |> length() |> Kernel.-(1)
    max_x = str |> String.split("\n") |> Enum.at(0) |> String.length() |> Kernel.-(1)
    next_coors = to_next_coors(s, {max_x, max_y}, map, ?a, MapSet.new([s]))
    find_path(map, next_coors, {max_x, max_y}, ?a, steps + 1, MapSet.new([s]))
  end

  defp find_path(map, next_coors, {mx, my}, v, steps, mem) do
    IO.inspect(steps)

    {new_coors, new_mem} =
      next_coors
      |> Enum.reduce_while({[], mem}, fn coor, {a, m} ->
        if Map.get(map, coor) == ?z do
          IO.inspect(steps + 1)
          System.halt(0)
        else
          {:cont,
           {a ++ to_next_coors(coor, {mx, my}, map, MapSet.put(m, coor)), MapSet.put(m, coor)}}
        end
      end)

    if new_coors != [] do
      find_path(map, Enum.uniq(new_coors), {mx, my}, v + 1, steps + 1, new_mem)
    end
  end

  defp to_next_coors(c, mc, map, mem), do: to_next_coors(c, mc, map, Map.get(map, c) + 1, mem)

  defp to_next_coors({x, y}, {mx, my}, map, v, mem) do
    [{x - 1, y}, {x, y - 1}, {x + 1, y}, {x, y + 1}]
    |> Enum.filter(fn {a, b} ->
      a >= 0 && b >= 0 && a <= mx && b <= my && Map.get(map, {a, b}) <= v &&
        !MapSet.member?(mem, {a, b})
    end)
  end

  ## part 2

  def run2(), do: part2(input())
  def test2(), do: part2(test_input())

  defp part2(str) do
    map =
      str
      |> Utils.to_coordinates_map(fn s -> String.to_charlist(s) |> Enum.at(0) end)

    start_coors =
      map
      |> Map.to_list()
      |> Enum.filter(fn {_, v} -> v == ?a end)
      |> Enum.map(fn {c, _} -> c end)

    max_y = str |> String.split("\n") |> length() |> Kernel.-(1)
    max_x = str |> String.split("\n") |> Enum.at(0) |> String.length() |> Kernel.-(1)
    find_path(map, start_coors, {max_x, max_y}, ?a, 0, MapSet.new(start_coors))
  end

  # utils

  defp input(), do: Utils.read_input_from_file(2022, 12)
  defp test_input(), do: Utils.read_test_input_from_file(2022, 12)
end
