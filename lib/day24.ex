defmodule Day24 do
  use AOC, day: 24

  @line_break_pattern ~r{\R}
  @line_pattern ~r{(?<x>-?\d+),\s+(?<y>-?\d+),\s+(?<z>-?\d+)\s+@\s+(?<vx>-?\d+),\s+(?<vy>-?\d+),\s+(?<vz>-?\d+)}
  @min 200000000000000
  @max 400000000000000

  def parse_line(line) do
    [x,y,z,vx,vy,vz] = @line_pattern 
    |> Regex.run(line, capture: [:x,:y,:z,:vx,:vy,:vz])
    |> Enum.map(&String.to_integer/1)

    {{x,y,z}, {vx,vy,vz}}
  end

  def parse(input) do
    input 
    |> String.split(@line_break_pattern, trim: true) 
    |> Enum.map(&parse_line/1)
  end

  def into_points_2d({{x,y,_}, {vx,vy,_}}) do
    {{x, y}, {1, x+vx, y+vy}}
  end

  def inside(x, min, max), do: min <= x and x <= max

  def part(1, input) do
    hails = input |> parse

    {min, max} = if Enum.count(hails) < 10 do
      {7, 27}
    else
      {@min, @max}
    end

    for {{{x1, y1, _z1}, {dx1, dy1, _dz1}}, i1} <- Enum.with_index(hails), {{{x2, y2, _z2}, {dx2, dy2, _dz2}}, i2} <- Enum.with_index(hails), i2 > i1 do
      try do
        [t1, t2] = Nx.tensor([[dx1, -dx2], [dy1, -dy2]]) 
        |> Nx.LinAlg.solve(Nx.tensor([x2 - x1, y2 - y1])) |> Nx.to_list()

        {t1, t2, x1 + t1 * dx1, y1 + t1 * dy1}
      rescue
        ArgumentError -> nil
      end
    end |> Enum.count(fn 
      nil -> false
      {t1, t2, x,y} -> t1 >= 0 and t2 >= 0 and inside(x, min, max) and inside(y, min, max)
    end)
  end

  def part(2, input) do
    input
  end
end