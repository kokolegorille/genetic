defmodule Toolbox.Mutation do
  alias Types.Chromosome

  use Bitwise
  def flip(chromosome) do
    genes =
      chromosome.genes
      |> Enum.map(& &1 ^^^ 1)
    %Chromosome{genes: genes, size: chromosome.size}
  end

  def scramble(chromosome) do
    genes =
      chromosome.genes
      |> Enum.shuffle()
    %Chromosome{genes: genes, size: chromosome.size}
  end
end
