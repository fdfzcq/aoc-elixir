defmodule Year2021.Day23 do
  # 0..9
  defstruct [:energy, :position, :energy_acc]
  def run1(), do: part1(input())
  def test1(), do: part1(test_input())

  defp part1(input) do
    position = Enum.with_index(input)
    |> Enum.reduce(%{},
      fn {[c1, c2], i}, m ->
        Map.put(m, {c1, i}, {2 * (i + 1), 1})
        |> Map.put({c2, i}, {2 * (i - 1), 2})
      end)

    step(%__MODULE__{energy: 0, position: position, energy_acc: []})
  end

  defp step(%__MODULE__{energy_acc: energy_acc} = state) do
    case is_final_state(state) do
      true -> %__MODULE__{state|energy_acc: [Map.get(state, :energy)|energy_acc]}
      false -> do_step(state)
    end
  end

  defp is_final_state(%__MODULE__{position: positions}), do:
    Enum.all?(positions,
      fn {{c, _}, p} ->
        case is_integer(p) do
          true -> false
          false ->
            {i, _} = p
            is_correct_cell(i, c)
        end
      end)

  defp is_correct_cell(i, c), do: i == target(c)

  defp do_step(state) do
    state |> move_to_correct_cell() |> move_one_out_of_cell()
  end

  defp move_one_out_of_cell(%__MODULE__{position: positions, energy: energy} = state) do
    in_cell_amphs = Enum.filter(positions, fn {_, p} -> !is_integer(p) end)
                    |> Enum.filter(fn {{c, _}, {i, _}} -> i != target(c) end)
                    |> Enum.filter(fn {{_, _}, {i, d}} ->
                      case d do
                        2 -> !Enum.any?(positions, fn {{_, _}, p} ->
                                case is_integer(p) do
                                  true -> false
                                  false ->
                                    {j, t} = p
                                    j == i && t == 1
                                end
                              end)
                        _ -> true
                      end
                    end)
    case in_cell_amphs do
      [] -> case move_to_correct_cell(state) do
              st when st == state -> state
              new_state -> step(new_state)
            end
      _ ->
        Enum.map(IO.inspect(in_cell_amphs),
          fn {{c, x}, {i, d}} ->
            possible_positions(positions, i)
            |> Enum.reduce(state,
              fn pos, %__MODULE__{energy_acc: energy_acc} ->
                step(%__MODULE__{
                  energy: energy + to_energy(c, pos, i, d),
                  position: Map.put(positions, {c, x}, pos),
                  energy_acc: energy_acc})
              end)
          end)
    end
  end

  defp possible_positions(positions, i) do
    [0, 1, 3, 5, 7, 9, 10]
    |> Enum.filter(fn q ->
      Enum.filter(positions, fn {_, p} -> is_integer(p) end)
      |> Enum.all?(fn {_, p} -> !is_between(p, i, q) end)
    end)
  end

  defp move_to_correct_cell(%__MODULE__{position: positions, energy: energy} = state) do
    filtered_positions = positions
    |> Enum.filter(fn {{_, _}, i} -> is_integer(i) end)
    case filtered_positions do
      [] -> state
      _ ->
        {new_positions, new_energy} = try_move_to_cells(filtered_positions, positions, energy)
        %__MODULE__{state|position: new_positions, energy: new_energy}
    end
  end

  defp try_move_to_cells([], positions, energy), do: {positions, energy}
  defp try_move_to_cells([{{c, v}, i}|t], positions, energy) do
    case find_reachable_target_cell(c, i, positions) do
      :no_match -> try_move_to_cells(t, positions, energy)
      d -> try_move_to_cells(t, Map.put(positions, {c, v}, {target(c), d}), energy + to_energy(c, i, target(c), d))
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
      fn {{c, _}, p} ->
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
    case cells do
      [] -> 2
      [_] -> 1
    end
  end

  ## part 2

  def run2(), do: part2(input())
  def test2(), do: part2(test_input())

  defp part2(str) do

  end

  # utils

  defp input(), do: [["C", "D"], ["C", "D"], ["A", "B"], ["B", "A"]]
  defp test_input(), do: [["B", "A"], ["C", "D"], ["B", "C"], ["D", "A"]]
end
