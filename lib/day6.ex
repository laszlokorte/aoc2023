defmodule Day6 do
  use AOC, day: 6

  @digits ~r{\d+}

  def part1(input) do
    [timeline, distanceline] = String.split(input, "\n", limit: 1, trim: true)
    times = Regex.scan(@digits, timeline) |> Enum.map(fn [num] -> String.to_integer(num) end)

    distances =
      Regex.scan(@digits, distanceline) |> Enum.map(fn [num] -> String.to_integer(num) end)

    choices =
      times
      |> Enum.map(fn max_time ->
        0..max_time |> Enum.map(fn hold -> (max_time - hold) * hold end)
      end)

    result =
      Enum.with_index(choices)
      |> Enum.map(fn
        {c, i} -> c |> Enum.filter(fn res -> res > Enum.at(distances, i) end) |> Enum.count()
      end)
      |> Enum.reduce(1, &(&1 * &2))

    result
  end

  def part2(input) do
    part1(String.replace(input, " ", ""))
  end
end
