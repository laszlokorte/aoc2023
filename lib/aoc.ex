defmodule AOC do
  
  defmacro __using__(opts) do
    quote do
      @test1data File.read(unquote('inputs/test-#{Keyword.get(opts, :day)}-1.txt')) |> elem(1)
      @prod1data File.read(unquote('inputs/prod-#{Keyword.get(opts, :day)}-1.txt')) |> elem(1)
      @test2data File.read(unquote('inputs/test-#{Keyword.get(opts, :day)}-2.txt')) |> elem(1)
      @prod2data File.read(unquote('inputs/prod-#{Keyword.get(opts, :day)}-2.txt')) |> elem(1)

      def part1_test do
        IO.puts(part1(@test1data))
      end

      def part1_prod do
        IO.puts(part1(@prod1data))
      end
      
      def part2_test do
        IO.puts(part2(@test2data))
      end

      def part2_prod do
        IO.puts(part2(@prod2data))
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
