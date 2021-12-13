defmodule Day07 do
  defp read_input do
    File.read!(Path.expand("../inputs/input07.txt"))
    |> String.trim
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  @doc """
  Find fuel amount (r) needed to minimise sum of movements to align all crab positions.
  """
  def part1 do
    crabs = read_input()

    (Enum.min(crabs)..Enum.max(crabs))
    |> Enum.map(fn r ->
        crabs
        |> Enum.map(fn c -> abs(c - r) end)
        |> Enum.sum
    end)
    |> Enum.min
    |> IO.inspect
  end

  @doc """
  Find fuel amount (r) needed to minimise sum of movements to align all crab positions.
  Larger movements cost more, e.g. moving 5 costs 1+2+3+4+5
  """
  def part2 do
    crabs = read_input()

    (Enum.min(crabs)..Enum.max(crabs))
    |> Enum.map(fn r ->
        crabs
        |> Enum.map(fn c -> abs(c - r) end)
        |> Enum.map(fn d ->
          cond do
            d > 0 -> Enum.sum(1..d)
            true -> 0
          end
        end)
        |> Enum.sum
    end)
    |> Enum.min
    |> IO.inspect
  end
end

# P1: 328187
# P2: 91257582
