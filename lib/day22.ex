defmodule Day22 do
  use AOC, day: 22

  @line_break_pattern ~r{\R}

  defmodule Brick do
    defstruct [:x, :y, :z, :id]

    @brick_pattern ~r{(\d+),(\d+),(\d+)~(\d+),(\d+),(\d+)}s

    def parse({line, line_number}) do
      [x1, y1, z1, x2, y2, z2] =
        Regex.run(@brick_pattern, line, capture: :all_but_first) |> Enum.map(&String.to_integer/1)

      %Brick{
        x: min(x1, x2)..max(x1, x2),
        y: min(y1, y2)..max(y1, y2),
        z: min(z1, z2)..max(z1, z2),
        id: line_number
      }
    end

    def supported_by(brick, support = %Brick{z: min_z..max_z}) do
      Brick.overlaps?(brick, %Brick{support | z: (min_z + 1)..(max_z + 1)}) and brick != support
    end

    def overlaps?(%Brick{x: x, y: y, z: z}, %Brick{x: xx, y: yy, z: zz}) do
      not (Range.disjoint?(x, xx) or Range.disjoint?(y, yy) or Range.disjoint?(z, zz))
    end

    def overlaps?(%Brick{x: x, y: y, z: z}, {xx, yy, zz}) do
      (is_nil(xx) or xx in x) and (is_nil(yy) or yy in y) and (is_nil(zz) or zz in z)
    end

    def move_down(%Brick{z: 1.._} = brick, _), do: brick

    def move_down(brick = %Brick{z: z1..z2}, settled) do
      down = %Brick{brick | z: (z1 - 1)..(z2 - 1)}

      if Enum.any?(settled, &Brick.overlaps?(&1, down)) do
        brick
      else
        Brick.move_down(down, settled)
      end
    end
  end

  def settle(bricks) do
    bricks
    |> Enum.sort_by(fn %Brick{z: a.._} -> a end, :asc)
    |> Enum.reduce(MapSet.new(), &MapSet.put(&2, Brick.move_down(&1, &2)))
  end

  def parse(input) do
    input
    |> String.split(@line_break_pattern)
    |> Enum.with_index()
    |> Enum.map(&Brick.parse/1)
  end

  def only_supported_by(bricks, passive, active) do
    not Brick.supported_by(passive, active) or
      Enum.count(bricks, &Brick.supported_by(passive, &1)) > 1
  end

  def is_free(bricks, brick) do
    bricks |> Enum.all?(&only_supported_by(bricks, &1, brick))
  end

  def count_free(bricks) do
    bricks |> Enum.count(&is_free(bricks, &1))
  end

  def part(1, input, _env) do
    input
    |> parse
    |> settle
    |> count_free
  end

  def part(2, input, _env) do
    settled = input |> parse |> settle

    settled
    |> Enum.filter(&(not is_free(settled, &1)))
    |> Enum.map(&MapSet.delete(settled, &1))
    |> Enum.map(&(settle(&1) |> MapSet.difference(&1) |> Enum.count()))
    |> Enum.sum()
  end
end
