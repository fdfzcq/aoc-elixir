defmodule Year2021.Day21 do
  def run1(), do: part1(input())
  def test1(), do: part1(test_input())

  defp part1({position1, position2}),
    do: play1({1, position1, 0}, {1, 2, 3}, {2, position2, 0}, 0)

  defp play1({_, _, score1}, {_, _, _}, {_, _, score2}, n) when score2 >= 1000, do: n * score1

  defp play1({x, pos1, score1}, {n1, n2, n3}, {y, pos2, score2}, d) do
    play1(
      {y, pos2, score2},
      next_rolls(n3 + 1),
      add_to_score(x, score1, pos1, {n1, n2, n3}),
      d + 3
    )
  end

  defp add_to_score(i, score, position, {n1, n2, n3}) do
    next_position = move(position + n1 + n2 + n3)
    {i, next_position, score + next_position}
  end

  defp next_rolls(n), do: {next_n(n), next_n(n + 1), next_n(n + 2)}

  defp next_n(n) when n > 100, do: rem(n, 100)
  defp next_n(n), do: n

  defp move(v) when v <= 10, do: v

  defp move(v) do
    case rem(v, 10) do
      0 -> 10
      n -> n
    end
  end

  ## part 2

  def run2(), do: part2(input())
  def test2(), do: part2(test_input())

  defp part2({pos1, pos2}), do: play2({1, pos1, 0}, {2, pos2, 0}, {%{1 => 0, 2 => 0}, %{}})

  defp play2({_, _, _}, {x, _, score2}, {win, mem}) when score2 >= 21,
    do: {Map.put(win, x, win[x] + 1), mem}

  defp play2({x, pos1, score1}, {y, pos2, score2}, {acc, mem}) do
    case Map.get(mem, {pos1, score1, pos2, score2, x}) do
      nil ->
        [9, 8, 7, 6, 5, 4, 3]
        |> Enum.reduce(
          {acc, mem},
          fn n, {%{1 => win1, 2 => win2}, mem1} ->
            {x, newpos1, newscore1} = add_to_score2(x, score1, pos1, n)

            {%{1 => w1, 2 => w2}, mem2} =
              play2({y, pos2, score2}, {x, newpos1, newscore1}, {%{1 => 0, 2 => 0}, mem1})

            {
              %{1 => win1 + calc_value(n, w1), 2 => win2 + calc_value(n, w2)},
              # mem2
              mem2 |> Map.put({pos2, score2, newpos1, newscore1, y}, %{1 => w1, 2 => w2})
            }
          end
        )

      res ->
        {%{x => acc[x] + res[x], y => acc[y] + res[y]}, mem}
    end
  end

  defp calc_value(9, v), do: v
  defp calc_value(8, v), do: 3 * v
  defp calc_value(7, v), do: 6 * v
  defp calc_value(6, v), do: 7 * v
  defp calc_value(5, v), do: 6 * v
  defp calc_value(4, v), do: 3 * v
  defp calc_value(3, v), do: v

  defp add_to_score2(i, score, position, n) do
    next_position = move(position + n)
    {i, next_position, score + next_position}
  end

  # utils

  defp input(), do: {1, 6}
  defp test_input(), do: {4, 8}
end
