defmodule Day10 do
  defp read_input do
    File.read!(Path.expand("../inputs/input10.txt"))
    |> String.split("\n")
  end

  # Repeatedly remove all consecutive pairs (), [], {}, <> from sequence
  defp cleanup(line, times \\ 10)
  defp cleanup(line, 0), do: line

  defp cleanup(line, times) do
    # brute force pair replacement - global by default in Elixir
    line =
      line
      |> String.replace("()", "")
      |> String.replace("[]", "")
      |> String.replace("{}", "")
      |> String.replace("<>", "")

    cleanup(line, times - 1)
  end

  # Detect what type of line we have
  defp analyse(line) do
    cond do
      # all consumed -> valid line
      String.length(line) == 0 ->
        {line, :valid}

      # just openers remain -> incomplete line
      String.match?(line, ~r/^[\(\[\{\<]+$/) ->
        {line, :incomplete}

      # intruder -> corrupted line
      true ->
        {line, :corrupted}
    end
  end

  # Get the score of the first closing char in sequence
  defp first_closing_char_score(str) do
    c =
      str
      |> String.graphemes()
      |> Enum.find(fn g -> String.contains?(")]}>", g) end)

    case c do
      ")" -> 3
      "]" -> 57
      "}" -> 1197
      ">" -> 25137
    end
  end

  # Mirror a sequence made of opening brackets
  defp autocomplete(str) do
    str
    |> String.reverse()
    |> String.replace("(", ")")
    |> String.replace("[", "]")
    |> String.replace("{", "}")
    |> String.replace("<", ">")
  end

  # Compute the score of a closing sequence
  defp score(str) do
    str
    |> String.graphemes()
    |> Enum.map(fn c ->
      case c do
        ")" -> 1
        "]" -> 2
        "}" -> 3
        ">" -> 4
      end
    end)
    |> Enum.reduce(0, fn c, acc -> acc * 5 + c end)
  end

  @doc """
  Count and score the first invalid chars in corrupt input lines
  """
  def part1 do
    read_input()
    |> Enum.map(&cleanup/1)
    |> Enum.map(&analyse/1)
    |> Enum.map(fn {line, status} ->
      if status == :corrupted, do: first_closing_char_score(line)
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.sum()
    |> IO.inspect(label: "P1")
  end

  @doc """
  Score the completion sequences of incomplete input lines
  """
  def part2 do
    scores =
      read_input()
      |> Enum.map(&cleanup/1)
      |> Enum.map(&analyse/1)
      |> Enum.map(fn {line, status} ->
        if status == :incomplete, do: score(autocomplete(line))
      end)
      |> Enum.reject(&is_nil/1)
      |> Enum.sort()

    scores
    |> Enum.drop(div(Enum.count(scores), 2))
    |> Enum.at(0)
    |> IO.inspect(label: "P2")
  end
end

# P1: 193275
# P2: 2429644557
