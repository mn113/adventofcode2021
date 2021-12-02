defmodule Day02 do
  defp read_input do
    File.read!(Path.expand("../inputs/input02.txt"))
    |> String.split("\n")
    |> Enum.map(fn line ->
      [term, digits] = String.split(line)
      {String.to_atom(term), elem(Integer.parse(digits), 0)}
    end)
  end

  @doc """
  Determine the area travelled by the sub (forward * down)
  """
  def part1 do
    initial = %{forward: 0, up: 0, down: 0}

    collected =
      read_input()
      |> Enum.reduce(
        initial,
        fn {dir, x}, acc ->
          Map.update!(acc, dir, &(&1 + x))
        end
      )

    (collected.forward * abs(collected.down - collected.up))
    |> IO.inspect(label: "P1")
  end

  @doc """
  Determine the new area travelled by the sub (forward * depth)
  """
  def part2 do
    initial = %{forward: 0, depth: 0, aim: 0}

    collected =
      read_input()
      |> Enum.reduce(
        initial,
        fn {dir, x}, acc ->
          case dir do
            :down ->
              acc |> Map.update!(:aim, &(&1 + x))

            :up ->
              acc |> Map.update!(:aim, &(&1 - x))

            :forward ->
              acc
              |> Map.update!(:forward, &(&1 + x))
              |> Map.update!(:depth, &(&1 + x * acc.aim))
          end
        end
      )

    (collected.forward * collected.depth)
    |> IO.inspect(label: "P2")
  end
end

# P1: 1451208
# P2: 1620141160
