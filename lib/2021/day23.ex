defmodule Year2021.Day23 do
  # 0..9
  defstruct [:energy, :position, :least_energy, :mem, :moved]
  def run1(), do: part1(input())
  def test1(), do: part1(test_input())

  defp part1(input) do
    position = Enum.with_index(input)
    |> Enum.reduce([],
      fn {inputs, i}, l ->
        inputs
        |> Enum.with_index()
        |> Enum.reduce(l, fn {cv, j}, acc -> [{cv, {2 * (i + 1), j + 1}}|acc] end)
        |> Enum.sort()
      end)
    {v, _} = do_step(%__MODULE__{energy: 0, position: position, least_energy: 9999999, mem: %{}, moved: MapSet.new()})
    v
  end

  defp is_final_state(%__MODULE__{position: positions}), do:
    Enum.all?(positions,
      fn {c, p} ->
        case is_integer(p) do
          true -> false
          false ->
            {i, _} = p
            is_correct_cell(i, c)
        end
      end)

  defp is_correct_cell(i, c), do: i == target(c)

  defp do_step(state) do
    case Map.get(state, :energy) > Map.get(state, :least_energy) do
      true -> {Map.get(state, :least_energy), Map.get(state, :mem)}
      false -> new_state = move_to_correct_cell(state)
        case is_final_state(new_state) do
          true -> {min(Map.get(new_state, :energy), Map.get(new_state, :least_energy)),
                   Map.get(new_state, :mem)}
          false -> move_one_out_of_cell(new_state)
        end
    end
  end

  defp move_one_out_of_cell(%__MODULE__{position: positions, mem: mem, least_energy: l, energy: energy} = state) do
    case Map.get(mem, positions) do
      nil -> do_move_one_out_of_cell(state)
      val -> {min(val + energy, l), mem}
    end
  end

  defp do_move_one_out_of_cell(
    %__MODULE__{position: positions, energy: energy, least_energy: energy_acc, mem: mem, moved: moved}) do
    in_cell_amphs = Enum.filter(positions, fn {_, p} -> !is_integer(p) end)
                    |> Enum.filter(fn val -> !MapSet.member?(moved, val) end)
                    |> Enum.filter(fn {c, {i, d}} ->
                        i != target(c) || (Enum.filter(positions, fn {_, p} -> !is_integer(p) end)
                             |> Enum.any?(fn {g, {a, b}} -> a == i && b > d && target(g) != a end))
                      end)
                    |> Enum.filter(fn {_, {i, d}} ->
                        !Enum.any?(positions, fn {_, p} ->
                          case is_integer(p) do
                            true -> false
                            false ->
                              {j, t} = p
                              j == i && t < d
                          end
                        end)
                    end)
    {new_least, new_mem} = Enum.reduce(in_cell_amphs, {9999999, mem},
      fn {c, {i, d}}, {e_acc, mem1} ->
        possible_positions(positions, i)
        |> Enum.reduce({e_acc, mem1},
            fn pos, {e_acc2, mem2} ->
              do_step(%__MODULE__{
                energy: to_energy(c, pos, i, d),
                position: [{c, pos}|Enum.reject(positions, fn m -> m == {c, {i, d}} end)] |> Enum.sort(),
                least_energy: e_acc2,
                moved: moved,
                mem: mem2})
            end)
      end)
    case new_least do
      9999999 -> {energy_acc, new_mem}
      _ ->
        {min(new_least + energy, energy_acc), Map.put(new_mem, positions, min(new_least, energy_acc))}
    end
  end

  defp possible_positions(positions, i) do
    [0, 1, 3, 5, 7, 9, 10]
    |> Enum.filter(fn q ->
      Enum.filter(positions, fn {_, p} -> is_integer(p) end)
      |> Enum.all?(fn {_, p} -> !(is_between(p, i, q) || p == q) end)
    end)
  end

  defp move_to_correct_cell(state) do
    case do_move_to_correct_cell(state) do
      st when st == state -> state
      st -> move_to_correct_cell(st)
    end
  end

  defp do_move_to_correct_cell(%__MODULE__{position: positions, energy: energy, moved: moved} = state) do
    filtered_positions = positions
    |> Enum.filter(fn {_, i} -> is_integer(i) end)
    case filtered_positions do
      [] -> state
      _ ->
        {new_positions, new_energy, new_moved} = try_move_to_cells(filtered_positions, positions, energy, moved)
        %__MODULE__{state|position: new_positions, energy: new_energy, moved: new_moved}
    end
  end

  defp try_move_to_cells([], positions, energy, moved), do: {positions, energy, moved}
  defp try_move_to_cells([{c, i}|t], positions, energy, moved) do
    case find_reachable_target_cell(c, i, positions) do
      :no_match -> try_move_to_cells(t, positions, energy, moved)
      d -> try_move_to_cells(t,
            Enum.sort([{c, {target(c), d}}|Enum.reject(positions, fn val -> val == {c, i} end)]),
            energy + to_energy(c, i, target(c), d),
            MapSet.put(moved, {c, {target(c), d}}))
    end
  end

  defp to_energy(c, i, j, d), do: (abs(i - j) + d) * energy_per_step(c)

  defp energy_per_step("A"), do: 1
  defp energy_per_step("B"), do: 10
  defp energy_per_step("C"), do: 100
  defp energy_per_step("D"), do: 1000

  defp find_reachable_target_cell(c, i, positions) do
    case !Enum.any?(positions, fn {_, p} ->
      case is_integer(p) do
        true -> is_between(p, i, target(c))
        false -> false
      end
    end) && only_contains_valid_amphipods(positions, target(c)) do
      true -> find_valid_cell(positions, target(c))
      false -> :no_match
    end
  end

  defp target("A"), do: 2
  defp target("B"), do: 4
  defp target("C"), do: 6
  defp target("D"), do: 8

  defp is_between(p, v1, v2), do: p > min(v1, v2) && p < max(v1, v2)

  defp only_contains_valid_amphipods(positions, i), do:
    !Enum.any?(positions,
      fn {c, p} ->
        case is_integer(p) do
          true -> false
          _ -> {v, _} = p
               v != target(c) && v == i
        end
      end)

  defp find_valid_cell(positions, i) do
    cells = positions
            |> Enum.filter(fn {_, p} -> !is_integer(p) end)
            |> Enum.filter(fn {_, {v, _}} -> v == i end)
    4 - length(cells)
  end

  ## part 2

  def run2(), do: part2(input())
  def test2(), do: part2(test_input())

  defp part2(str) do

  end

  # utils

  defp input(), do:
    [["C", "D", "D", "D"],
     ["C", "C", "B", "D"],
     ["A", "B", "A", "B"],
     ["B", "A", "C", "A"]]
  defp test_input(), do:
    [["B", "D", "D", "A"],
     ["C", "C", "B", "D"],
     ["B", "B", "A", "C"],
     ["D", "A", "C", "A"]]
end
