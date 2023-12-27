defmodule Day7 do
  use AOC, day: 7

  import Enum

  @line_break_pattern ~r{\R}
  @cards_part1 ["A", "K", "Q", "J", "T", "9", "8", "7", "6", "5", "4", "3", "2"]
  @cards_part2 ["A", "K", "Q", "T", "9", "8", "7", "6", "5", "4", "3", "2", "J"]
  @jokers_part1 MapSet.new()
  @jokers_part2 MapSet.new(["J"])

  def card_rank(card, card_order) do
    find_index(card_order, &(&1 == card))
  end

  def hand_rank_sorted([c, c, c, c, c]), do: 0
  def hand_rank_sorted([c, c, c, c, _]), do: 1
  def hand_rank_sorted([c, c, c, d, d]), do: 2
  def hand_rank_sorted([c, c, c, _, _]), do: 3
  def hand_rank_sorted([c, c, d, d, _]), do: 4
  def hand_rank_sorted([c, c, _, _, _]), do: 5
  def hand_rank_sorted([_, _, _, _, _]), do: 6

  def apply_joker(original, joker) do
    without_jokers = original |> filter(&(&1 not in joker))
    missing = count(original) - count(without_jokers)

    without_jokers
    |> List.first(List.first(original))
    |> List.duplicate(missing)
    |> concat(without_jokers)
  end

  def hand_bid_rank({_bid, hand}, card_order, joker) do
    hand |> String.codepoints() |> hand_rank(card_order, joker)
  end

  def hand_rank(hand, card_order, joker) do
    kind_rank =
      hand
      |> sort_by(&card_rank(&1, card_order))
      |> chunk_by(& &1)
      |> sort_by(&count/1)
      |> reverse()
      |> List.flatten()
      |> apply_joker(joker)
      |> hand_rank_sorted

    card_ranks = hand |> map(&card_rank(&1, card_order))

    [kind_rank | card_ranks]
  end

  def parse_hand(line) do
    [hand, bid] = String.split(line, " ", trim: true)

    {String.to_integer(bid), hand}
  end

  def calculate_hands(input, card_order, joker) do
    input
    |> String.split(@line_break_pattern, trim: true)
    |> map(&parse_hand(&1))
    |> sort_by(&hand_bid_rank(&1, card_order, joker))
    |> map(&elem(&1, 0))
    |> reverse()
    |> with_index(1)
    |> map(&Tuple.product/1)
    |> sum()
  end

  def part(1, input, _env) do
    calculate_hands(input, @cards_part1, @jokers_part1)
  end

  def part(2, input, _env) do
    calculate_hands(input, @cards_part2, @jokers_part2)
  end
end
