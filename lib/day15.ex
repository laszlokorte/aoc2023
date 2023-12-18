defmodule Day15 do
  use AOC, day: 15

  @box_count 256
  @hash_mod 17
  @op_pattern ~r{(?<lense>\w+)(?:=(?<focal>\d)|(?<sub>-))}
  @boxes 0..(@box_count - 1) |> Enum.into(Map.new(), fn i -> {i, []} end)
  @sub "-"

  def hash(<<>>, acc) do
    acc
  end

  def hash(<<first::utf8, rest::binary>>, acc) do
    hash(rest, rem((acc + first) * @hash_mod, @box_count))
  end

  def hash(string) do
    string |> hash(0)
  end

  def parse_operation(op) do
    match = Regex.run(@op_pattern, op, capture: [:lense, :focal, :sub])

    case match do
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
    |> Enum.with_index(1)
    |> Enum.map(fn {{_, focal}, i} -> (box + 1) * i * focal end)
    |> Enum.sum()
  end

  def part(1, input) do
    input
    |> String.split(",")
    |> Enum.map(&hash/1)
    |> Enum.sum()
  end

  def part(2, input) do
    input
    |> String.split(",")
    |> Enum.map(&parse_operation/1)
    |> Enum.reduce(@boxes, &apply_operation/2)
    |> Enum.map(&focusing_power/1)
    |> Enum.sum()
  end
end
