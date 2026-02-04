require 'test_helper'

class MarkovTest < Minitest::Test

  sentences = [
    "the cat sits",
    "the cat eats",
    "the dog sits"
  ]

  def test_markov_chain_model
    mc = MarkovChain.new(sentences)

    puts "States:"
    p mc.states

    puts "\nWord probabilities:"
    p mc.word_probabilities

    puts "\nTransition probabilities:"
    p mc.transition_probabilities

    puts "\nCombined probabilities:"
    p mc.combined_probabilities
  end
end
