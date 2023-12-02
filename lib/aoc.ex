defmodule AOC do
  def all do
    IO.puts("\nDay1")
    Day1.all()
    IO.puts("\nDay 2")
    Day2.all()
  end

  defmacro __using__(opts) do
    quote do
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

      def all do
        IO.puts("Part 1 Test:")
        part1_test()
        IO.puts("Part 1 Prod:")
        part1_prod()
        IO.puts("Part 2 Test:")
        part2_test()
        IO.puts("Part 2 Prod:")
        part2_prod()
      end
    end
  end
end
