defmodule Mix.Tasks.AocInit do
  @moduledoc "Printed when the user requests `mix help echo`"
  @shortdoc "Initializes new AOC day"

  use Mix.Task

  @impl Mix.Task
  def run([day]) do
    for f <- [
          "inputs/day-#{day}-test-1.txt",
          "inputs/day-#{day}-test-2.txt",
          "inputs/day-#{day}-prod.txt"
        ],
        not File.exists?(f) do
      File.write(f, "", [:write, :append, :utf8])
    end

    unless File.exists?("lib/day#{day}.ex") do
      day_num = String.to_integer(day)
      module_name = {:__aliases__, [alias: false], [:"Day#{day_num}"]}

      File.write(
        "lib/day#{day}.ex",
        quote do
          defmodule unquote(module_name) do
            use AOC, day: unquote(day_num)

            def part(1, input, _env) do
              input
            end

            def part(2, input, _env) do
              input
            end
          end
        end
        |> Macro.to_string(),
        [:write, :append, :utf8]
      )
    end
  end
end
