defmodule Day24 do
  use AOC, day: 24

  @line_break_pattern ~r{\R}
  @line_pattern ~r{(?<x>-?\d+),\s+(?<y>-?\d+),\s+(?<z>-?\d+)\s+@\s+(?<vx>-?\d+),\s+(?<vy>-?\d+),\s+(?<vz>-?\d+)}
  @min 200_000_000_000_000
  @max 400_000_000_000_000
  @z3result ~r{\(\(sum (?<result>\d+)\)\)}
  @newline "\n"
  @z3cmd "z3 -in"

  def parse_line(line) do
    [x, y, z, vx, vy, vz] =
      @line_pattern
      |> Regex.run(line, capture: [:x, :y, :z, :vx, :vy, :vz])
      |> Enum.map(&String.to_integer/1)

    {{x, y, z}, {vx, vy, vz}}
  end

  def parse(input) do
    input
    |> String.split(@line_break_pattern, trim: true)
    |> Enum.map(&parse_line/1)
  end

  def into_points_2d({{x, y, _}, {vx, vy, _}}) do
    {{x, y}, {1, x + vx, y + vy}}
  end

  def inside(x, min, max), do: min <= x and x <= max

  def run_solver(all_hails) do
    hails = Enum.take(all_hails, 4)

    try do
      z3 = Port.open({:spawn, @z3cmd}, [:binary])

      z3decls =
        [
          Enum.map(1..4, &"t#{&1}"),
          Enum.map(1..3, &"x#{&1}"),
          Enum.map(1..3, &"xd#{&1}"),
          ["sum"]
        ]
        |> Enum.concat()
        |> Enum.map(&"(declare-const #{&1} Int)")
        |> Enum.concat(
          hails
          |> Enum.with_index(1)
          |> Enum.flat_map(fn {{base, dir}, h} ->
            Enum.zip_with([1..3, Tuple.to_list(base), Tuple.to_list(dir)], fn
              [i, b, d] -> "(assert (= (+ #{b} (* t#{h} #{d})) (+ x#{i} (* t#{h} xd#{i}))))"
            end)
          end)
        )
        |> Enum.concat([
          "(assert (= sum (+ x1 x2 x3)))",
          "(check-sat)",
          "(get-value (sum))"
        ])

      for d <- z3decls do
        send(z3, {self(), {:command, d}})
        send(z3, {self(), {:command, @newline}})
      end

      receive do
        {^z3, _} ->
          receive do
            {^z3, {:data, x}} -> Regex.run(@z3result, x, capture: [:result])
            _ -> :error
          end

        _ ->
          :error
      end
    rescue
      ErlangError ->
        "error: z3 is not installed"
    end
  end

  def part(1, input, env) do
    hails = input |> parse

    {min, max} =
      case env do
        :test -> {7, 27}
        :prod -> {@min, @max}
      end

    for {{{x1, y1, _z1}, {dx1, dy1, _dz1}}, i1} <- Enum.with_index(hails),
        {{{x2, y2, _z2}, {dx2, dy2, _dz2}}, i2} <- Enum.with_index(hails),
        i2 > i1 do
      try do
        [t1, t2] =
          Nx.tensor([[dx1, -dx2], [dy1, -dy2]])
          |> Nx.LinAlg.solve(Nx.tensor([x2 - x1, y2 - y1]))
          |> Nx.to_list()

        {t1, t2, x1 + t1 * dx1, y1 + t1 * dy1}
      rescue
        ArgumentError -> nil
      end
    end
    |> Enum.count(fn
      nil -> false
      {t1, t2, x, y} -> t1 >= 0 and t2 >= 0 and inside(x, min, max) and inside(y, min, max)
    end)
  end

  def part(2, input, _env) do
    input |> parse |> run_solver
  end
end
