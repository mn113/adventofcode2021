defmodule Day06 do
  # Directed Cyclic Graph
  @fish_links %{
    "8" => "7",
    "7" => "6",
    "6" => "5",
    "5" => "4",
    "4" => "3",
    "3" => "2",
    "2" => "1",
    "1" => "0",
    "0" => "-1" # holding state so 7 -> 6 can be merged with -1 -> 6
    # "-1" => "6" # the cyclic edge, which is executed manually
  }

  @type fish_age :: String.t
  @type fish_ctr :: %{fish_age => non_neg_integer}

  defp read_input do
    File.read!(Path.expand("../inputs/input06.txt"))
    |> String.split(",")
    # |> Enum.map(&String.to_integer/1)
    |> Enum.frequencies
  end

  defp update_fish_age_counts(fish_ctr) do
    zeros = Map.get(fish_ctr, "0", 0)

    fish_ctr
    |> Map.to_list
    # replace each fish age count onto the next age key it is linked to
    |> Enum.map(fn {age, count} ->
      new_age = Map.get(@fish_links, age)
      {new_age, count}
    end)
    |> Map.new
    # make new babies: all zeros become 8's
    |> Map.put("8", zeros)
    # reset ages; add 7 -> 6 count to -1 -> 6 count
    |> Map.merge(%{ "6" => zeros }, fn _k, v1, v2 -> v1 + v2 end)
    |> Map.delete("-1")
  end

  defp loop(fish_ctr, 0), do: fish_ctr
  defp loop(fish_ctr, remaining) do
    fish_ctr = update_fish_age_counts(fish_ctr)
    loop(fish_ctr, remaining - 1)
  end

  @doc """
  Calculate the number of fish after 80 days
  """
  def part1 do
    read_input()
    |> loop(80)
    |> Map.values
    |> Enum.reduce(&+/2)
    |> IO.inspect(label: "P1")
  end

  @doc """
  Calculate the number of fish after 256 days
  """
  def part2 do
    read_input()
    |> loop(256)
    |> Map.values
    |> Enum.reduce(&+/2)
    |> IO.inspect(label: "P2")
  end
end

# P1: 379414
# P2: 1705008653296