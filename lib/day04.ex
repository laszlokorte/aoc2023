defmodule Day4 do
  use AOC, day: 4

  import Enum
  import String

  @line_break_pattern ~r{\R}
  @digits_pattern ~r{\d+}
  @separators [":", "|"]

  def find_numbers(str) do
    @digits_pattern
    |> Regex.scan(str)
    |> map(&List.first/1)
    |> map(&to_integer/1)
    |> into(MapSet.new())
  end

  def score_points(hits), do: if(hits > 0, do: 2 ** (hits - 1), else: 0)

  def count_matches(line) do
    [_, winners, actuals] = split(line, @separators, parts: 3, trim: true)

    find_numbers(actuals)
    |> MapSet.intersection(find_numbers(winners))
    |> MapSet.size()
  end

  def sum_lists([], []), do: []
  def sum_lists([h | tail], []), do: [h | tail]
  def sum_lists([], [h | tail]), do: [h | tail]
  def sum_lists([x | xt], [y | yt]), do: [x + y | sum_lists(xt, yt)]

  def count_total_cards(hits_per_card) do
    reduce(hits_per_card, {0, []}, fn
      this_card_matches, {sum_of_cards, []} ->
        {sum_of_cards + 1, List.duplicate(1, this_card_matches)}

      this_card_matches, {sum_of_cards, [copies | tail]} ->
        {
          sum_of_cards + copies + 1,
          sum_lists(tail, List.duplicate(copies + 1, this_card_matches))
        }
    end)
    |> elem(0)
  end

  def part(1, input, _env) do
    input
    |> split(@line_break_pattern, trim: true)
    |> map(&Day4.count_matches/1)
    |> map(&Day4.score_points/1)
    |> sum()
  end

  def part(2, input, _env) do
    input
    |> split(@line_break_pattern, trim: true)
    |> map(&Day4.count_matches/1)
    |> Day4.count_total_cards()
  end
end
