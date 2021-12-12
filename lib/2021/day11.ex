defmodule Day11 do
  def test(), do: find_sync(0, to_map(test_input()))
  def run(), do: find_sync(0, to_map(input()))

  ## part 1
  def test(steps), do: steps(to_map(test_input()), steps)
  def run(steps), do: steps(to_map(input()), steps)

  def steps(map, steps), do: steps(map, steps, 0)

  defp steps(_, 0, glowed), do: glowed
  defp steps(map, steps, glowed) do
    {new_map, new_glowed} = step(map)
    steps(new_map, steps - 1, glowed + new_glowed)
  end
  ## end of part 1

  ## part 2
  defp find_sync(steps, map) do
    case is_synced(map) do
      true -> steps
      false ->
        {new_map, _} = step(map)
        find_sync(steps + 1, new_map)
    end
  end

  defp is_synced(map), do: map |> Map.values() |> Enum.all?(fn v -> v == 0 end)
  ## end of part2

  defp step(map) do
    increased_map = map
    |> Enum.reduce(map, &increase_energy_level(&1, &2))
    |> Map.new()
    increased_map
    |> Enum.reduce({increased_map, MapSet.new()}, &glow(&1, &2))
    |> reset_to_zero()
  end

  defp increase_energy_level({coor, val}, map), do: Map.put(map, coor, val + 1)

  defp glow({{x, y}, 10}, {map, glowed}) do
    new_glowed = MapSet.put(glowed, {x, y})
    {x, y}
    |> neighbours()
    |> Enum.reduce({map, new_glowed},
      fn {nx, ny}, {m, g} ->
        v = Map.get(m, {nx, ny}, -1)
        case v do
          10 -> {m, g}
          -1 -> {m, g}
          _ -> glow({{nx, ny}, v + 1}, {Map.put(m, {nx, ny}, v + 1), g})
        end
      end)
  end
  defp glow(_, acc), do: acc

  defp reset_to_zero({map, glowed}) do
    new_map = glowed
    |> MapSet.to_list()
    |> Enum.reduce(map, fn c, m -> Map.put(m, c, 0) end)
    {new_map, MapSet.size(glowed)}
  end

  defp neighbours({x, y}), do: [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1},
    {x + 1, y + 1}, {x + 1, y - 1}, {x - 1, y - 1}, {x - 1, y + 1 }]

  ## utils

  defp to_map(str), do:
    str
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.reduce(%{}, &to_map(&1, &2))

  defp to_map({line_str, y}, acc_map), do:
    line_str
    |> String.codepoints()
    |> Enum.with_index()
    |> Enum.reduce(acc_map, &(add_point(&1, &2, y)))

  defp add_point({c, x}, map, y), do: Map.put(map, {x, y}, String.to_integer(c))

  defp test_input, do: Utils.read_input_from_file("day11_test.txt")
  defp input, do: Utils.read_input_from_file("day11.txt")
end
