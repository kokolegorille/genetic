defmodule OneMax do
  @size 1_000

  @behaviour Problem
  alias Types.Chromosome

  @impl true
  def genotype() do
    genes = for _ <- 1..@size, do: Enum.random(0..1)
    %Chromosome{genes: genes, size: @size}
  end

  @impl true
  def fitness_function(chromosome) do
    Enum.sum(chromosome.genes)
  end

  @impl true
  def terminate?([best | _]) do
    best.fitness == @size
  end
end

soln = Genetic.run(OneMax)

IO.write("\n")
IO.inspect soln
