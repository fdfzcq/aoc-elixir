defmodule Year2021.Day25 do
  def run1(), do: part1(input())
  def test1(), do: part1(test_input())

  defp part1(str) do
    map =
      str
      |> String.split("\n")
      |> Enum.with_index()
      |> Enum.reduce(
        %{},
        fn {line, y}, acc ->
          String.codepoints(line)
          |> Enum.with_index()
          |> Enum.reduce(
            acc,
            fn {c, x}, m ->
              Map.put(m, {x, y}, c)
            end
          )
        end
      )

    find_most_steps(map, 0, nil)
  end

  defp find_most_steps(map, steps, old_map) do
    case old_map == map do
      true -> steps
      false -> find_most_steps(step(map), steps + 1, map)
    end
  end

  defp step(map),
    do:
      map
      |> move_sea_cucumbers(:east)
      |> move_sea_cucumbers(:south)

  defp move_sea_cucumbers(map, dir) do
    map
    |> Enum.filter(fn {_, c} -> c == direction(dir) end)
    |> Enum.reduce(map, &maybe_move_sea_cucumber(&1, &2, map, dir))
  end

  defp maybe_move_sea_cucumber({{x, y}, v}, map, old_map, dir) do
    case can_move({x, y}, old_map, dir) do
      true ->
        new_map = Map.put(map, {x, y}, ".")

        case Map.get(old_map, next({x, y}, dir)) do
          nil -> Map.put(new_map, next({x, y}, dir, :wrap), v)
          _ -> Map.put(new_map, next({x, y}, dir), v)
        end

      false ->
        map
    end
  end

  defp can_move({x, y}, map, dir) do
    case Map.get(map, next({x, y}, dir)) do
      nil -> Map.get(map, next({x, y}, dir, :wrap)) == "."
      val -> val == "."
    end
  end

  defp next({x, y}, :east), do: {x + 1, y}
  defp next({x, y}, :south), do: {x, y + 1}
  defp next({_, y}, :east, :wrap), do: {0, y}
  defp next({x, _}, :south, :wrap), do: {x, 0}

  defp direction(:east), do: ">"
  defp direction(:south), do: "v"

  # utils

  defp input(), do: Utils.read_input_from_file(2021, 25)
  defp test_input(), do: Utils.read_test_input_from_file(2021, 25)
end
