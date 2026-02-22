# frozen_string_literal: true

require 'test_helper'

class MarkovTest < Minitest::Test

  def setup
    @sentences = [
      'die Kappelbrücke',
      'die Museggmauer',
      'das Löwendenkmal',
      'der Vierwaldstättersee',
      'die Altstadt',
      'die Rigi',
      'das Verkehrshaus',
      'die Pilatusbahn',
      'die Gletschergrotte',
      'das Bourbaki-Panorama',
      'die Kappelbrücke',
      'die Kappelbrücke',
      'der Schwanenplatz'
    ]
  end

  def test_markov_chain_model
    mc = MarkovChain.new(@sentences)

    puts 'States:'
    p mc.states
    assert mc.states.any?

    puts "\nWord probabilities:"
    p mc.word_probabilities
    assert mc.word_probabilities.any?

    puts "\nTransition probabilities:"
    p mc.transition_probabilities
    assert mc.transition_probabilities.any?

    puts "\nCombined probabilities:"
    p mc.combined_probabilities
    assert mc.combined_probabilities.any?
  end
end
