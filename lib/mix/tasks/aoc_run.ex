defmodule Mix.Tasks.AocRun do
  @moduledoc "Printed when the user requests `mix help echo`"
  @shortdoc "Echoes arguments"

  use Mix.Task

  @impl Mix.Task
  def run(args) do
    {:ok, _} = Application.ensure_all_started(:memoize)

    case args do
      [] ->
        run_all([1, 2], [:test, :prod])

      ["prod"] ->
        run_all([1, 2], [:prod])

      ["test"] ->
        run_all([1, 2], [:test])

      [day] ->
        run_day(String.to_integer(day), [1, 2], [:test, :prod])

      [day, part] ->
        run_day(String.to_integer(day), [String.to_integer(part)], [:test, :prod])

      [day, part, env] ->
        run_day(String.to_integer(day), [String.to_integer(part)], [parse_env(env)])
    end
    |> Enum.each(fn {day_number, part, env, output} ->
      IO.puts("Day #{day_number}, Part #{part}, #{env}: #{output}")
    end)
  end

  def parse_env("test"), do: :test
  def parse_env("prod"), do: :prod

  def run_day(day_number, parts, envs) do
    {:consolidated, days} = AOC.Day.__protocol__(:impls)

    day =
      days
      |> Enum.find(fn d -> AOC.Day.number(struct(d, [])) == day_number end)

    for part <- parts, env <- envs do
      input = AOC.Day.input(struct(day, []), part, env)

      {day, part, env, input}
    end
    |> Task.async_stream(
      fn
        {day, part, env, input} ->
          {part, env, apply(day, :part, [part, input])}
      end,
      ordered: true,
      timeout: :infinity
    )
    |> Enum.map(fn {:ok, {part, env, output}} ->
      {day_number, part, env, output}
    end)
  end

  def run_all(parts, envs) do
    {:consolidated, days} = AOC.Day.__protocol__(:impls)

    sorted = days |> Enum.sort_by(fn d -> AOC.Day.number(struct(d, [])) end)

    sorted
    |> Task.async_stream(
      fn
        day -> run_day(AOC.Day.number(struct(day, [])), parts, envs)
      end,
      ordered: true,
      timeout: :infinity
    )
    |> Enum.flat_map(fn {:ok, r} -> r end)
  end
end
