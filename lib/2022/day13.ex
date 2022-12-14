defmodule Year2022.Day13 do
  def run1(), do: part1(input())
  def test1(), do: part1(test_input())

  defp part1(str) do
    str
    |> String.split("\n\n")
    |> compare_groups(1, 0)
  end

  defp compare_groups([], _, res), do: res

  defp compare_groups([group_str | rest], i, res) do
    [left, right] =
      group_str
      |> String.split("\n")
      |> Enum.map(fn l -> Code.eval_string(l) |> elem(0) end)

    if compare_group(left, right) do
      compare_groups(rest, i + 1, res + i)
    else
      compare_groups(rest, i + 1, res)
    end
  end

  defp compare_group([], []), do: nil
  defp compare_group([], _), do: true
  defp compare_group(_, []), do: false

  defp compare_group([l | lt], [r | rt]) do
    case {is_list(l), is_list(r)} do
      {true, true} ->
        compare_lists_and_continue(l, r, lt, rt)

      {false, true} ->
        compare_lists_and_continue([l], r, lt, rt)

      {true, false} ->
        compare_lists_and_continue(l, [r], lt, rt)

      {false, false} ->
        case l do
          v when v < r -> true
          v when v == r -> compare_group(lt, rt)
          _ -> false
        end
    end
  end

  defp compare_lists_and_continue(l, r, lt, rt) do
    nested = compare_group(l, r)

    case nested do
      nil -> compare_group(lt, rt)
      _ -> nested
    end
  end

  ## part 2

  def run2(), do: part2(input())
  def test2(), do: part2(test_input())

  defp part2(str) do
    lists =
      str
      |> String.split("\n\n")
      |> Enum.map(&String.split(&1, "\n"))
      |> List.flatten()
      |> Enum.map(fn l -> Code.eval_string(l) |> elem(0) end)

    sorted =
      [[[2]], [[6]] | lists]
      |> Enum.sort(fn l1, l2 -> compare_group(l1, l2) end)

    i1 = Enum.find_index(sorted, fn x -> x == [[2]] end)
    i2 = Enum.find_index(sorted, fn x -> x == [[6]] end)
    (i1 + 1) * (i2 + 1)
  end

  # utils

  defp input(), do: Utils.read_input_from_file(2022, 13)
  defp test_input(), do: Utils.read_test_input_from_file(2022, 13)
end
