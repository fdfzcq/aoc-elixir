defmodule Year2021.Day16 do
  defstruct [:packet_version, :packet_type, :subpackets, :literal_value, :packet_length]

  def run(), do: process(input())
  def test(), do: process(test_input())

  defp process(hexstring), do:
    hexstring
    |> hexstring_to_bits()
    |> parse_packet(%__MODULE__{subpackets: []})
    |> to_result

  defp to_result(%__MODULE__{packet_type: type, subpackets: subpackets, literal_value: val}) do
    subvalues = Enum.map(subpackets, &to_result/1)
    case type do
      0 -> Enum.sum(subvalues)
      1 -> Enum.reduce(subvalues, 1, &Kernel.*/2)
      2 -> Enum.min(subvalues)
      3 -> Enum.max(subvalues)
      4 -> val
      5 -> to_bit(hd(subvalues) > Enum.at(subvalues, 1))
      6 -> to_bit(hd(subvalues) < Enum.at(subvalues, 1))
      7 -> to_bit(hd(subvalues) == Enum.at(subvalues, 1))
    end
  end

  defp to_bit(true), do: 1
  defp to_bit(false), do: 0

  defp hexstring_to_bits(str) do
    str
    |> String.codepoints()
    |> Enum.map(
      fn c ->
        {integer, _} = Integer.parse(c, 16)
        bits = Integer.digits(integer, 2)
        case length(bits) < 4 do
          true -> List.duplicate(0, 4 - length(bits)) ++ bits
          false -> bits
        end
      end
    )
    |> List.flatten()
  end

  defp parse_packet(bits, packet = %__MODULE__{packet_version: nil}) do
    version = bits |> Enum.slice(0..2) |> Integer.undigits(2)
    type = bits |> Enum.slice(3..5) |> Integer.undigits(2)
    parse_packet(bits, %__MODULE__{packet| packet_version: version, packet_type: type})
  end

  defp parse_packet(bits, packet = %__MODULE__{packet_type: 4}) do
    valuebits = bits
    |> Enum.slice(6..-1)
    |> Enum.chunk_every(5)
    |> Enum.reduce_while([],
      fn chunk, acc ->
        case hd(chunk) do
          0 -> {:halt, Enum.reverse([tl(chunk)|acc])}
          1 -> {:cont, [tl(chunk)|acc]}
        end
      end)
    value = valuebits
    |> List.flatten()
    |> Integer.undigits(2)
    %__MODULE__{ packet | literal_value: value, packet_length: 6 + 5 * length(valuebits)}
  end
  defp parse_packet(bits, packet) do
    length_type = Enum.at(bits, 6)
    packet_length = 7
    subpackets = case length_type do
      0 ->
        length = Enum.slice(bits, 7..21) |> Integer.undigits(2)
        parse_packets(Enum.slice(bits, 22..22 + length - 1), [], nil)
      1 ->
        number_of_subpackets = Enum.slice(bits, 7..17) |> Integer.undigits(2)
        parse_packets(Enum.slice(bits, 18..-1), [], number_of_subpackets)
    end
    packet_length = case length_type do
      0 -> packet_length + 15
      1 -> packet_length + 11
    end
    packet_length = packet_length + Enum.sum(Enum.map(subpackets, fn p -> Map.get(p, :packet_length) end))
    %__MODULE__{packet | subpackets: subpackets, packet_length: packet_length}
  end

  defp parse_packets(bits, packets, number) do
    packet = parse_packet(bits, %__MODULE__{subpackets: []})
    case length(bits) - Map.get(packet, :packet_length) < 11 || length(packets) + 1 == number do
      true -> Enum.reverse([packet|packets])
      false -> parse_packets(Enum.slice(bits, Map.get(packet, :packet_length)..-1), [packet|packets], number)
    end
  end

  defp input(), do: Utils.read_input_from_file(2021, 16)
  defp test_input(), do: Utils.read_test_input_from_file(2021, 16)
end
