# frozen_string_literal: true

require_relative 'markov_chain'

require 'optparse'

sentences = [
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

mc = MarkovChain::MarkovChain.new(sentences)

OptionParser.new do |opts|
  opts.banner = 'Usage: markov_chain.rb [options]'

  opts.on('-a', '--all STEPS', Float, 'compute all matrices') do |steps|
    puts 'Sentences:'
    puts mc.sentences
    puts "\nStates:"
    puts mc.states
    puts "\nWord probabilities"
    puts mc.word_probabilities
    puts "\nTransition probabilities"
    puts mc.transition_probabilities
    puts "\nCombined probabilities"
    puts mc.combined_probabilities
    puts "\nDistribution after 2 steps"
    puts mc.distribution_after(steps:)
    puts mc.to_mermaid_flow(steps:)
  end

  opts.on('-s', '--states', 'print all states') do
    puts mc.states
  end

  opts.on('-t', '--transition-probabilities', 'print transition probabilities') do
    puts mc.transition_probabilities
  end

  opts.on('-w', '--word-probabilities', 'print word probabilities') do
    puts mc.word_probabilities
  end

  opts.on('-c', '--combined-probabilities') do
    puts mc.combined_probabilities
  end

  opts.on('-d', '--distribution-after STEPS', Integer, 'Distributions after STEPS') do |steps|
    puts mc.distribution_after(steps:)
  end

  opts.on('-m', '--mermaid-diagram') do
    puts mc.to_mermaid_flow
  end

  opts.on('-n', '--mermaid-after STEPS', Integer, 'mermaid diagram after STEPS') do |steps|
    puts mc.to_mermaid_flow_with_node_probabilities(steps:)
  end

  opts.on('-i', '--input FILENAME', String, 'input file with lines of words') do |filename|
    sentences = File.readlines(filename).map(&:chomp)
    mc = MarkovChain::MarkovChain.new(sentences)
    warn "successfully read #{filename} with #{mc.sentences} sentences."
  end
end.parse!
