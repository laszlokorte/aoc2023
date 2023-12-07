defmodule Day4 do
  use AOC, day: 4

  def find_numbers(str) do
    Regex.scan(~r{\d+}, str)
    |> Enum.map(&List.first/1)
    |> Enum.map(&String.to_integer/1)
    |> Enum.into(MapSet.new())
  end

  def score_points(hits), do: if(hits > 0, do: 2 ** (hits - 1), else: 0)

  def count_matches(line) do
    [_, winners, actuals] = String.split(line, [":", "|"])

    find_numbers(actuals)
    |> MapSet.intersection(find_numbers(winners))
    |> MapSet.size()
  end

  def sum_lists([], []), do: []
  def sum_lists([h | tail], []), do: [h | tail]
  def sum_lists([], [h | tail]), do: [h | tail]
  def sum_lists([x | xt], [y | yt]), do: [x + y | sum_lists(xt, yt)]

  def count_total_cards(hits_per_card) do
    Enum.reduce(hits_per_card, {0, []}, fn
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

  def part1(input) do
    input
    |> String.split(~r{\R}, trim: true)
    |> Enum.map(&Day4.count_matches/1)
    |> Enum.map(&Day4.score_points/1)
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> String.split(~r{\R}, trim: true)
    |> Enum.map(&Day4.count_matches/1)
    |> Day4.count_total_cards()
  end
end
