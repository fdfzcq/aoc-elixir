defmodule Year2022.Day11 do
  def run1(), do: part1(input())
  def test1(), do: part1(test_input())

  defstruct items: [], operation: nil, test_div: 0, true: 0, false: 0

  defp part1(str) do
    [v1, v2 | _] =
      str
      |> String.split("\n\n")
      |> to_monkeys(%{})
      |> run_rounds(0, 20, %{}, :part1)
      |> Map.values()
      |> Enum.sort(&(&1 > &2))

    v1 * v2
  end

  defp to_monkeys([], monkeys), do: monkeys

  defp to_monkeys([block | tails], monkeys) do
    ["Monkey " <> number_str | lines] = String.split(block, "\n")

    monkey_number =
      String.slice(number_str, 0..(String.length(number_str) - 2)) |> String.to_integer()

    ["  Starting items: " <> items_str | lines1] = lines
    items = items_str |> String.split(", ") |> Enum.map(&String.to_integer/1)
    ["  Operation: new = " <> operations_str | lines2] = lines1
    [op_number1, op, op_number2] = String.split(operations_str, " ")
    ["  Test: divisible by " <> div_num_str | lines3] = lines2
    ["    If true: throw to monkey " <> true_monkey_str | line4] = lines3
    ["    If false: throw to monkey " <> false_monkey_str | _] = line4

    monkey = %__MODULE__{
      items: items,
      operation: {op_number1, op, op_number2},
      test_div: String.to_integer(div_num_str),
      true: String.to_integer(true_monkey_str),
      false: String.to_integer(false_monkey_str)
    }

    new_monkeys = Map.put(monkeys, monkey_number, monkey)
    to_monkeys(tails, new_monkeys)
  end

  defp run_rounds(_, _, 0, map, _), do: map

  defp run_rounds(monkeys, monkey, rounds_left, inspect_map, part) do
    case Map.get(monkeys, monkey, nil) do
      nil ->
        run_rounds(monkeys, 0, rounds_left - 1, inspect_map, part)

      struct ->
        case Map.get(struct, :items) do
          [] ->
            run_rounds(monkeys, monkey + 1, rounds_left, inspect_map, part)

          items ->
            new_monkeys = Enum.reduce(items, monkeys, &run_round(&1, &2, monkey, part))

            new_new_monkeys =
              Map.put(new_monkeys, monkey, Map.get(new_monkeys, monkey) |> Map.put(:items, []))

            new_inspect_map =
              Map.put(inspect_map, monkey, Map.get(inspect_map, monkey, 0) + length(items))

            run_rounds(new_new_monkeys, monkey + 1, rounds_left, new_inspect_map, part)
        end
    end
  end

  defp run_round(item, monkeys, monkey, part) do
    %__MODULE__{operation: {n1, ops, n2}, test_div: td, true: tm, false: fm} =
      Map.get(monkeys, monkey)

    worry_level =
      case part do
        :part2 -> do_op(item, ops, n1, n2)
        _ -> div(do_op(item, ops, n1, n2), 3)
      end

    if rem(worry_level, td) == 0 do
      add_to_monkeys(monkeys, worry_level, tm)
    else
      add_to_monkeys(monkeys, worry_level, fm)
    end
  end

  defp do_op(item, ops, n1, n2) do
    v1 = to_value(n1, item)
    v2 = to_value(n2, item)

    case ops do
      "+" -> v2 + v1
      "*" -> v1 * v2
    end
  end

  defp to_value(n, item) do
    case n do
      "old" -> item
      _ -> String.to_integer(n)
    end
  end

  defp add_to_monkeys(monkeys, item, m) do
    new_items = Map.get(monkeys, m) |> Map.get(:items) |> Kernel.++([item])
    new_monkey = Map.get(monkeys, m) |> Map.put(:items, new_items)
    Map.put(monkeys, m, new_monkey)
  end

  ## part 2

  def run2(), do: part2(input())
  def test2(), do: part2(test_input())

  defp part2(str) do
    [v1, v2 | _] =
      str
      |> String.split("\n\n")
      |> to_monkeys(%{})
      |> run_rounds2(10000, %{})
      |> Map.values()
      |> Enum.sort(&(&1 > &2))

    v1 * v2
  end

  defp run_rounds2(monkeys, rounds, map) do
    0..(map_size(monkeys) - 1)
    |> Enum.reduce(map, &run_rounds_per_item(&1, &2, monkeys, rounds))
  end

  defp run_rounds_per_item(monkey, map, monkeys, rounds) do
    %__MODULE__{items: items} = Map.get(monkeys, monkey)
    Enum.reduce(items, map, &do_run_rounds_per_item(&1, &2, monkey, monkeys, rounds))
  end

  defp do_run_rounds_per_item(_, map, _, _, rounds) when rounds <= 0, do: map

  defp do_run_rounds_per_item(item, map, monkey, monkeys, rounds) do
    %__MODULE__{operation: {n1, ops, n2}, test_div: td, true: tm, false: fm} =
      Map.get(monkeys, monkey)

    # test_mod = 23 * 19 * 13 * 17
    mod = 7 * 19 * 13 * 3 * 2 * 11 * 17 * 5
    worry_level = rem(do_op(item, ops, n1, n2), mod)

    next_monkey =
      if rem(worry_level, td) == 0 do
        tm
      else
        fm
      end

    new_rounds =
      if next_monkey > monkey do
        rounds
      else
        rounds - 1
      end

    do_run_rounds_per_item(
      worry_level,
      Map.put(map, monkey, Map.get(map, monkey, 0) + 1),
      next_monkey,
      monkeys,
      new_rounds
    )
  end

  # utils

  defp input(), do: Utils.read_input_from_file(2022, 11)
  defp test_input(), do: Utils.read_test_input_from_file(2022, 11)
end
