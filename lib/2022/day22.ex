defmodule Year2022.Day22 do
  def run1(), do: part1(input())
  def test1(), do: part1(test_input())

  defp part1(str) do
    [map_str, ins_str] = String.split(str, "\n\n")

    map =
      map_str
      |> Utils.to_coordinates_map(fn c -> c end)
      |> Map.filter(fn {_, c} -> c != " " end)

    ins_nums =
      Regex.scan(~r/[[:digit:]]+/, ins_str) |> Enum.map(fn [v] -> String.to_integer(v) end)

    ins_dirs = String.replace(ins_str, ~r/[\d]/, "") |> String.codepoints()

    # part 1
    y_range_map =
      to_range_map(map, fn {{_, y}, _} -> y end, fn {k, list} ->
        {{{min_x, _}, _}, {{max_x, _}, _}} = Enum.min_max_by(list, fn {{x, _}, _} -> x end)

        {k, {min_x, max_x}}
      end)

    x_range_map =
      to_range_map(map, fn {{x, _}, _} -> x end, fn {k, list} ->
        {{{_, min_y}, _}, {{_, max_y}, _}} = Enum.min_max_by(list, fn {{_, y}, _} -> y end)

        {k, {min_y, max_y}}
      end)

    run_instructions(
      {map, y_range_map, x_range_map},
      ins_nums,
      ins_dirs,
      find_start_point(map),
      :right
    )
  end

  defp to_range_map(map, group_fun, map_fun) do
    map
    |> Map.to_list()
    |> Enum.group_by(group_fun)
    |> Map.to_list()
    |> Enum.map(map_fun)
    |> Map.new()
  end

  defp find_start_point(map) do
    {coor, _} =
      map
      |> Map.to_list()
      |> Enum.sort(fn {{x1, y1}, _}, {{x2, y2}, _} ->
        if y1 == y2 do
          x1 < x2
        else
          y1 < y2
        end
      end)
      |> hd()

    coor
  end

  defp run_instructions(_, [], [], {x, y}, facing) do
    IO.inspect({x, y, facing})
    4 * (x + 1) + 1000 * (y + 1) + to_score(facing)
  end

  defp run_instructions(m, nums, dirs, current, facing) do
    case {nums, dirs} do
      {[], [dir | d_t]} ->
        run_instructions(m, nums, d_t, current, new_facing(facing, dir))

      {[num | n_t], []} ->
        new_pos = move_forward(m, current, num, facing)
        run_instructions(m, n_t, dirs, new_pos, facing)

      {[num | n_t], [dir | d_t]} ->
        new_pos = move_forward(m, current, num, facing)
        new_facing = new_facing(facing, dir)

        run_instructions(m, n_t, d_t, new_pos, new_facing)
    end
  end

  defp new_facing(facing, dir) do
    case {facing, dir} do
      {:right, "R"} -> :down
      {:right, "L"} -> :up
      {:down, "R"} -> :left
      {:down, "L"} -> :right
      {:left, "R"} -> :up
      {:left, "L"} -> :down
      {:up, "R"} -> :right
      {:up, "L"} -> :left
    end
  end

  defp to_score(facing) do
    case facing do
      :right -> 0
      :down -> 1
      :left -> 2
      :up -> 3
    end
  end

  defp move_forward({map, range_y, range_x}, {x0, y0}, steps, facing) do
    case facing do
      :right ->
        {min_x, max_x} = Map.get(range_y, y0)

        new_x =
          find_moved_value({min_x, max_x}, x0, steps, :inc, fn xx ->
            Map.get(map, {xx, y0}) == "#"
          end)

        {new_x, y0}

      :left ->
        {min_x, max_x} = Map.get(range_y, y0)

        new_x =
          find_moved_value({min_x, max_x}, x0, steps, :dec, fn xx ->
            Map.get(map, {xx, y0}) == "#"
          end)

        {new_x, y0}

      :up ->
        {min_y, max_y} = Map.get(range_x, x0)

        new_y =
          find_moved_value({min_y, max_y}, y0, steps, :dec, fn yy ->
            Map.get(map, {x0, yy}) == "#"
          end)

        {x0, new_y}

      :down ->
        {min_y, max_y} = Map.get(range_x, x0)

        new_y =
          find_moved_value({min_y, max_y}, y0, steps, :inc, fn yy ->
            Map.get(map, {x0, yy}) == "#"
          end)

        {x0, new_y}
    end
  end

  defp find_moved_value({min, max}, v0, steps, type, fun) do
    new_v =
      case type do
        :inc -> min + rem(v0 + steps - min, max - min + 1)
        :dec -> max - rem(max - v0 + steps, max - min + 1)
      end

    range =
      case type do
        :inc ->
          if v0 + steps > max && v0 + steps > max + (max - min + 1) do
            Enum.to_list(v0..max) ++ Enum.to_list(min..v0)
          else
            if v0 + steps > max do
              Enum.to_list(v0..max) ++ Enum.to_list(min..new_v)
            else
              v0..new_v
            end
          end

        :dec ->
          if v0 - steps < min && v0 - steps < min - (max - min + 1) do
            Enum.to_list(v0..min) ++ Enum.to_list(max..v0)
          else
            if v0 - steps < min do
              Enum.to_list(v0..min) ++ Enum.to_list(max..new_v)
            else
              v0..new_v
            end
          end
      end

    case Enum.find(range, fun) do
      nil ->
        new_v

      vv ->
        case type do
          :inc ->
            if vv - 1 < min do
              max
            else
              vv - 1
            end

          :dec ->
            if vv + 1 > max do
              min
            else
              vv + 1
            end
        end
    end
  end

  ## part 2

  def run2(), do: part2(input())
  def test2(), do: part2(test_input())

  defp part2(str) do
    [map_str, ins_str] = String.split(str, "\n\n")

    map =
      map_str
      |> Utils.to_coordinates_map(fn c -> c end)
      |> Map.filter(fn {_, c} -> c != " " end)

    ins_nums =
      Regex.scan(~r/[[:digit:]]+/, ins_str) |> Enum.map(fn [v] -> String.to_integer(v) end)

    ins_dirs = String.replace(ins_str, ~r/[\d]/, "") |> String.codepoints()

    y_range_map =
      to_range_map(map, fn {{_, y}, _} -> y end, fn {k, list} ->
        {{{min_x, _}, _}, {{max_x, _}, _}} = Enum.min_max_by(list, fn {{x, _}, _} -> x end)

        {k, {min_x, max_x}}
      end)

    x_range_map =
      to_range_map(map, fn {{x, _}, _} -> x end, fn {k, list} ->
        {{{_, min_y}, _}, {{_, max_y}, _}} = Enum.min_max_by(list, fn {{_, y}, _} -> y end)

        {k, {min_y, max_y}}
      end)

    edge_map = edge_maps()

    run_instructions2(
      {map, y_range_map, x_range_map, edge_map},
      ins_nums,
      ins_dirs,
      find_start_point(map),
      :right
    )
  end

  defp edge_maps_test() do
    %{}
    # cube 1
    |> update_edge_map(fn x0 -> {{{x0 + 8, 0}, :up}, {{x0, 4}, :up}, {:down, :down}} end)
    |> update_edge_map(fn y0 -> {{{8, y0}, :left}, {{4 + y0, 4}, :up}, {:down, :right}} end)
    |> update_edge_map(fn y0 -> {{{11, y0}, :right}, {{15, 11 - y0}, :right}, {:left, :left}} end)
    # cube 2
    |> update_edge_map(fn y0 -> {{{0, 4 + y0}, :left}, {{15 - y0, 11}, :down}, {:up, :right}} end)
    |> update_edge_map(fn x0 -> {{{x0, 7}, :down}, {{11 - x0, 11}, :down}, {:up, :up}} end)
    # cube 3
    |> update_edge_map(fn x0 -> {{{4 + x0, 7}, :down}, {{8, 11 - x0}, :left}, {:right, :up}} end)
    # cube 4
    |> update_edge_map(fn x0 -> {{{11, 4 + x0}, :right}, {{15 - x0, 8}, :up}, {:down, :left}} end)

    # cube 5
    # cube 6
  end

  defp edge_maps() do
    %{}
    # cube 1
    |> update_edge_map(fn x0 -> {{{x0 + 50, 0}, :up}, {{0, 150 + x0}, :left}, {:right, :down}} end)
    |> update_edge_map(fn y0 -> {{{50, y0}, :left}, {{0, 149 - y0}, :left}, {:right, :right}} end)
    # cube 2
    |> update_edge_map(fn x0 -> {{{x0 + 100, 0}, :up}, {{x0, 199}, :down}, {:up, :down}} end)
    |> update_edge_map(fn y0 ->
      {{{149, y0}, :right}, {{99, 149 - y0}, :right}, {:left, :left}}
    end)
    |> update_edge_map(fn x0 ->
      {{{x0 + 100, 49}, :down}, {{99, 50 + x0}, :right}, {:left, :up}}
    end)
    # cube 3
    |> update_edge_map(fn y0 -> {{{50, 50 + y0}, :left}, {{y0, 100}, :up}, {:down, :right}} end)
    # cube 4
    # cube 5
    |> update_edge_map(fn x0 ->
      {{{50 + x0, 149}, :down}, {{49, 150 + x0}, :right}, {:left, :up}}
    end)

    # cube 6
  end

  defp update_edge_map(map, fun) do
    0..49
    |> Enum.reduce(
      map,
      fn x0, acc ->
        {a, b, dirs} = fun.(x0)
        put_double_map(acc, a, b, dirs)
      end
    )
  end

  defp put_double_map(map, {a, dira}, {b, dirb}, {dir1, dir2}) do
    map
    |> Map.put({a, dira}, {b, dir1})
    |> Map.put({b, dirb}, {a, dir2})
  end

  defp run_instructions2(_, [], [], {x, y}, facing) do
    IO.inspect({x, y, facing})
    4 * (x + 1) + 1000 * (y + 1) + to_score(facing)
  end

  defp run_instructions2(m, nums, dirs, current, facing) do
    case {nums, dirs} do
      {[], [dir | d_t]} ->
        run_instructions2(m, nums, d_t, current, new_facing(facing, dir))

      {[num | n_t], []} ->
        {new_pos, facing0} = move_forward2(m, current, num, facing)
        run_instructions2(m, n_t, dirs, new_pos, facing0)

      {[num | n_t], [dir | d_t]} ->
        {new_pos, facing0} = move_forward2(m, current, num, facing)
        new_facing = new_facing(facing0, dir)

        run_instructions2(m, n_t, d_t, new_pos, new_facing)
    end
  end

  defp move_forward2(_, pos, 0, facing), do: {pos, facing}

  defp move_forward2({_map, range_y, range_x, _edge_map} = maps, {x0, y0}, steps, facing) do
    case facing do
      :right ->
        {_, max_x} = Map.get(range_y, y0)
        do_move_forward2(x0, {:max, max_x}, steps, maps, fn m -> {m, y0} end, :right)

      :left ->
        {min_x, _} = Map.get(range_y, y0)
        do_move_forward2(x0, {:min, min_x}, steps, maps, fn m -> {m, y0} end, :left)

      :up ->
        {min_y, _} = Map.get(range_x, x0)
        do_move_forward2(y0, {:min, min_y}, steps, maps, fn m -> {x0, m} end, :up)

      :down ->
        {_, max_y} = Map.get(range_x, x0)
        do_move_forward2(y0, {:max, max_y}, steps, maps, fn m -> {x0, m} end, :down)
    end
  end

  defp do_move_forward2(v0, {:max, max}, steps, {map, range_y, range_x, edge_map}, fun, facing) do
    if v0 + steps > max do
      case Enum.find(v0..max, fn vv -> Map.get(map, fun.(vv)) == "#" end) do
        nil ->
          {{next_x, next_y}, next_facing} = Map.get(edge_map, {fun.(max), facing})

          if Map.get(map, {next_x, next_y}) == "#" do
            {fun.(max), facing}
          else
            move_forward2(
              {map, range_y, range_x, edge_map},
              {next_x, next_y},
              steps - (max - v0) - 1,
              next_facing
            )
          end

        c ->
          {fun.(c - 1), facing}
      end
    else
      case Enum.find(v0..(v0 + steps), fn vv -> Map.get(map, fun.(vv)) == "#" end) do
        nil ->
          {fun.(v0 + steps), facing}

        c ->
          {fun.(c - 1), facing}
      end
    end
  end

  defp do_move_forward2(v0, {:min, min}, steps, {map, range_y, range_x, edge_map}, fun, facing) do
    if v0 - steps < min do
      case Enum.find(v0..min, fn vv -> Map.get(map, fun.(vv)) == "#" end) do
        nil ->
          {{next_x, next_y}, next_facing} = Map.get(edge_map, {fun.(min), facing})

          if Map.get(map, {next_x, next_y}) == "#" do
            {fun.(min), facing}
          else
            move_forward2(
              {map, range_y, range_x, edge_map},
              {next_x, next_y},
              steps - (v0 - min) - 1,
              next_facing
            )
          end

        c ->
          {fun.(c + 1), facing}
      end
    else
      case Enum.find(v0..(v0 - steps), fn vv -> Map.get(map, fun.(vv)) == "#" end) do
        nil ->
          {fun.(v0 - steps), facing}

        c ->
          {fun.(c + 1), facing}
      end
    end
  end

  # utils

  defp input(), do: Utils.read_input_from_file(2022, 22)
  defp test_input(), do: Utils.read_test_input_from_file(2022, 22)
end
