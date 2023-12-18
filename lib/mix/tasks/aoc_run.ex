defmodule Mix.Tasks.AocRun do
  @moduledoc "Printed when the user requests `mix help echo`"
  @shortdoc "Echoes arguments"

  use Mix.Task

  @impl Mix.Task
  def run(args) do
    {:ok, _} = Application.ensure_all_started(:memoize)

    case args do
      [] -> run_all()
      [day] -> run_day(String.to_integer(day), [1,2], [:test, :prod])
      [day, part] -> run_day(String.to_integer(day), [String.to_integer(part)], [:test, :prod])
      [day, part, env] -> run_day(String.to_integer(day), [String.to_integer(part)], [parse_env(env)])
    end
  end

  def parse_env("test"), do: :test
  def parse_env("prod"), do: :prod

  def run_day(day_number, parts, envs) do
    {:consolidated, days} = AOC.Day.__protocol__(:impls)

    day = days 
    |> Enum.find(fn d -> AOC.Day.number(struct(d, [])) == day_number end)
    
    for part <- parts do
      for env <- envs do
        input = AOC.Day.input(struct(day, []), part, env)
        result = apply(day, :part, [part, input])

        IO.puts("Day #{day_number}, Part #{part} #{env}:")
        IO.puts(result)
      end
    end
  end

  def run_all do
    {:consolidated, days} = AOC.Day.__protocol__(:impls)

    sorted = days |> Enum.sort_by(fn d -> AOC.Day.number(struct(d, [])) end)

    for day <- sorted do
      run_day(AOC.Day.number(struct(day, [])), [1,2], [:test, :prod])
    end
  end
end