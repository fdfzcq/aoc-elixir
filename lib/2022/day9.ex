defmodule Year2022.Day9 do
  def run1(), do: part1(input())
  def test1(), do: part1(test_input())

  defp part1(str),
    do:
      str
      |> String.split("\n")
      |> move_head()
      |> elem(0)
      |> map_size()

  defp move_head(instructions),
    do: Enum.reduce(instructions, {%{{0, 0} => 1}, {0, 0}, {0, 0}}, &move_head/2)

  defp move_head(ins, {tail_map, head_pos, tail_pos}) do
    [dir, dis_str] = String.split(ins, " ")
    dis = String.to_integer(dis_str)
    move_by_step({dir, dis}, {head_pos, tail_pos}, tail_map)
  end

  defp move_by_step({_, 0}, {hp, tp}, map), do: {map, hp, tp}

  defp move_by_step({dir, dis}, {head_pos, tail_pos}, tail_map) do
    next_head_pos = move_head_pos(dir, head_pos)
    next_tail_pos = move_tail_pos(tail_pos, head_pos)

    move_by_step(
      {dir, dis - 1},
      {next_head_pos, next_tail_pos},
      Map.put(tail_map, next_tail_pos, Map.get(tail_map, next_tail_pos, 0) + 1)
    )
  end

  defp move_head_pos(dir, {x, y}) do
    case dir do
      "R" -> {x + 1, y}
      "U" -> {x, y + 1}
      "L" -> {x - 1, y}
      "D" -> {x, y - 1}
    end
  end

  defp move_tail_pos({tx, ty}, {hx, hy}) do
    if should_move?({tx, ty}, {hx, hy}) do
      {move_closer(tx, hx), move_closer(ty, hy)}
    else
      {tx, ty}
    end
  end

  defp should_move?({tx, ty}, {hx, hy}) do
    abs(hx - tx) > 1 || abs(hy - ty) > 1
  end

  defp move_closer(t, h) do
    case t do
      v when v == h -> t
      v when v > h -> t - 1
      v when v < h -> t + 1
    end
  end

  ## part 2

  def run2(), do: part2(input())
  def test2(), do: part2(test_input())

  defp part2(str) do
    str
    |> String.split("\n")
    |> move_head2()
    |> elem(0)
    |> map_size()
  end

  defp move_head2(instructions),
    do:
      Enum.reduce(
        instructions,
        {%{{0, 0} => 1}, {0, 0}, 1..9 |> Enum.map(&{&1, {0, 0}}) |> Map.new()},
        &move_head2/2
      )

  defp move_head2(ins, {tail_map, head_pos, tails_pos}) do
    [dir, dis_str] = String.split(ins, " ")
    dis = String.to_integer(dis_str)
    move_by_step2({dir, dis}, {head_pos, tails_pos}, tail_map)
  end

  defp move_by_step2({_, 0}, {hp, tp}, map), do: {map, hp, tp}

  defp move_by_step2({dir, dis}, {head_pos, tails_pos}, tail_map) do
    next_head_pos = move_head_pos(dir, head_pos)

    next_tails_pos =
      tails_pos
      |> Map.to_list()
      |> Enum.sort(&(elem(&1, 0) < elem(&2, 0)))
      |> Enum.reduce(tails_pos, &move_tail(&1, &2, next_head_pos))

    last_tail_pos = Map.get(next_tails_pos, 9)

    move_by_step2(
      {dir, dis - 1},
      {next_head_pos, next_tails_pos},
      Map.put(tail_map, last_tail_pos, Map.get(tail_map, last_tail_pos, 0) + 1)
    )
  end

  defp move_tail({i, tp}, tails, next_head_pos) do
    next_tp =
      case i do
        1 -> move_tail_pos(tp, next_head_pos)
        n -> move_tail_pos(tp, Map.get(tails, n - 1))
      end

    Map.put(tails, i, next_tp)
  end

  # utils

  defp input(), do: Utils.read_input_from_file(2022, 9)
  defp test_input(), do: Utils.read_test_input_from_file(2022, 9)
end
