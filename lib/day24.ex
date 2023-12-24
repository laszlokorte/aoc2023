defmodule Day24 do
  use AOC, day: 24

  @line_break_pattern ~r{\R}
  @line_pattern ~r{(?<x>-?\d+),\s+(?<y>-?\d+),\s+(?<z>-?\d+)\s+@\s+(?<vx>-?\d+),\s+(?<vy>-?\d+),\s+(?<vz>-?\d+)}

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
    {{x,y}, {x+vx, y+vy}}
  end

  def inside(x, min, max), do: min <= x and x <= max

  def part(1, input) do
    lines = input |> parse |> Enum.map(&into_points_2d/1)

    for {{x1,y1}, {x2,y2}} <- lines, {{x3,y3}, {x4,y4}} <- lines do
      denom = (x1 - x2)*(y3-y4) - (y1 - y2)*(x3 - x4)
      
      if denom == 0 do
        nil
      else
        a = (x1*y2 - y1*x2)
        b = (x3*y4 - y3*x4)

        ix = (a*(x3 - x4) - (x1 - x2)*b)/denom
        iy = (a*(y3 - y4) - (y1 - y2)*b)/denom

        {ix, iy}
      end
    end |> Enum.filter(fn 
      nil -> false
      {x,y} -> inside(x, 7, 27) and inside(y, 7, 27)
    end)
  end

  def part(2, input) do
    input
  end
end