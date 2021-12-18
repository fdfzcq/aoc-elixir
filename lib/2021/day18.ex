defmodule Year2021.Day18 do
  defstruct [:level, :explode_right, :explode_left, :new_list, :list]

  ## part 1

  def run1(), do: part1(parse(input()))
  def test1(), do: part1(parse(test_input()))

  defp part1(lists) do
    lists
    |> Enum.reduce([],
      fn l, acc ->
        case acc do
          [] -> reduce_list(l)
          _ ->
            reduce_list(add_level(acc) ++ add_level(l))
        end
      end)
    |> calc_res()
  end

  ## part 2

  def run2(), do: part2(parse(input()))
  def test2(), do: part2(parse(test_input()))

  defp part2(lists), do:
    lists
    |> Enum.reduce({0, lists},
      fn l, {acc, left} ->
        max = left
        |> Enum.reduce(0,
          fn p, acc ->
            case l == p do
              true -> acc
              false -> max(acc, max(to_result(l, p), to_result(p, l)))
            end
          end)
        {max(acc, max), List.delete(left, l)}
      end)

  defp to_result(l1, l2), do: calc_res(reduce_list(add_level(l1) ++ add_level(l2)))

  ## private functions

  defp calc_res([{v, _}]) when is_number(v), do: v
  defp calc_res(list), do: calc_res(IO.inspect(list), [])

  defp calc_res([], acc) do
    rev = Enum.reverse(acc)
    case rev |> pair_up([]) do
      val when rev == val and length(val) != 1 -> 0
      val -> calc_res(val)
    end
  end
  defp calc_res([{{v1, v2}, level}|t], acc), do: calc_res(t, [{3 * v1 + 2 * v2, level - 1}|acc])
  defp calc_res([h|t], acc), do: calc_res(t, [h|acc])

  defp pair_up([], acc), do: Enum.reverse(acc)
  defp pair_up([{v1, l}, {v2, l}|t], acc) when is_number(v1) and is_number(v2), do: pair_up(t, [{{v1, v2}, l}|acc])
  defp pair_up([h|t], acc), do: pair_up(t, [h|acc])

  defp add_level(list), do:
    Enum.map(list, fn {val, level} -> {val, level + 1} end)

  defp reduce_list(list), do:
    list
    |> IO.inspect()
    |> explode_list([])
    |> split_list([])

  defp explode_list([], acc), do: Enum.reverse(acc)
  defp explode_list([{{val1, val2}, level}|t], acc) do
    case level >= 4 do
      true ->
        reduce_list(Enum.reverse(tail(acc)) ++ explode(head(acc), {{val1, val2}, level}, head(t)) ++ tail(t))
        #reduce_list(Enum.reverse(explode(val1, level, acc, :left)) ++ explode(val2, level, t, :right))
      false -> explode_list(t, [{{val1, val2}, level}|acc])
    end
  end
  defp explode_list([h|t], acc), do: explode_list(t, [h|acc])

  defp tail([]), do: []
  defp tail(list), do: tl(list)

  defp head([]), do: nil
  defp head(list), do: hd(list)

  defp explode(nil, {{_, val2}, level}, {val, l}), do: pair({0, level - 1}, {adds(val, val2, :left), l})
  defp explode({val, l}, {{val1, _}, level}, nil), do: pair({adds(val, val1, :right), l}, {0, level - 1})
  defp explode({v1, l1}, {{val1, val2}, level}, {v2, l2}) do
    case l1 == level - 1 && is_number(v1) do
      true -> [{{v1 + val1, 0}, l1}, {adds(v2, val2, :left), l2}]
      false ->
        case l2 == level - 1 && is_number(v2) do
          true -> [{adds(v1, val1, :right), l1}, {{0, v2 + val2}, l2}]
          false -> [{adds(v1, val1, :right), l1}, {0, level - 1}, {adds(v2, val2, :left), l2}]
        end
    end
  end

  defp adds({v1, v2}, val, :left), do: {v1 + val, v2}
  defp adds({v1, v2}, val, :right), do: {v1, v2 + val}
  defp adds(v, val, _), do: v + val

  defp pair({v1, l}, {v2, l}) when is_number(v1) and is_number(v2), do: [{{v1, v2}, l}]
  defp pair(a, b), do: [a, b]

  defp split_list([], acc), do: Enum.reverse(acc)
  defp split_list([{{val1, val2}, level}|t], acc) when val1 > 9, do:
    reduce_list(Enum.reverse([{val2, level}, split(val1, level)|acc]) ++ t)
  defp split_list([{{val1, val2}, level}|t], acc) when val2 > 9, do:
    reduce_list(Enum.reverse([split(val2, level), {val1, level}|acc]) ++ t)
  defp split_list([{val, level}|t], acc) do
    case val do
      val when is_number(val) and val > 9 ->
        reduce_list(Enum.reverse([split(val, level)|acc]) ++ t)
      val ->
        split_list(t, [{val, level}|acc])
    end
  end

  defp split(val, level), do: {{div(val, 2), div(val, 2) + rem(val, 2)}, level + 1}

  ## utils
  defp parse(str), do:
    str
    |> String.split("\n")
    |> Enum.map(&parse_string/1)
    |> Enum.map(&translate/1)

  defp parse_string(str) do
    {:ok, tokens, _} = :erl_scan.string(String.to_charlist(str <> "."))
    {:ok, list} = :erl_parse.parse_term(tokens)
    list
  end

  defp translate(list), do:
    translate(list, 0, [])

  defp translate([], _, acc), do: acc
  defp translate([v1, v2|t], level, acc) when is_number(v1) and is_number(v2) do
    translate(t, level, acc ++ [{{v1, v2}, level}])
  end
  defp translate([h|t], level, acc) do
    new_acc = case has_nested_list(h) do
      true -> translate(h, level + 1, acc)
      false -> acc ++ [to_pair(h, level)]
    end
    translate(t, level, new_acc)
  end

  defp has_nested_list(list) do
    case is_list(list) do
      true ->
        Enum.any?(list, &is_list/1)
      false -> false
    end
  end

  defp to_pair([v1, v2], level), do: {{v1, v2}, level + 1}
  defp to_pair(v, l), do: {v, l}

  defp input(), do: Utils.read_input_from_file(2021, 18)
  defp test_input(), do: Utils.read_test_input_from_file(2021, 18)
end
