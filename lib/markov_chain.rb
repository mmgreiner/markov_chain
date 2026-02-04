# frozen_string_literal: true

require_relative 'markov_chain/version'

module MarkovChain
  class Error < StandardError; end

  require 'matrix'

  def self.new(sentences)
    MarkovChain.new(sentences)
  end

  class MarkovChain
    attr_reader :states,
                :word_frequencies,
                :word_probabilities,
                :transition_counts,
                :transition_probabilities,
                :combined_probabilities,
                :sentences

    START_STATE = '__START__'
    END_STATE   = '__END__'

    def initialize(sentences)
      @sentences = sentences
      @states = [START_STATE, END_STATE]
      build_states
      build_model
    end

    private

    def tokenize(sentence)
      sentence
        .downcase
        .scan(/\p{L}+/)
    end

    # --------------------------------------------------
    # Build unique states (include START + END already)
    # --------------------------------------------------
    def build_states
      @sentences.each do |sentence|
        tokenize(sentence).each do |word|
          @states << word unless @states.include?(word)
        end
      end
    end

    # --------------------------------------------------
    # Build frequency vector + transition matrix
    # --------------------------------------------------
    def build_model
      n = @states.length

      freq_array = Array.new(n, 0)
      transition_array = Array.new(n) { Array.new(n, 0) }

      total_words = 0

      @sentences.each do |sentence|
        words = tokenize(sentence)
        next if words.empty?

        start_index = @states.index(START_STATE)
        end_index   = @states.index(END_STATE)

        first_index = @states.index(words.first)
        transition_array[start_index][first_index] += 1

        words.each_with_index do |word, i|
          current_index = @states.index(word)
          freq_array[current_index] += 1
          total_words += 1

          if i < words.length - 1
            next_index = @states.index(words[i + 1])
            transition_array[current_index][next_index] += 1
          else
            transition_array[current_index][end_index] += 1
          end
        end
      end

      @word_frequencies = Vector.elements(freq_array)
      @transition_counts = Matrix.rows(transition_array)

      # compute_probabilities(total_words)
      compute_probabilities
    end

    def compute_probabilities_old(total_words)
      n = @states.length

      @word_probabilities =
        Vector.elements(
          @word_frequencies.map { |f| total_words.positive? ? f.to_f / total_words : 0.0 }
        )

      prob_rows = []

      n.times do |i|
        row = @transition_counts.row(i).to_a
        row_sum = row.sum

        prob_rows << if row_sum.zero?
                       Array.new(n, 0.0)
                     else
                       row.map { |v| v.to_f / row_sum }
                     end
      end

      @transition_probabilities = Matrix.rows(prob_rows)

      combined_rows = []

      n.times do |i|
        row = @transition_probabilities.row(i).to_a
        combined_rows << row.map { |p| p * @word_probabilities[i] }
      end

      @combined_probabilities = Matrix.rows(combined_rows)
    end

    # --------------------------------------------------
    # Compute probabilities
    # --------------------------------------------------
    def compute_probabilities
      n = @states.length
      end_index = @states.index(END_STATE)

      total_transitions = 0
      outgoing_totals = Array.new(n, 0)

      n.times do |i|
        row_sum = @transition_counts.row(i).to_a.sum
        outgoing_totals[i] = row_sum
        total_transitions += row_sum
      end

      # State probabilities derived from transition structure
      @word_probabilities =
        Vector.elements(
          outgoing_totals.map { |v| total_transitions.positive? ? v.to_f / total_transitions : 0.0 }
        )

      prob_rows = []

      n.times do |i|
        if i == end_index
          absorbing = Array.new(n, 0.0)
          absorbing[end_index] = 1.0
          prob_rows << absorbing
        else
          row = @transition_counts.row(i).to_a
          row_sum = row.sum

          prob_rows << if row_sum.zero?
                         Array.new(n, 0.0)
                       else
                         row.map { |v| v.to_f / row_sum }
                       end
        end
      end

      @transition_probabilities = Matrix.rows(prob_rows)

      combined_rows = []

      n.times do |i|
        row = @transition_probabilities.row(i).to_a
        combined_rows << row.map { |p| p * @word_probabilities[i] }
      end

      @combined_probabilities = Matrix.rows(combined_rows)
    end

    public

    def distribution_after(steps:)
      n = @states.length

      start_index = @states.index(START_STATE)

      # initial distribution vector
      pi = Array.new(n, 0.0)
      pi[start_index] = 1.0

      pi_vector = Vector.elements(pi)

      p_power = @transition_probabilities.transpose ** steps

      result = p_power * pi_vector
      result
    rescue => e
      tp = @transition_probabilities
      tpt = @transition_probabilities.transpose
      puts <<~ERR
        🛑 Error computing distribution after #{steps} steps: #{e.message}
           transition_probabilities: #{tp.class} #{tp.row_count}x#{tp.column_count}
           trans_probs_transposed  : #{tpt.class} #{tpt.row_count}x#{tpt.column_count}
           pi_vector               : #{pi_vector.class} #{pi_vector.count}
      ERR
      Vector.zero(n)
    end

    # --------------------------------------------------
    # Public: Mermaid export with START/END
    # --------------------------------------------------
    public

    def to_mermaid_flow(threshold: 0.0, decimals: 3)
      lines = []

      lines << 'flowchart LR'

      n = @states.length

      # node labels
      n.times do |i|
        lines << "    #{mermaid_id(@states[i])}[\"#{display_label(@states[i])}\"]"
      end

      n.times do |i|
        from_id = mermaid_id(@states[i])

        n.times do |j|
          prob = @transition_probabilities[i, j]
          next if prob <= threshold

          # from_label = display_label_br(@states[i]) unless labels.include?(from_id)
          # puts "#{i}, #{j} processing transition to state: #{@states[j]}, labels: #{labels.last(2)}, from_label: |#{from_label}|"
          # labels << from_id

          to_id = mermaid_id(@states[j])
          # to_label = display_label_br(@states[j]) unless labels.include?(to_id)
          # labels << to_id

          formatted = format("%.#{decimals}f", prob)

          lines << "    #{from_id} -->|#{formatted}| #{to_id}"
        end
      end

      lines.join("\n")
    end

    def to_mermaid_flow_with_node_probabilities(steps: 3, threshold: 0.0)
      dist = distribution_after(steps:)

      lines = []
      lines << "flowchart LR"

      n = @states.length

      # Node labels with probability
      n.times do |i|
        label = display_label(@states[i])
        id = mermaid_id(@states[i])
        percent = (dist[i] * 100).round(1)

        lines << "    #{id}[\"#{label}<br/>#{percent}%\"]"
      end

      # Edges
      n.times do |i|
        n.times do |j|
          prob = @transition_probabilities[i, j]
          next if prob <= threshold

          from_id = mermaid_id(@states[i])
          to_id   = mermaid_id(@states[j])

          percent = (prob * 100).round(1)

          lines << "    #{from_id} -->|#{percent}%| #{to_id}"
        end
      end

      lines.join("\n")
end


    private

    def mermaid_id(label)
      label.gsub(/[^a-zA-Z0-9_]/, '_')
    end

    def display_label(label)
      case label
      when START_STATE then 'START'
      when END_STATE   then 'END'
      else label
      end
    end

    def display_label_br(label)
      "[\"#{display_label(label)}\"]"
    end
  end
end
