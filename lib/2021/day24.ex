defmodule Year2021.Day24 do
  def run1(), do: part1(input())

  defp part1(str) do
    instructions = String.split(str, "\n")
    find_largest_valid_monad(1, instructions, 0, MapSet.new(), "")
  end

  ##

  defp find_largest_valid_monad(9, _, _, mem, _), do: {mem, :invalid}

  defp find_largest_valid_monad(_, [], z, mem, monad) do
    case z == 0 do
      true -> {mem, monad}
      false -> {mem, :invalid}
    end
  end

  defp find_largest_valid_monad(_, _, z, mem, _) when z > 26 * 26 * 26 * 26 * 26,
    do: {mem, :invalid}

  defp find_largest_valid_monad(n, [h1, h2 | t], old_z, mem, monad)
       when old_z <= 26 * 26 * 26 * 26 * 26 do
    IO.inspect(monad)
    [v1, v2, v3] = String.split(h2, ",") |> Enum.map(&String.to_integer/1)
    w = n

    case MapSet.member?(mem, {v1, v2, v3, old_z}) do
      true ->
        {mem, :invalid}

      false ->
        new_z =
          case rem(old_z, 26) + v2 == n do
            true -> div(old_z, v1)
            false -> 26 * div(old_z, v1) + w + v3
          end

        {new_mem, res} = find_largest_valid_monad(1, t, new_z, mem, monad <> Integer.to_string(n))

        case res do
          :invalid ->
            {new_mem, :invalid}

            case find_largest_valid_monad(n + 1, [h1, h2 | t], old_z, new_mem, monad) do
              {new_mem2, :invalid} -> {MapSet.put(new_mem2, {v1, v2, v3, old_z}), :invalid}
              {new_mem2, new_monad} -> {new_mem2, new_monad}
            end

          new_monad ->
            {new_mem, new_monad}
        end
    end
  end

  ## part 2

  def run2(), do: part2(input())

  defp part2(str) do
  end

  # utils

  defp input(), do: Utils.read_input_from_file(2021, 24)
end
