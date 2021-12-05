defmodule Day05 do
  defp read_input do
    File.read!(Path.expand("../inputs/input05.txt"))
    |> String.split("\n")
    |> Enum.map(&regex_parse_line/1)
  end

  defp regex_parse_line(line) do
    captures =
      Regex.named_captures(
        ~r/(?<x1>\d+),(?<y1>\d+) -> (?<x2>\d+),(?<y2>\d+)/,
        String.trim(line)
      )

    %{
      :x1 => captures["x1"] |> String.to_integer(),
      :y1 => captures["y1"] |> String.to_integer(),
      :x2 => captures["x2"] |> String.to_integer(),
      :y2 => captures["y2"] |> String.to_integer()
    }
  end

  defp expand_line(%{x1: x1, y1: y1, x2: x2, y2: y2} = _coords, opts) do
    xrange = x1..x2
    yrange = y1..y2

    cond do
      # horizontal
      x1 == x2 ->
        for y <- yrange, do: {x1, y}

      # vertical
      y1 == y2 ->
        for x <- xrange, do: {x, y1}

      # diagonals allowed
      Keyword.get(opts, :allow_diagonals) ->
        Enum.zip(xrange, yrange)

      # diagonals ignored
      true ->
        []
    end
  end

  defp count_hotspots(opts) do
    # use {x,y} tuples as keys in a counter Map
    read_input()
    |> Enum.map(fn line -> expand_line(line, opts) end)
    |> Enum.flat_map(fn x -> x end)
    |> Enum.reduce(
      %{},
      fn point, acc ->
        Map.update(acc, point, 1, &(&1 + 1))
      end
    )
    |> Map.values()
    |> Enum.filter(fn x -> x > 1 end)
    |> length
  end

  @doc """
  Count the number of grid cells containing 2 or more line parts - diagonals excluded
  """
  def part1 do
    count_hotspots(allow_diagonals: false)
    |> IO.inspect(label: "P1")
  end

  @doc """
  Count the number of grid cells containing 2 or more line parts - diagonals included
  """
  def part2 do
    count_hotspots(allow_diagonals: true)
    |> IO.inspect(label: "P2")
  end
end

# P1: 4826
# P2: 16793
