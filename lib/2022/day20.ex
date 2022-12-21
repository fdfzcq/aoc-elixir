defmodule Year2022.Day20 do
  def run1(), do: part1(input())
  def test1(), do: part1(test_input())

  defp part1(str) do
    list = str
    |> String.split("\n")
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index(fn e, i -> {e, i} end)

    list0 = mixing(list, [], length(list))
    {0, i0} = Enum.find(list0, fn {e, _} -> e == 0 end)
    {a1, _} = Enum.find(list0, fn {_, i} -> i == rem(i0 + 1000, length(list)) end)
    {a2, _} = Enum.find(list0, fn {_, i} -> i == rem(i0 + 2000, length(list)) end)
    {a3, _} = Enum.find(list0, fn {_, i} -> i == rem(i0 + 3000, length(list)) end)
    a1 + a2 + a3
  end

  defp mixing([], new, _) do
    IO.inspect(Enum.sort(new, fn {_, i1}, {_, i2} -> i1 < i2 end))
    Enum.reverse(new)
  end
  defp mixing([{e, index}|t], new, l) do
    new_i = normalize(index + e, l)
    new_t = Enum.map(t, &move_indices(&1, index, new_i))
    new_acc = Enum.map(new, &move_indices(&1, index, new_i))
    mixing(new_t, [{e, new_i}|new_acc], l)
  end

  defp normalize(v, l) do
    if v >= 0 do
      if v > l - 1 do
        rem(v, l - 1)
      else
        v
      end
    else
      l + rem(v, l - 1) - 1
    end
  end

  defp move_indices({e, i}, from, to) do
    if from <= i && to >= i do
      {e, i - 1}
    else
      if from > i && to <= i do
        {e, i + 1}
      else
        {e, i}
      end
    end
  end

  ## part 2

  def run2(), do: part2(input())
  def test2(), do: part2(test_input())

  defp part2(str) do
    list = str
    |> String.split("\n")
    |> Enum.map(&String.to_integer/1)
    |> Enum.with_index(fn e, i -> {e * 811589153, i} end)

    list0 = 0..9 |> Enum.reduce(list, fn _, l -> mixing(l, [], length(list)) end)
    {0, i0} = Enum.find(list0, fn {e, _} -> e == 0 end)
    {a1, _} = Enum.find(list0, fn {_, i} -> i == rem(i0 + 1000, length(list)) end)
    {a2, _} = Enum.find(list0, fn {_, i} -> i == rem(i0 + 2000, length(list)) end)
    {a3, _} = Enum.find(list0, fn {_, i} -> i == rem(i0 + 3000, length(list)) end)
    a1 + a2 + a3
  end

  # utils

  defp input(), do: Utils.read_input_from_file(2022, 20)
  defp test_input(), do: Utils.read_test_input_from_file(2022, 20)
end
