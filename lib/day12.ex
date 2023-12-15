defmodule Day12 do
  use AOC, day: 12

  use Memoize

  @line_break_pattern ~r{\R}
  @comma ","
  @space " "
  @space_between_reps "?"
  @part2_multiplier 5

  @spring_operational ?.
  @spring_damaged ?#
  @spring_unknown ??

  def parse_line(line, multiplier \\ 1) do
    [pattern, counts] = String.split(line, @space, parts: 2)

    springs =
      pattern
      |> List.duplicate(multiplier)
      |> Enum.join(@space_between_reps)

    damage_counts =
      counts
      |> List.duplicate(multiplier)
      |> Enum.join(@comma)
      |> String.split(@comma)
      |> Enum.map(&String.to_integer/1)
      |> Enum.into(<<>>, fn num -> <<num::8>> end)

    {springs, damage_counts}
  end

  defmemo ramaining_combos(springs, counts, in_seq) do
    case {springs, counts, in_seq} do
      {<<>>, <<>>, false} ->
        1

      {<<>>, <<0>>, true} ->
        1

      {<<@spring_operational, rest::binary>>, <<0, counts::binary>>, true} ->
        ramaining_combos(rest, counts, false)

      {<<@spring_operational, rest::binary>>, counts, false} ->
        ramaining_combos(rest, counts, false)

      {<<@spring_damaged, rest::binary>>, <<count_head, count_rst::binary>>, _} ->
        ramaining_combos(rest, <<count_head - 1, count_rst::binary>>, true)

      {<<@spring_unknown, rest::binary>>, <<count_head, count_rst::binary>>, inseq} ->
        ramaining_combos(
          <<@spring_operational, rest::binary>>,
          <<count_head, count_rst::binary>>,
          inseq
        ) +
          ramaining_combos(
            <<@spring_damaged, rest::binary>>,
            <<count_head, count_rst::binary>>,
            inseq
          )

      {<<@spring_unknown, rest::binary>>, <<>>, false} ->
        ramaining_combos(rest, <<>>, false)

      {_, _, _} ->
        0
    end
  end

  def count_combinations({a, b}) do
    ramaining_combos(a, b, false)
  end

  def part1(input) do
    input
    |> String.split(@line_break_pattern)
    |> Enum.map(&parse_line(&1))
    |> Enum.map(&count_combinations/1)
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> String.split(@line_break_pattern)
    |> Enum.map(&parse_line(&1, @part2_multiplier))
    |> Enum.map(&count_combinations/1)
    |> Enum.sum()
  end
end
