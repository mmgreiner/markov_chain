# MarkovChain

Provides some basic [Markov Chain](https://en.wikipedia.org/wiki/Markov_chain) functions for [ruby](https://www.ruby-lang.org/en/).

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add markov_chain --github mmgreiner/markov_chain

```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install markov_chain --github mmgreiner/markov_chain
```

## Usage

Input is a list of strings like:

```ruby
require 'markov_chain'

sentences = [
  "die Kappelbrücke",
  "die Museggmauer",
  "die Kappelbrücke"
]
mk = MarkovChain.new(sentences)

puts "Sentences:"
puts mk.sentences
puts "\nStates:"
puts mk.states
puts "\nWord probabilities"
puts mk.word_probabilities
puts "\nTransition probabilities"
puts mk.transition_probabilities
puts "\nCombined probabilities"
puts mk.combined_probabilities
puts "\nDistribution after 2 steps"
puts mk.distribution_after(steps: 2)
puts "\nMermaid flow diagram"
puts mk.to_mermaid_flow
puts "\nMermaid flow with distributions"
puts mk.to_mermaid_flow_with_node_probabilities(steps:)
```

There is also a small command line program under `lib/main.rb`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mmgreiner/markov_chain.
