defmodule Day6 do
  use AOC, day: 6

  import Enum

  @digits ~r{\d+}
  @line_break_pattern ~r{\R}

  def integers_between({a, b}) do
    round(:math.floor(b) - :math.ceil(a) + 1)
  end

  def pq_zeros(p, q) when p * p > q * 4 do
    {-p / 2 - :math.sqrt(p ** 2 / 4 - q - 1), -p / 2 + :math.sqrt(p ** 2 / 4 - q - 1)}
  end

  def single_int([num]) do
    String.to_integer(num)
  end

  def part(1, input, _env) do
    [timeline, distanceline] = String.split(input, @line_break_pattern, limit: 1, trim: true)
    times = @digits |> Regex.scan(timeline) |> map(&single_int/1)
    distances = @digits |> Regex.scan(distanceline) |> map(&single_int/1)

    times
    |> zip_with(distances, &pq_zeros/2)
    |> map(&integers_between/1)
    |> reduce(1, &(&1 * &2))
  end

  def part(2, input, env) do
    part(1, String.replace(input, " ", ""), env)
  end
end
