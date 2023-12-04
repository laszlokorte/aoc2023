defmodule AOC do
  defprotocol Day do
    @spec number(t) :: String.t()
    def number(_)
  end

  def all do
    {:consolidated, days} = Day.__protocol__(:impls)

    days
    |> Enum.each(fn d ->
      IO.puts("## Day #{Day.number(struct(d, []))} ##")
      IO.puts("Part 1 Test:")
      apply(d, :part1_test, [])
      IO.puts("Part 1 Prod:")
      apply(d, :part1_prod, [])
      IO.puts("Part 2 Test:")
      apply(d, :part2_test, [])
      IO.puts("Part 2 Prod:")
      apply(d, :part2_prod, [])
      IO.puts("")
    end)
  end

  def setup_day(day) do
    for f <- [
          "inputs/day-#{day}-test-1.txt",
          "inputs/day-#{day}-test-1.txt",
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
          
            def part1(input) do
              input
            end
          
            def part2(input) do
              input
            end
          end
          """,
          [:write, :append, :utf8]
        )
  end

  defmacro __using__(opts) do
    quote do
      defstruct []

      @externalResource unquote(~c"inputs/day-#{Keyword.get(opts, :day)}-test-1.txt")
      @externalResource unquote(~c"inputs/day-#{Keyword.get(opts, :day)}-test-2.txt")
      @externalResource unquote(~c"inputs/day-#{Keyword.get(opts, :day)}-prod.txt")

      @test1data File.read(unquote(~c"inputs/day-#{Keyword.get(opts, :day)}-test-1.txt"))
                 |> elem(1)
      @test2data File.read(unquote(~c"inputs/day-#{Keyword.get(opts, :day)}-test-2.txt"))
                 |> elem(1)
      @proddata File.read(unquote(~c"inputs/day-#{Keyword.get(opts, :day)}-prod.txt")) |> elem(1)

      def part1_test do
        IO.puts(part1(@test1data))
      end

      def part1_prod do
        IO.puts(part1(@proddata))
      end

      def part2_test do
        IO.puts(part2(@test2data))
      end

      def part2_prod do
        IO.puts(part2(@proddata))
      end

      defimpl AOC.Day do
        def number(_) do
          unquote(Keyword.get(opts, :day))
        end
      end
    end
  end
end
