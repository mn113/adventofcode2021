defmodule Day03 do
  defp read_input do
    File.read!(Path.expand("../inputs/input03.txt"))
    |> String.split("\n")
  end

  defp count_bits(input) do
    initial_columns = Map.new(Enum.to_list(0..11), fn k -> {k, 0} end)

    input
    |> Enum.reduce(
        initial_columns,
        fn binstr, cols_acc ->
            for {d, k} <- Enum.with_index(String.graphemes(binstr)), reduce: cols_acc do
                str_acc -> Map.update!(str_acc, k, &(&1 + if d == "1", do: 1, else: -1))
            end
        end
    )
    |> Map.values
  end

  defp map_count_to_bit(count) do
    if count >= 0, do: "1", else: "0"
  end

  defp find_most_common_bits(input) do
    input
    |> count_bits
    |> Enum.map(&map_count_to_bit/1)
    |> Enum.join
  end

  defp find_least_common_bits(input) do
    input
    |> find_most_common_bits
    |> invert_binary
  end

  defp invert_binary(binstr) do
    Enum.join(for d <- String.graphemes(binstr), do: if d == "1", do: "0", else: "1")
  end

  @doc """
  Count the most common binary digit in each position. Multiply result with its inverse.
  """
  def part1 do
    # gamma = most common bit in each position
    gamma = read_input()
    |> find_most_common_bits
    |> IO.inspect(label: "g")

    # epsilon = least common bit in each position
    epsilon = invert_binary(gamma)
    |> IO.inspect(label: "e")

    String.to_integer(gamma, 2) * String.to_integer(epsilon, 2)
    |> IO.inspect(label: "P1")
  end

  @doc """
  Calculate 2 more binary strings and their product
  """
  def part2 do
    input = read_input()

    gamma = input |> find_most_common_bits |> IO.inspect(label: "g")
    epsilon = input |> find_least_common_bits |> IO.inspect(label: "e")

    # find input number most closely matching gamma
    # filter, recalculate gamma, advance bit position
    i = 0
    oxy_list = Enum.filter(input, fn bitstr -> String.at(bitstr, i) == String.at(gamma, i) end)
    gamma = find_most_common_bits(oxy_list)
    i = 1
    oxy_list = Enum.filter(oxy_list, fn bitstr -> String.at(bitstr, i) == String.at(gamma, i) end)
    gamma = find_most_common_bits(oxy_list)
    i = 2
    oxy_list = Enum.filter(oxy_list, fn bitstr -> String.at(bitstr, i) == String.at(gamma, i) end)
    gamma = find_most_common_bits(oxy_list)
    i = 3
    oxy_list = Enum.filter(oxy_list, fn bitstr -> String.at(bitstr, i) == String.at(gamma, i) end)
    gamma = find_most_common_bits(oxy_list)
    i = 4
    oxy_list = Enum.filter(oxy_list, fn bitstr -> String.at(bitstr, i) == String.at(gamma, i) end)
    gamma = find_most_common_bits(oxy_list)
    i = 5
    oxy_list = Enum.filter(oxy_list, fn bitstr -> String.at(bitstr, i) == String.at(gamma, i) end)
    gamma = find_most_common_bits(oxy_list)
    i = 6
    oxy_list = Enum.filter(oxy_list, fn bitstr -> String.at(bitstr, i) == String.at(gamma, i) end)
    gamma = find_most_common_bits(oxy_list)
    i = 7
    oxy_list = Enum.filter(oxy_list, fn bitstr -> String.at(bitstr, i) == String.at(gamma, i) end)
    gamma = find_most_common_bits(oxy_list)
    i = 8
    oxy_list = Enum.filter(oxy_list, fn bitstr -> String.at(bitstr, i) == String.at(gamma, i) end)
    gamma = find_most_common_bits(oxy_list)
    i = 9
    oxy_list = Enum.filter(oxy_list, fn bitstr -> String.at(bitstr, i) == String.at(gamma, i) end)
    gamma = find_most_common_bits(oxy_list)
    i = 10
    oxy_list = Enum.filter(oxy_list, fn bitstr -> String.at(bitstr, i) == String.at(gamma, i) end)
    gamma = find_most_common_bits(oxy_list)
    i = 11
    oxy_list = Enum.filter(oxy_list, fn bitstr -> String.at(bitstr, i) == String.at(gamma, i) end)
    |> IO.inspect(label: "Oxy")

    # find input number most closely matching epsilon
    i = 0
    co2_list = Enum.filter(input, fn bitstr -> String.at(bitstr, i) == String.at(epsilon, i) end)
    epsilon = find_least_common_bits(co2_list)
    i = 1
    co2_list = Enum.filter(co2_list, fn bitstr -> String.at(bitstr, i) == String.at(epsilon, i) end)
    epsilon = find_least_common_bits(co2_list)
    i = 2
    co2_list = Enum.filter(co2_list, fn bitstr -> String.at(bitstr, i) == String.at(epsilon, i) end)
    epsilon = find_least_common_bits(co2_list)
    i = 3
    co2_list = Enum.filter(co2_list, fn bitstr -> String.at(bitstr, i) == String.at(epsilon, i) end)
    epsilon = find_least_common_bits(co2_list)
    i = 4
    co2_list = Enum.filter(co2_list, fn bitstr -> String.at(bitstr, i) == String.at(epsilon, i) end)
    epsilon = find_least_common_bits(co2_list)
    i = 5
    co2_list = Enum.filter(co2_list, fn bitstr -> String.at(bitstr, i) == String.at(epsilon, i) end)
    epsilon = find_least_common_bits(co2_list)
    i = 6
    co2_list = Enum.filter(co2_list, fn bitstr -> String.at(bitstr, i) == String.at(epsilon, i) end)
    epsilon = find_least_common_bits(co2_list)
    i = 7
    co2_list = Enum.filter(co2_list, fn bitstr -> String.at(bitstr, i) == String.at(epsilon, i) end)
    epsilon = find_least_common_bits(co2_list)
    i = 8
    co2_list = Enum.filter(co2_list, fn bitstr -> String.at(bitstr, i) == String.at(epsilon, i) end)
    |> IO.inspect(label: "CO2")

    String.to_integer(Enum.at(oxy_list, 0), 2) * String.to_integer(Enum.at(co2_list, 0), 2)
    |> IO.inspect(label: "P2")
  end
end

# P1: 2967914
# P2: 7041258
