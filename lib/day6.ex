defmodule Day6 do
  use AOC, day: 6

  @digits ~r{\d+}

  def integers_between(a,b) do
    round(:math.floor(b)-:math.ceil(a) + 1)
  end

  def pq_zeros(p,q) do
    {-p/2-:math.sqrt(p**2/4-q-1), -p/2+:math.sqrt(p**2/4-q-1)}
  end

  def part1(input) do
    [timeline, distanceline] = String.split(input, "\n", limit: 1, trim: true)
    times = Regex.scan(@digits, timeline) |> Enum.map(fn [num] -> String.to_integer(num) end)
    distances =
      Regex.scan(@digits, distanceline) |> Enum.map(fn [num] -> String.to_integer(num) end)

    times 
    |> Enum.zip_with(distances, &pq_zeros/2) 
    |> Enum.map(fn {a,b} -> integers_between(a,b) end)
    |> Enum.reduce(1, &(&1 * &2))
  end

  def part2(input) do
    part1(String.replace(input, " ", ""))
  end
end
