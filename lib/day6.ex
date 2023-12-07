defmodule Day6 do
  use AOC, day: 6

  @digits ~r{\d+}

  def integers_between({a, b}) do
    round(:math.floor(b) - :math.ceil(a) + 1)
  end

  def pq_zeros(p, q) do
    {-p / 2 - :math.sqrt(p ** 2 / 4 - q - 1), -p / 2 + :math.sqrt(p ** 2 / 4 - q - 1)}
  end

  def single_int([num]) do
    String.to_integer(num)
  end

  def part1(input) do
    [timeline, distanceline] = String.split(input, ~r{\R}, limit: 1, trim: true)
    times = @digits |> Regex.scan(timeline) |> Enum.map(&single_int/1)
    distances = @digits |> Regex.scan(distanceline) |> Enum.map(&single_int/1)

    times
    |> Enum.zip_with(distances, &pq_zeros/2)
    |> Enum.map(&integers_between/1)
    |> Enum.reduce(1, &(&1 * &2))
  end

  def part2(input) do
    part1(String.replace(input, " ", ""))
  end
end
