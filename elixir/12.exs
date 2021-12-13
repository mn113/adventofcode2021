defmodule Day12 do
  @single_small_cave_limit 2

  defp read_input do
    pairs = File.read!(Path.expand("../inputs/input12.txt"))
    |> String.split("\n")
    |> Enum.map(fn line -> String.split(line, "-") end)

    reversed_pairs = for [p1,p2] <- pairs, do: [p2,p1]

    pairs ++ reversed_pairs
    |> Enum.filter(fn [p1,p2] -> p2 != "start" && p1 != "end" end)
  end

  @doc """
  Count number of times most frequence lowercase element appears
  """
  defp count_most_frequent_lowercase(route) do
    route
    |> Enum.filter(fn node -> node == String.downcase(node) end)
    |> Enum.frequencies
    |> Map.values
    |> Enum.max
  end

  @doc """
  Count number of lowercase elements appearing more than once
  """
  defp count_repeat_lowercase(route) do
    route
    |> Enum.filter(fn node -> node == String.downcase(node) end)
    |> Enum.filter(fn node ->
      Enum.count(route, fn el -> el == node end) > 1
    end)
    |> Enum.uniq
    |> Enum.count
  end

  @doc """
  Given a list of partial routes, append next valid steps to all routes
  """
  defp extend_routes(pairs, routes) do
    routes
    |> Enum.reject(fn route ->
      count_most_frequent_lowercase(route) > 2 # optimisation for part 2
    end)
    |> Enum.reject(fn route ->
      count_repeat_lowercase(route) > 1 # optimisation for part 2
    end)
    |> Enum.reduce([], fn route, acc ->
      last = Enum.at(route, -1)
      if last == "end" do
        acc ++ [route]
      else
        longerroute = pairs
        # next link must match last node
        |> Enum.filter(fn [p1,_] -> p1 == last end)
        # limit to number of lowercase node uses
        |> Enum.filter(fn [_,p2] ->
          p2 == String.upcase(p2) ||
          Enum.count(route, fn x -> x == p2 end) < @single_small_cave_limit
        end)
        |> Enum.map(fn [_,p2] -> p2 end)
        |> Enum.map(fn next -> route ++ [next] end)
        acc ++ longerroute
      end
    end)
  end

  @doc """
  Build a list of all valid routes from "start" to "end". Recursive.
  """
  defp build_all_routes(pairs, partial_routes \\ [["start"]], complete_routes \\ []) do
    # extend once
    new_routes = extend_routes(pairs, partial_routes)
    {new_complete_routes, new_partial_routes} = Enum.split_with(new_routes, fn route -> Enum.at(route, -1) == "end" end)

    IO.inspect({Enum.count(new_partial_routes), Enum.count(new_complete_routes)})
    if Enum.count(partial_routes) == 0 do
      # all routes end in "end" - we're done
      complete_routes ++ new_complete_routes
    else
      # extend again
      build_all_routes(pairs, new_partial_routes, complete_routes ++ new_complete_routes)
    end
  end

  @doc """
  Count the distinct routes through the cave system. Small caves visitable 1 time.
  """
  def part1 do
    read_input()
    |> build_all_routes
    |> Enum.count
    |> IO.inspect
  end

  @doc """
  Count the distinct routes through the cave system. Small caves visitable 2 times.
  """
  def part2 do
    read_input()
    |> build_all_routes
    # |> Enum.reject(fn route ->
    #   count_repeat_lowercase(route) > 1
    # end)
    |> Enum.count
    |> IO.inspect
  end
end

# P1: 3421
# P2: 84870