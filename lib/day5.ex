defmodule Day5 do
  use AOC, day: 5

  @min_range -1
  @max_range 100_000
  @blank_line_pattern ~r{\R\R}
  @digit_pattern ~r{\d+}
  @digit_pair_pattern ~r{(\d+) (\d+)}
  @mapping_pattern ~r{(\d+) (\d+) (\d+)}

  def pack_dense_ranges(ranges) do
    ranges
    |> Enum.sort_by(fn {_, dst_start.._} -> dst_start end)
    |> (&Enum.concat([{@min_range..@min_range, @min_range..@min_range}], &1)).()
    |> (&Enum.concat([&1, [{@max_range..@max_range, @max_range..@max_range}]])).()
    |> Enum.chunk_every(2, 1)
    |> Enum.flat_map(fn
      [{src, as..ae}, {_, bs.._}] ->
        cond do
          bs in as..ae -> [{src, as..ae}]
          true -> [{src, as..ae//1}, {ae + 1, (ae + 1)..(bs - 1)//1}]
        end

      [r] ->
        [r]
    end)
  end

  def extract_mappings(mapping_lines) do
    String.split(mapping_lines, @blank_line_pattern, trim: true)
    |> Enum.map(fn
      block ->
        Regex.scan(@mapping_pattern, block, capture: :all_but_first)
        |> Enum.map(fn [dst, src, len] ->
          {
            String.to_integer(src),
            String.to_integer(dst),
            String.to_integer(len)
          }
        end)
        |> Enum.map(fn {dst, src, len} ->
          {
            src,
            Range.new(dst, dst + len - 1)
          }
        end)
        |> pack_dense_ranges
    end)
  end

  def extract_seeds_singlton(seed_line) do
    Regex.scan(@digit_pattern, seed_line)
    |> Enum.map(fn [num] -> String.to_integer(num) end)
    |> Enum.map(fn num -> Range.new(num, num) end)
  end

  def extract_seed_range(seed_line) do
    Regex.scan(@digit_pair_pattern, seed_line, capture: :all_but_first)
    |> Enum.map(fn
      [start, len] ->
        Range.new(
          String.to_integer(start),
          String.to_integer(start) - 1 + String.to_integer(len)
        )
    end)
  end

  def clamp_range(a..b, min..max) do
    max(a, min)..min(b, max)
  end

  def find_dependencies(seeds, maps) do
    Enum.reduce(maps, seeds, fn
      mapping, inputs ->
        Enum.flat_map(inputs, fn
          i ->
            Enum.filter(mapping, fn {_, dst} -> not Range.disjoint?(i, dst) end)
            |> Enum.map(fn {src_start, dst_start..dst_end} ->
              case clamp_range(i, dst_start..dst_end) do
                start..nd -> (start - dst_start + src_start)..(nd - dst_start + src_start)
              end
            end)
        end)
    end)
  end

  def part1(input) do
    [seed_line, mapping_lines] = String.split(input, @blank_line_pattern, trim: true, parts: 2)

    seeds = extract_seeds_singlton(seed_line)
    maps = extract_mappings(mapping_lines)

    find_dependencies(seeds, maps)
    |> Enum.map(&Enum.min/1)
    |> Enum.min()
  end

  def part2(input) do
    [seed_line, mapping_lines] = String.split(input, @blank_line_pattern, trim: true, parts: 2)

    seeds = extract_seed_range(seed_line)
    maps = extract_mappings(mapping_lines)

    find_dependencies(seeds, maps)
    |> Enum.map(&Enum.min/1)
    |> Enum.min()
  end
end
