defmodule Year2021.Day17 do
  defstruct [:target, :current_position, :velocity, :steps, :highest_point]

  ## part 1

  def run1(), do: part1(to_target(input()))
  def test1(), do: part1(to_target(test_input()))

  defp part1(target),
    do: try_velocity(0, 1000, target, []) |> Enum.map(&Map.get(&1, :highest_point)) |> Enum.max()

  ## part 2

  def run2(), do: part2(to_target(input()))
  def test2(), do: part2(to_target(test_input()))

  defp part2(target),
    do:
      0..1000
      |> Enum.reduce(
        0,
        fn vx, acc ->
          -1000..1000
          |> Enum.reduce(
            acc,
            fn vy, new_acc ->
              case step_within_range(%__MODULE__{
                     target: target,
                     current_position: {0, 0},
                     steps: 0,
                     velocity: {vx, vy}
                   }) do
                :too_far -> new_acc
                :too_close -> new_acc
                _ -> new_acc + 1
              end
            end
          )
        end
      )

  defp try_velocity(_, -1000, _, acc), do: acc

  defp try_velocity(vx, vy, target, acc) do
    case step_within_range(%__MODULE__{
           target: target,
           current_position: {0, 0},
           velocity: {vx, vy},
           highest_point: 0,
           steps: 0
         }) do
      :too_far -> try_velocity(0, vy - 1, target, acc)
      :too_close -> try_velocity(vx + 1, vy, target, acc)
      state -> try_velocity(vx + 1, vy, target, [state | acc])
    end
  end

  defp step_within_range(
         %__MODULE__{
           target: [[min_x, max_x], [min_y, max_y]],
           current_position: {x, y}
         } = state
       ) do
    case is_within_range([min_x, max_x], x) && is_within_range([min_y, max_y], y) do
      true -> state
      false -> do_step(state)
    end
  end

  defp do_step(
         %__MODULE__{
           target: [[min_x, _max_x], [_min_y, _max_y]],
           current_position: {x, _y},
           velocity: {vx, _vy}
         } = state
       ) do
    case vx do
      0 ->
        case x < min_x do
          true -> :too_close
          false -> cont_step(state)
        end

      _ ->
        cont_step(state)
    end
  end

  defp cont_step(
         %__MODULE__{
           target: [[_min_x, max_x], [min_y, _max_y]],
           current_position: {x, y},
           velocity: {vx, vy},
           highest_point: h_point,
           steps: steps
         } = state
       ) do
    case x > max_x || y < min_y do
      true ->
        :too_far

      _ ->
        step_within_range(%__MODULE__{
          state
          | current_position: {x + vx, y + vy},
            velocity: next_velocity({vx, vy}),
            steps: steps + 1,
            highest_point: max(h_point, y + vy)
        })
    end
  end

  defp is_within_range([min, max], val), do: val >= min && val <= max

  defp next_velocity({0, y}), do: {0, y - 1}
  defp next_velocity({x, y}), do: {x - 1, y - 1}

  ## utils

  defp to_target("target area: " <> area),
    do:
      area
      |> String.split(", ")
      |> Enum.map(fn str ->
        str
        |> String.slice(2..-1)
        |> String.split("..")
        |> Enum.map(&String.to_integer/1)
      end)

  defp input(), do: Utils.read_input_from_file(2021, 17)
  defp test_input(), do: Utils.read_test_input_from_file(2021, 17)
end
