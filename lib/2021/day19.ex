defmodule Year2021.Day19 do

  defstruct [:map, :reference_scanner, :checked, :scanners, :to_check, :scanner_positions]

  def run(), do: process(input())
  def test(), do: process(test_input())

  defp process(input), do:
    input
    |> to_scanners()
    |> build_map()
    |> Map.get(:scanner_positions)
    |> largest_dist()

  defp largest_dist(list), do:
    list
    |> Enum.map(
      fn [x1, y1, z1] ->
        Enum.map(list,
          fn [x2, y2, z2] ->
            abs(x1 - x2) + abs(y1 - y2) + abs(z1 - z2)
          end)
      end)
    |> List.flatten()
    |> Enum.max()

  defp build_map(scanners) do
    state = %__MODULE__{
      map: MapSet.new(Enum.at(scanners, 0)),
      scanners: scanners,
      checked: MapSet.new(),
      to_check: MapSet.new(),
      scanner_positions: [[0, 0, 0]]
    }
    build_map(0, state)
  end

  defp build_map(index, state) do
    ref_scanner = state |> Map.get(:scanners) |> Enum.at(index)
    new_state = state
    |> Map.put(:checked, MapSet.put(Map.get(state, :checked), index))
    |> Map.put(:to_check, MapSet.delete(Map.get(state, :to_check), index))
    |> Map.put(:reference_scanner, ref_scanner)
    new_new_state = new_state
    |> Map.get(:scanners)
    |> Enum.with_index()
    |> Enum.filter(fn {_, i} -> !MapSet.member?(Map.get(state, :checked), i) end)
    |> Enum.reduce(new_state, &do_build_map/2)
    IO.inspect(new_new_state)
    case MapSet.size(Map.get(new_new_state, :to_check)) do
      0 -> new_new_state
      _ -> new_new_state |> Map.get(:to_check) |> MapSet.to_list() |> hd() |> build_map(new_new_state)
    end
  end

  defp do_build_map({current_scanner, i}, state) do
    referece_scanner = Map.get(state, :reference_scanner)
    res = find_beacons(referece_scanner, current_scanner)
    case res do
      nil -> state
      {scanner_coor, beacons} ->
        %__MODULE__{state|
          map: MapSet.union(Map.get(state, :map), MapSet.new(beacons)),
          scanners:
            state
            |> Map.get(:scanners)
            |> Enum.with_index()
            |> Enum.map(
              fn {v, index} ->
                case index == i do
                  true -> beacons
                  false -> v
                end
              end
            ),
          to_check: MapSet.put(Map.get(state, :to_check), i),
          scanner_positions: [scanner_coor|Map.get(state, :scanner_positions)]
        }
    end
  end

  defp find_beacons(ref_scanner, cur_scanner) do
    ref_scanner
    |> Enum.reduce_while(nil, &find_beacons(&1, &2, ref_scanner, cur_scanner))
  end

  defp find_beacons(ref_beacon, _, ref_scanner, cur_scanner) do
    cur_scanner
    |> Enum.reduce_while(nil,
      fn cur_beacon, _ ->
        res = ref_beacon
        |> find_possible_scanner_coors(cur_beacon, cur_scanner)
        |> Enum.find(
          fn {_, transformed} ->
            length(Enum.filter(transformed, fn b -> Enum.member?(ref_scanner, b) end)) == 12
          end
        )
        case res do
          nil -> {:cont, {:cont, nil}}
          _ -> {:halt, {:halt, res}}
        end
      end)
  end

  defp find_possible_scanner_coors(ref, cur, beacons), do:
    all_orientations({cur, beacons})
    |> Enum.map(&scanner_coors(ref, &1))

  defp scanner_coors([rx, ry, rz], {[cx, cy, cz], beacons}) do
    [x, y, z] = [rx - cx, ry - cy, rz - cz]
    {[x, y, z],
      Enum.map(beacons,
        fn [xx, yy, zz] ->
          [xx + x, yy + y, zz + z]
      end)}
  end

  ## utils
  def all_orientations({b, beacons}) do
    all_bs = all_orientations(b)
    all_beacons = beacons
    |> Enum.map(&all_orientations/1)
    |> Stream.zip()
    |> Enum.reduce([], fn elements, acc -> acc ++ [Tuple.to_list(elements)] end)
    Enum.zip(all_bs, all_beacons)
  end

  def all_orientations([x, y, z]) do
    [[x, y, z], [y, z, x], [z, y, x], [x, z, y], [y, x, z], [z, x, y]]
    |> Enum.reduce([], fn c, acc -> rotate(c) ++ acc end)
  end

  defp rotate([x, y, z]) do
    Enum.reduce([x, -x], [],
      fn v_x, acc ->
        Enum.reduce([y, -y], acc,
          fn v_y, a ->
            Enum.reduce([z, -z], a,
              fn v_z, b ->
                b ++ [[v_x, v_y, v_z]]
              end)
          end)
      end)
  end

  defp to_scanners(str), do:
    str
    |> String.split("\n\n")
    |> Enum.map(&to_scanner/1)

  defp to_scanner(str), do:
    str
    |> String.split("\n")
    |> Enum.slice(1..-1)
    |> Enum.map(&to_coordinates/1)
    #{id, coordinates}

  defp to_coordinates(str), do:
    str
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)

  defp input(), do: Utils.read_input_from_file(2021, 19)
  defp test_input(), do: Utils.read_test_input_from_file(2021, 19)
end
