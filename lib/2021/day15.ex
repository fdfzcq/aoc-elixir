defmodule Year2021.Day15 do

  def run1(), do: part1(to_map(input()))
  def test1(), do: part1(to_map(test_input()))

  ## part 1 in djikstra/a-star
  defp part1(map), do:
    Graph.a_star(to_graph(map), {0, 0}, destination(map),
      fn _ ->
        200
      end)
    |> Enum.map(fn c -> Map.get(map, c) end)
    |> Enum.sum()
    |> Kernel.-(Map.get(map, {0, 0}))

  defp to_graph(map) do
    g = Graph.add_vertices(Graph.new(), Map.keys(map))
    map
    |> Map.keys()
    |> Enum.reduce(g,
      fn coor, acc ->
        coor
        |> neighbours(destination(map))
        |> Enum.reduce(acc,
          fn next_coor, graph ->
            Graph.add_edge(graph, coor, next_coor, weight: Map.get(map, next_coor))
          end)
      end)
  end

  ## part 1 in bfs - too slow
  def part1_bfs(map) do
    step(:queue.in({{0, 0}, 1, 0, MapSet.new([{0, 0}])}, :queue.new()), map, destination(map), :queue.new())
  end

  defp step(queue, map, destination, acc) do
    {{:value, {coor, val, dist, traversed}}, new_queue} = :queue.out(queue)
    new_acc = case coor == destination do
      true -> IO.inspect(dist) # this will throw an error and stop the program as expected
      false ->
        case dist > straight_path(map, destination) do
          true -> acc
          false ->
            case val do
              1 ->
                coor
                |> neighbours(destination)
                |> Enum.filter(fn c -> !MapSet.member?(traversed, c) end)
                |> Enum.reduce(acc,
                  fn next_coor, a ->
                    :queue.in({next_coor, Map.get(map, next_coor), dist + 1, MapSet.put(traversed, coor)}, a)
                  end
                )
              _ ->
                :queue.in({coor, val - 1, dist + 1, traversed}, acc)
            end
        end
    end
    case :queue.is_empty(new_queue) do
      true -> step(new_acc, map, destination, :queue.new())
      false -> step(new_queue, map, destination, new_acc)
    end
  end

  defp straight_path(map, {_, max_y}), do:
    map
    |> Enum.filter(fn {{x, y}, _} -> x == 0 || y == max_y end)
    |> Enum.map(fn {_, v} -> v end)
    |> Enum.sum()

  defp neighbours({x, y}, {max_x, max_y}), do:
    [{x + 1, y}, {x - 1, y}, {x, y + 1}, {x, y - 1}]
    |> Enum.filter(fn {a, b} -> a >= 0 && b >= 0 && a <= max_x && b <= max_y end)

  defp destination(map), do:
    map
    |> Map.keys()
    |> Enum.max_by(fn {x, y} -> x * y end)

  ## utils

  defp to_map(str), do:
    str
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.reduce(%{}, &to_map(&1, &2))

  defp to_map({line_str, y}, acc_map), do:
    line_str
    |> String.codepoints()
    |> Enum.with_index()
    |> Enum.reduce(acc_map, &(add_points(&1, &2, y)))

  ## part 1
  def add_point({c, x}, map, y), do: Map.put(map, {x, y}, String.to_integer(c))
  ## part 2
  defp add_points({char, x}, map, y) do
    c = String.to_integer(char)
    0..4
    |> Enum.reduce(map,
      fn i, m ->
        0..4
        |> Enum.reduce(m,
          fn j, acc ->
            case c + i + j > 9 do
              true -> Map.put(acc, {x + i * 100, y + j * 100}, c + i + j - 9)
              false -> Map.put(acc, {x + i * 100, y + j * 100}, c + i + j)
            end
          end)
      end)
  end

  defp input(), do: Utils.read_input_from_file(2021, 15)
  defp test_input(), do: Utils.read_test_input_from_file(2021, 15)
end
