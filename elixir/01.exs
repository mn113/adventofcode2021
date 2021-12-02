defmodule Day01 do
  defp read_input do
    File.read!(Path.expand("../inputs/input01.txt"))
    |> String.split("\n")
    |> Enum.map(fn line -> line |> Integer.parse() end)
    |> Enum.map(fn {num, _} -> num end)
  end

  @doc """
  Count the number of increasing pairs in the input list
  """
  def part1 do
    input = read_input()

    input
    |> Enum.drop(1)
    |> Enum.with_index()
    |> Enum.filter(fn {_, i} ->
      Enum.at(input, i) < Enum.at(input, i + 1)
    end)
    |> length
    |> IO.inspect()
  end

  @doc """
  Count the number of times the sum of 3 consecutive elements increases in the input list
  """
  def part2 do
    input = read_input()

    input
    |> Enum.drop(3)
    |> Enum.with_index()
    |> Enum.filter(fn {_, i} ->
      # items i+1 & i+2 would be equal on each side of comparison
      Enum.at(input, i) < Enum.at(input, i + 3)
    end)
    |> length
    |> IO.inspect()
  end
end

# P1: 1559
# P1: 1600
