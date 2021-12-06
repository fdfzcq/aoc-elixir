defmodule AOC.Day6 do
  ## This is horrible code translated from prolog
  ## Might make it better in the future

  def test(days), do: latern_fish(test_input, days)
  def run(days), do: latern_fish(input, days)

  def latern_fish(list, days), do:
    Enum.reduce(list, {%{}, length(list)}, &latern_fish(&1, &2, days))

  def latern_fish(clock, acc, days) when days <= clock, do:
    acc
  def latern_fish(clock, {map, acc}, days) do
    case Map.get(map, {clock, days}) do
      nil ->
        rem_days = days - clock - 1
        {map, v} = sum_new_latern_fish(rem_days, {map, 0})
        res = v + div(rem_days, 7) + 1
        new_map = Map.put(map, {clock, days}, res)
        {new_map, acc + res}
      v -> {map, v + acc}
    end
  end

  def sum_new_latern_fish(days, acc) when days < 0, do:
    acc
  def sum_new_latern_fish(days, {m, n}) do
    {map, v} = latern_fish(8, {m, 0}, days)
    sum_new_latern_fish(days - 7, {map, n + v})
  end

  def test_input, do: [3,4,3,1,2]
  def input, do: [5,1,2,1,5,3,1,1,1,1,1,2,5,4,1,1,1,1,2,1,2,1,1,1,1,1,2,1,5,1,1,1,3,1,1,1,3,1,1,3,1,1,4,3,1,1,4,1,1,1,1,2,1,1,1,5,1,1,5,1,1,1,4,4,2,5,1,1,5,1,1,2,2,1,2,1,1,5,3,1,2,1,1,3,1,4,3,3,1,1,3,1,5,1,1,3,1,1,4,4,1,1,1,5,1,1,1,4,4,1,3,1,4,1,1,4,5,1,1,1,4,3,1,4,1,1,4,4,3,5,1,2,2,1,2,2,1,1,1,2,1,1,1,4,1,1,3,1,1,2,1,4,1,1,1,1,1,1,1,1,2,2,1,1,5,5,1,1,1,5,1,1,1,1,5,1,3,2,1,1,5,2,3,1,2,2,2,5,1,1,3,1,1,1,5,1,4,1,1,1,3,2,1,3,3,1,3,1,1,1,1,1,1,1,2,3,1,5,1,4,1,3,5,1,1,1,2,2,1,1,1,1,5,4,1,1,3,1,2,4,2,1,1,3,5,1,1,1,3,1,1,1,5,1,1,1,1,1,3,1,1,1,4,1,1,1,1,2,2,1,1,1,1,5,3,1,2,3,4,1,1,5,1,2,4,2,1,1,1,2,1,1,1,1,1,1,1,4,1,5]
end
