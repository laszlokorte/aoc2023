defmodule Day15 do
  use AOC, day: 15

  import Enum

  @box_count 256
  @hash_mod 17
  @op_pattern ~r{(?<lense>\w+)(?:=(?<focal>\d)|(?<sub>-))}
  @boxes 0..(@box_count - 1) |> into(Map.new(), fn i -> {i, []} end)
  @sub "-"
  @comma ","

  def hash(<<>>, acc), do: acc

  def hash(<<first::utf8, rest::binary>>, acc) do
    hash(rest, rem((acc + first) * @hash_mod, @box_count))
  end

  def hash(string), do: hash(string, 0)

  def parse_operation(op) do
    Regex.run(@op_pattern, op, capture: [:lense, :focal, :sub])
    |> case do
      [lense, focal, ""] -> {hash(lense), String.to_atom(lense), String.to_integer(focal)}
      [lense, "", @sub] -> {hash(lense), String.to_atom(lense), :sub}
    end
  end

  def apply_operation({box, label, :sub}, boxes) do
    Map.update(boxes, box, [], fn lenses -> Keyword.delete_first(lenses, label) end)
  end

  def apply_operation({box, label, focal}, boxes) do
    Map.update(boxes, box, [], &Keyword.update(&1, label, focal, fn _ -> focal end))
  end

  def focusing_power({box, lenses}) do
    lenses
    |> with_index(1)
    |> map(fn {{_, focal}, i} -> (box + 1) * i * focal end)
    |> sum()
  end

  def part(1, input) do
    input
    |> String.split(@comma, trim: true)
    |> map(&hash/1)
    |> sum()
  end

  def part(2, input) do
    input
    |> String.split(@comma, trim: true)
    |> map(&parse_operation/1)
    |> reduce(@boxes, &apply_operation/2)
    |> map(&focusing_power/1)
    |> sum()
  end
end
