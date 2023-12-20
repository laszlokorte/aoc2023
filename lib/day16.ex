defmodule Day16 do
  use AOC, day: 16

  import Enum

  @line_break_pattern ~r{\R}
  @initial_ray {{-1, 0}, :right}

  def is_empty("."), do: true
  def is_empty(_), do: false

  def parse_element("-"), do: :splith
  def parse_element("|"), do: :splitv
  def parse_element("/"), do: :mirrorf
  def parse_element("\\"), do: :mirrorb

  def interact(:splith, :right), do: [:right]
  def interact(:splith, :left), do: [:left]
  def interact(:splith, _), do: [:left, :right]

  def interact(:splitv, :up), do: [:up]
  def interact(:splitv, :down), do: [:down]
  def interact(:splitv, _), do: [:up, :down]

  def interact(:mirrorf, :up), do: [:right]
  def interact(:mirrorf, :down), do: [:left]
  def interact(:mirrorf, :left), do: [:down]
  def interact(:mirrorf, :right), do: [:up]

  def interact(:mirrorb, :up), do: [:left]
  def interact(:mirrorb, :down), do: [:right]
  def interact(:mirrorb, :right), do: [:down]
  def interact(:mirrorb, :left), do: [:up]

  def step({x, y}, :left), do: {x - 1, y}
  def step({x, y}, :right), do: {x + 1, y}
  def step({x, y}, :up), do: {x, y - 1}
  def step({x, y}, :down), do: {x, y + 1}

  def parse(input) do
    map =
      input
      |> String.split(@line_break_pattern, trim: true)
      |> with_index()
      |> flat_map(fn
        {line, y} ->
          line
          |> String.codepoints()
          |> with_index()
          |> filter(fn
            {char, _} -> not is_empty(char)
          end)
          |> map(fn
            {char, x} -> {{x, y}, parse_element(char)}
          end)
      end)
      |> into(Map.new())

    {width, _} = map |> Map.keys() |> max_by(&elem(&1, 0))
    {_, height} = map |> Map.keys() |> max_by(&elem(&1, 1))

    {
      map,
      width,
      height
    }
  end

  def ray_step({pos, dir}, elements) do
    case Map.get(elements, pos) do
      nil -> [{step(pos, dir), dir}]
      element -> interact(element, dir) |> map(&{step(pos, &1), &1})
    end
  end

  def time_step({active_rays, visited}, {elements, w, h}) do
    new_rayfront =
      active_rays
      |> flat_map(&ray_step(&1, elements))
      |> filter(fn
        {{x, y}, _} -> x in 0..w and y in 0..h
      end)
      |> filter(fn r -> not MapSet.member?(visited, r) end)
      |> into(MapSet.new())

    {new_rayfront, MapSet.union(new_rayfront, visited)}
  end

  def init_ray(initial) do
    {MapSet.new([initial]), MapSet.new()}
  end

  def stable_energy(initial, landscape) do
    initial
    |> init_ray
    |> Stream.iterate(&time_step(&1, landscape))
    |> find(fn
      {active, _} -> MapSet.size(active) == 0
    end)
    |> elem(1)
    |> map(fn {pos, _} -> pos end)
    |> into(MapSet.new())
    |> count()
  end

  def initial_positions(w, h) do
    []
    |> concat(map(0..w, &{{&1, -1}, :down}))
    |> concat(map(0..w, &{{&1, h + 1}, :up}))
    |> concat(map(0..w, &{{-1, &1}, :right}))
    |> concat(map(0..w, &{{w + 1, &1}, :left}))
  end

  def part(1, input) do
    landscape = parse(input)

    stable_energy(@initial_ray, landscape)
  end

  def part(2, input) do
    landscape = {_, w, h} = parse(input)

    initial_positions(w, h)
    |> map(&stable_energy(&1, landscape))
    |> max()
  end
end
