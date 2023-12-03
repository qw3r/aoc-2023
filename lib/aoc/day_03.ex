defmodule AoC.Day03 do
  def part1(input) do
    %{nums: nums, symbols: symbols} = parse_input(input)
    symbols_set = symbols |> Enum.map(fn {y, x, _} -> {y, x} end) |> MapSet.new()

    nums
    |> Enum.filter(fn {rows, cols, _number} ->
      for(
        y <- rows,
        x <- cols,
        do: MapSet.member?(symbols_set, {y, x})
      )
      |> Enum.any?()
    end)
    |> Enum.map(fn {_rows, _cols, number} -> number end)
    |> Enum.sum()
  end

  def part2(input) do
    %{nums: nums, symbols: symbols} = parse_input(input)

    symbols
    |> Enum.filter(fn
      {_y, _x, "*"} -> true
      _ -> false
    end)
    |> Enum.map(fn {y, x, _} ->
      nums |> Enum.filter(fn {rows, cols, _number} -> y in rows && x in cols end)
    end)
    |> Enum.map(fn
      [a, b] -> elem(a, 2) * elem(b, 2)
      _ -> 0
    end)
    |> Enum.sum()
  end

  defp parse_input(input) do
    lines =
      input
      |> String.split("\n", trim: true)
      |> Enum.with_index()

    nums =
      lines
      |> Enum.flat_map(fn {line, i} ->
        Regex.scan(~r/\d+/, line, return: :index)
        |> List.flatten()
        |> Enum.map(fn {j, len} ->
          {(i - 1)..(i + 1), (j - 1)..(j + len), String.to_integer(String.slice(line, j, len))}
        end)
      end)

    symbols =
      lines
      |> Enum.flat_map(fn {line, i} ->
        Regex.scan(~r/[^a-zA-Z0-9\.]/, line, return: :index)
        |> List.flatten()
        |> Enum.map(fn {j, _} -> {i, j, String.slice(line, j, 1)} end)
      end)

    %{nums: nums, symbols: symbols}
  end
end
