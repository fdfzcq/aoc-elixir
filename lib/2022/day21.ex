defmodule Year2022.Day21 do
  def run1(), do: part1(input())
  def test1(), do: part1(test_input())

  defp part1(str) do
    str
    |> String.split("\n")
    |> Enum.map(
      fn line ->
        [key, str] = String.split(line, ": ")
        content =
          case String.split(str, " ") do
            [m1, op, m2] -> {m1, op, m2}
            [numstr] -> String.to_integer(numstr)
          end
        {key, content}
      end
    )
    |> Map.new()
    |> find_value("nlcb")
  end

  defp find_value(map, monkey) do
    case Map.get(map, monkey) do
      {m1, op, m2} ->
        do_op(op, find_value(map, m1), find_value(map, m2))
      n -> n
    end
  end

  defp do_op(op, m1, m2) do
    case op do
      "+" -> m1 + m2
      "-" -> m1 - m2
      "*" -> m1 * m2
      "/" -> div(m1, m2)
    end
  end

  ## part 2

  def run2(), do: part2(input())
  def test2(), do: part2(test_input())

  defp part2(str) do
    str
    |> String.split("\n")
    |> Enum.map(
      fn line ->
        [key, str] = String.split(line, ": ")
        content =
          case String.split(str, " ") do
            [m1, op, m2] -> {m1, op, m2}
            [numstr] -> String.to_integer(numstr)
          end
        {key, content}
      end
    )
    |> Enum.reject(fn {m, _} -> m == "humn" end)
    |> Map.new()
    |> find_number_to_yell()
  end

  defp find_number_to_yell(map) do
    {m1, _, m2} = Map.get(map, "root")
    map0 = map
    |> Map.to_list()
    |> Enum.map(
      fn {k, v} ->
        try do
          {k, find_value(map, k)}
        rescue
          _ -> {k, v}
        end
      end)
    |> Map.new()
    find_number_to_yell(map0, Map.get(map0, m2), m1)
  end

  defp find_number_to_yell(map, v, m) do
    case Map.get(map, m) do
      {m1, op, m2} ->
        case {maybe_find_v(map, m1), maybe_find_v(map, m2)} do
          {v1, nil} ->
            new_v = reverse_op(op, 1, v1, v)
            find_number_to_yell(map, new_v, m2)
          {nil, v2} ->
            new_v = reverse_op(op, 0, v2, v)
            find_number_to_yell(map, new_v, m1)
        end
      nil -> v
      _ -> :oops
    end
  end

  defp reverse_op(op, pos, v, res) do
    case op do
      "+" -> res - v
      "*" -> div(res, v)
      "/" ->
        case pos do
          0 -> res * v
          1 -> div(v, res)
        end
      "-" ->
        case pos do
          0 -> res + v
          1 -> v - res
        end
    end
  end

  defp maybe_find_v(map, m) do
    try do
      find_value(map, m)
    rescue
      _ -> nil
    end
  end

  # utils

  defp input(), do: Utils.read_input_from_file(2022, 21)
  defp test_input(), do: Utils.read_test_input_from_file(2022, 21)
end
