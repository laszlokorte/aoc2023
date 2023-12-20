defmodule Day12 do
  use AOC, day: 12

  use Memoize
  import Enum

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
      |> join(@space_between_reps)

    damage_counts =
      counts
      |> List.duplicate(multiplier)
      |> join(@comma)
      |> String.split(@comma)
      |> map(&String.to_integer/1)
      |> into(<<>>, fn num -> <<num::8>> end)

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
        [@spring_operational, @spring_damaged]
        |> map(
          &ramaining_combos(
            <<&1, rest::binary>>,
            <<count_head, count_rst::binary>>,
            inseq
          )
        )
        |> sum()

      {<<@spring_unknown, rest::binary>>, <<>>, false} ->
        ramaining_combos(rest, <<>>, false)

      {_, _, _} ->
        0
    end
  end

  def count_combinations({a, b}) do
    ramaining_combos(a, b, false)
  end

  def part(1, input) do
    input
    |> String.split(@line_break_pattern)
    |> map(&parse_line(&1))
    |> map(&count_combinations/1)
    |> sum()
  end

  def part(2, input) do
    input
    |> String.split(@line_break_pattern)
    |> map(&parse_line(&1, @part2_multiplier))
    |> map(&count_combinations/1)
    |> sum()
  end
end
