defmodule Day14 do
  use AOC, day: 14

  @part2_seq [:up, :left, :down, :right]
  @part2_cycle_count 1_000_000_000

  defmodule StoneMap do
    @linke_break_pattern ~r{\R}

    @round_piece "O"
    @cube_piece "#"
    @empty_piece "."

    defstruct [:width, :height, :pieces]

    def tilt_order(%StoneMap{width: width, height: height}, dir) when dir in [:down, :right] do
      for x <- width..0, y <- height..0, do: {x, y}
    end

    def tilt_order(%StoneMap{width: width, height: height}, dir) when dir in [:up, :left] do
      for x <- 0..width, y <- 0..height, do: {x, y}
    end

    def can_move(:round), do: true
    def can_move(_), do: false

    def new_positition({x, y}, :up), do: {x, y - 1}
    def new_positition({x, y}, :down), do: {x, y + 1}
    def new_positition({x, y}, :left), do: {x - 1, y}
    def new_positition({x, y}, :right), do: {x + 1, y}

    def valid_position?({x, y}, %StoneMap{width: w, height: h}) do
      x in 0..(w - 1) and y in 0..(h - 1)
    end

    def move_element(current_position, old_map, direction) do
      %StoneMap{pieces: pieces} = old_map
      new_pos = new_positition(current_position, direction)

      cond do
        Map.has_key?(pieces, new_pos) ->
          old_map

        valid_position?(new_pos, old_map) ->
          case Map.pop(pieces, current_position) do
            {element, updated_pieces} ->
              if can_move(element) do
                move_element(
                  new_pos,
                  Map.put(old_map, :pieces, Map.put(updated_pieces, new_pos, element)),
                  direction
                )
              else
                old_map
              end

            _ ->
              old_map
          end

        true ->
          old_map
      end
    end

    def tilt(stone_map, direction) do
      tilt_order(stone_map, direction)
      |> Enum.reduce(stone_map, &move_element(&1, &2, direction))
    end

    def parse(input) do
      lines = input |> String.split(@linke_break_pattern, trim: true)
      height = Enum.count(lines)
      width = String.length(Enum.at(lines, 0))

      lines
      |> Enum.with_index()
      |> Enum.flat_map(fn {line, y} ->
        line
        |> String.codepoints()
        |> Enum.with_index()
        |> Enum.map(fn
          {@round_piece, x} -> {:round, x, y}
          {@cube_piece, x} -> {:cube, x, y}
          {@empty_piece, x} -> {:empty, x, y}
        end)
      end)
      |> Enum.filter(fn
        {:round, _, _} -> true
        {:cube, _, _} -> true
        {:empty, _, _} -> false
      end)
      |> Enum.into(Map.new(), fn {kind, x, y} -> {{x, y}, kind} end)
      |> StoneMap.new(width, height)
    end

    def new(p, w, h) do
      %StoneMap{width: w, height: h, pieces: p}
    end

    def find_cycle(map, dir_seq) do
      Stream.cycle(dir_seq)
      |> Stream.with_index()
      |> Stream.scan({map, Map.new(), nil}, fn
        {dir, count}, {map, seen, _} ->
          {tilt(map, dir), Map.put(seen, {map, dir}, count), Map.get(seen, {map, dir})}
      end)
      |> Stream.drop_while(fn {_, _, cycle} -> nil == cycle end)
      |> Stream.map(fn {last_map, seen, cycle_start} ->
        {last_map, Enum.count(seen) - cycle_start, cycle_start}
      end)
      |> Enum.at(0)
    end

    def print_map({w, h, map}) do
      for y <- 0..h do
        for x <- 0..w do
          case Map.get(map, {x, y}) do
            :cube -> IO.write(@cube_piece)
            :round -> IO.write(@round_piece)
            _ -> IO.write(@empty_piece)
          end
        end

        IO.puts("")
      end
    end

    def weight(%StoneMap{height: height, pieces: pieces}) do
      pieces
      |> Enum.map(fn
        {{_, y}, :round} -> height - y
        _ -> 0
      end)
      |> Enum.sum()
    end
  end

  def part1(input) do
    StoneMap.parse(input)
    |> StoneMap.tilt(:up)
    |> StoneMap.weight()
  end

  def part2(input) do
    map = StoneMap.parse(input)

    total_tilts = @part2_cycle_count * Enum.count(@part2_seq)
    {cycle, cycle_length, cycle_start} = StoneMap.find_cycle(map, @part2_seq)
    cycle_rest = rem(total_tilts - cycle_start, cycle_length)

    Stream.cycle(@part2_seq)
    |> Stream.drop(cycle_start)
    |> Stream.take(cycle_rest)
    |> Enum.reduce(cycle, &StoneMap.tilt(&2, &1))
    |> StoneMap.weight()
  end
end
