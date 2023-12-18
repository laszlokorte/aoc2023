defmodule Mix.Tasks.AocInit do
  @moduledoc "Printed when the user requests `mix help echo`"
  @shortdoc "Initializes new AOC day"

  use Mix.Task

  @impl Mix.Task
  def run([day])  do
    for f <- [
          "inputs/day-#{day}-test-1.txt",
          "inputs/day-#{day}-test-2.txt",
          "inputs/day-#{day}-prod.txt"
        ] do
      unless File.exists?(f), do: File.write(f, "", [:write, :append, :utf8])
    end

    unless File.exists?("lib/day#{day}.ex"),
      do:
        File.write(
          "lib/day#{day}.ex",
          """
          defmodule Day#{day} do
            use AOC, day: #{day}
          
            def part(1, input) do
              input
            end
          
            def part(2, input) do
              input
            end
          end
          """,
          [:write, :append, :utf8]
        )
  end
end