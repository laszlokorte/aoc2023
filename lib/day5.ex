defmodule Day5 do
  use AOC, day: 5

  @min_range -1
  @blank_line_pattern ~r{\R\R}
  @digit_pattern ~r{\d+}
  @digit_pair_pattern ~r{(\d+) (\d+)}
  @mapping_pattern ~r{(\d+) (\d+) (\d+)}

  def parse_parts(input) do
    String.split(input, @blank_line_pattern, trim: true, parts: 2)
  end

  def to_integer_triple([dst, src, len]) do
    {
      String.to_integer(src),
      String.to_integer(dst),
      String.to_integer(len)
    }
  end

  def to_mapping_entry({dst, src, len}) do
    {src, Range.new(dst, dst + len - 1)}
  end

  def parse_mappings_block(block) do
    Regex.scan(@mapping_pattern, block, capture: :all_but_first)
    |> Enum.map(&to_integer_triple/1)
    |> Enum.map(&to_mapping_entry/1)
  end

  def parse_mappings(mapping_lines) do
    String.split(mapping_lines, @blank_line_pattern, trim: true)
    |> Enum.map(&parse_mappings_block/1)
  end

  def parse_seeds_singlton(seed_line) do
    Regex.scan(@digit_pattern, seed_line)
    |> Enum.map(fn [num] -> String.to_integer(num) end)
    |> Enum.map(fn num -> Range.new(num, num) end)
  end

  def parse_seed_range(seed_line) do
    Regex.scan(@digit_pair_pattern, seed_line, capture: :all_but_first)
    |> Enum.map(fn
      [start, len] ->
        Range.new(
          String.to_integer(start),
          String.to_integer(start) - 1 + String.to_integer(len)
        )
    end)
  end

  def fill_range_gap([{src, as..ae}, {_, bs.._}]) when bs in as..ae, do: [{src, as..ae}]

  def fill_range_gap([{src, as..ae}, {_, bs.._}]),
    do: [{src, as..ae//1}, {ae + 1, (ae + 1)..(bs - 1)//1}]

  def fill_range_gap([_]), do: []

  def pack_dense_ranges(ranges, upper_limit) do
    ranges
    |> Enum.sort_by(fn {_, dst_start.._} -> dst_start end)
    |> (&Enum.concat([{@min_range, @min_range..@min_range}], &1)).()
    |> (&Enum.concat([&1, [{upper_limit, upper_limit..upper_limit}]])).()
    |> Enum.chunk_every(2, 1)
    |> Enum.flat_map(&fill_range_gap/1)
  end

  def pack_mappings(mappings, max) do
    mappings |> Enum.map(&pack_dense_ranges(&1, max))
  end

  def clamp_range(from..to, bound_min..bound_max) do
    max(from, bound_min)..min(to, bound_max)
  end

  def map_input_to_output(input, {src_start, dst_start..dst_end}) do
    clamped_start..clamped_end = clamp_range(input, dst_start..dst_end)

    (clamped_start - dst_start + src_start)..(clamped_end - dst_start + src_start)
  end

  def apply_mappings_to_one_input(mappings, input) do
    mappings
    |> Enum.filter(fn {_, dst} -> not Range.disjoint?(input, dst) end)
    |> Enum.map(&map_input_to_output(input, &1))
  end

  def apply_mappings(mappings, inputs) do
    inputs |> Enum.flat_map(&apply_mappings_to_one_input(mappings, &1))
  end

  def find_dependencies(maps, seeds) do
    maps |> Enum.reduce(seeds, &apply_mappings/2)
  end

  def highest_value(seeds, mappings) do
    max(
      List.flatten(mappings) |> Enum.map(fn {s, a..b} -> s + (b - a) end) |> Enum.max(),
      seeds |> Enum.map(&Enum.max/1) |> Enum.max()
    )
  end

  def part(1, input) do
    [seed_line, mapping_lines] = parse_parts(input)

    seeds = parse_seeds_singlton(seed_line)
    mappings = parse_mappings(mapping_lines)

    mappings
    |> pack_mappings(highest_value(seeds, mappings))
    |> find_dependencies(seeds)
    |> Enum.map(&Enum.min/1)
    |> Enum.min()
  end

  def part(2, input) do
    [seed_line, mapping_lines] = parse_parts(input)

    seeds = parse_seed_range(seed_line)
    mappings = parse_mappings(mapping_lines)

    mappings
    |> pack_mappings(highest_value(seeds, mappings))
    |> find_dependencies(seeds)
    |> Enum.map(&Enum.min/1)
    |> Enum.min()
  end
end
