defmodule Day2 do
  use AOC, day: 2

  import Enum

  @line_break_pattern ~r{\R}
  @line_pattern ~r/Game (?<number>\d+): (?<rounds>.*)/
  @round_pattern ~r/(?<count>\d+) (?<color>\w+)/
  @setup_part1 %{
    "red" => 12,
    "green" => 13,
    "blue" => 14
  }

  def parse_rounds(all_rounds) do
    all_rounds
    |> String.split(";", trim: true)
    |> map(&Regex.scan(@round_pattern, &1, capture: :all_but_first))
    |> map(&into(&1, %{}, fn [a, b] -> {b, a |> String.to_integer()} end))
  end

  def parse_game(line) do
    [number, all_rounds] = Regex.run(@line_pattern, line, capture: [:number, :rounds])

    {
      number |> String.to_integer(),
      all_rounds |> Day2.parse_rounds()
    }
  end

  def round_is_possible(one_round, max_cubes) do
    one_round |> all?(fn {col, num} -> max_cubes[col] >= num end)
  end

  def game_is_possible({_, rounds}) do
    all?(rounds, &Day2.round_is_possible(&1, @setup_part1))
  end

  def required_cube_count({_, rounds}) do
    reduce(
      rounds,
      %{},
      &Map.merge(&1, &2, fn _k, x, y ->
        Kernel.max(x, y)
      end)
    )
  end

  def cubes_power(cubes) do
    Map.values(cubes) |> reduce(1, &(&1 * &2))
  end

  def part(1, input) do
    input
    |> String.split(@line_break_pattern, trim: true)
    |> map(&Day2.parse_game/1)
    |> filter(&Day2.game_is_possible/1)
    |> map(&elem(&1, 0))
    |> sum()
  end

  def part(2, input) do
    input
    |> String.split(@line_break_pattern, trim: true)
    |> map(&Day2.parse_game/1)
    |> map(&Day2.required_cube_count/1)
    |> map(&Day2.cubes_power/1)
    |> sum()
  end
end
