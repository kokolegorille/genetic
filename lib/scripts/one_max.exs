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
  def terminate?([best | _], _generation) do
    best.fitness == @size
  end

  # # Maximum
  # @impl true
  # def terminate?(population) do
  #   Enum.max_by(population, &OneMax.fitness_function/1) == @size
  # end

  # # Minimum
  # @impl true
  # def terminate?(population) do
  #   Enum.min_by(population, &OneMax.fitness_function/1) == 0
  # end

  # # Average
  # @impl true
  # def terminate?(population) do
  #   avg = Enum.map(population, &(Enum.sum(&1) / length(&1)))
  #   avg == 21
  # end
end

soln = Genetic.run(OneMax)

IO.write("\n")
IO.inspect soln
