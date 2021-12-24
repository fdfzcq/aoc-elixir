defmodule Day9 do
  def run(), do: process(to_number_lists(input()))
  def test(), do: process(to_number_lists(test_input()))

  defp process(number_lists) do
    [v1, v2, v3 | _] =
      number_lists
      |> Enum.with_index()
      |> Enum.map(&find_low_points(&1, number_lists))
      |> List.flatten()
      |> Enum.reduce([], &find_basin(&1, &2, number_lists))
      |> Enum.sort(&(&1 >= &2))

    v1 * v2 * v3
  end

  defp find_low_points({num_list, y}, number_lists),
    do:
      num_list
      |> Enum.with_index()
      |> Enum.reduce([], &find_low_point(&1, &2, y, number_lists))
      |> List.flatten()

  defp find_low_point({num, x}, acc, y, number_lists) do
    case is_low_point(x, y, num, number_lists) do
      true ->
        [{x, y, num} | acc]

      false ->
        acc
    end
  end

  defp is_low_point(x, y, n, lists) do
    n < read_value(x - 1, y, lists) &&
      n < read_value(x + 1, y, lists) &&
      n < read_value(x, y - 1, lists) &&
      n < read_value(x, y + 1, lists)
  end

  defp find_basin({x, y, num}, acc, numlists) do
    size =
      {x, y, num}
      |> search(MapSet.new([{x, y}]), numlists)
      |> MapSet.size()

    [size | acc]
  end

  defp search({x, y, n}, mapset, numlists) do
    {next, new_map} =
      {x, y}
      |> neighbours()
      |> Enum.reduce(
        {[], mapset},
        fn {nx, ny}, {acc, m} ->
          case MapSet.member?(m, {nx, ny}) do
            true ->
              {acc, m}

            false ->
              nn = read_value(nx, ny, numlists)

              case nn > n && nn < 9 do
                true -> {[{nx, ny, nn} | acc], MapSet.put(m, {nx, ny})}
                false -> {acc, m}
              end
          end
        end
      )

    case next do
      [] -> mapset
      _ -> next |> Enum.reduce(new_map, &search(&1, &2, numlists))
    end
  end

  defp neighbours({x, y}), do: [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}]

  defp read_value(x, y, lists) when x >= 0 and y >= 0,
    do:
      lists
      |> Enum.at(y, [])
      |> Enum.at(x, 10)

  defp read_value(_, _, _), do: 10

  defp to_number_lists(input_str) do
    input_str
    |> String.split("\n")
    |> Enum.map(fn str ->
      str
      |> String.codepoints()
      |> Enum.map(&String.to_integer/1)
    end)
  end

  defp test_input, do: Utils.read_input_from_file("day9_test.txt")
  defp input, do: Utils.read_input_from_file("day9.txt")
end
