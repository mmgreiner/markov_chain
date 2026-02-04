Excellent — this is the right question.

The short answer:

`__START__` is not zero because you are **not computing word frequency**.

You are computing:

[
P(i) = \frac{\text{outgoing transitions from state } i}{\text{total transitions}}
]

That is a **transition-based state probability**, not a token frequency probability.

---

# Why START Is Non-Zero

Look at your code:

```ruby
outgoing_totals.map { |v| v.to_f / total_transitions }
```

`outgoing_totals[i]` = number of outgoing transitions from state `i`.

Now think about START:

Every sentence produces:

```
START → first_word
```

So if you have 4 sentences, START has 4 outgoing transitions.

Therefore:

```
outgoing_totals[START] = number_of_sentences
```

So:

```
P(START) = sentences / total_transitions
```

That is why you get:

```
0.307692...
```

It’s not a word probability.
It’s a **state transition mass proportion**.

---

# The Conceptual Issue

You are mixing two different interpretations:

## 1️⃣ Token Frequency Model

[
P(word) = \frac{\text{count of word tokens}}{\text{total tokens}}
]

In that model:

* START frequency = 0
* END frequency = 0
* Only real words counted

That matches your earlier `freq_array`.

---

## 2️⃣ Pure Markov State Model

[
P(i) = \frac{\text{outgoing transitions from } i}{\text{total transitions}}
]

Now START has probability mass,
because it participates in transitions.

That is mathematically consistent for a state graph.

---

# Which One Is “Correct”?

Both are correct — for different meanings.

| Interpretation  | START probability |
| --------------- | ----------------- |
| Word frequency  | 0                 |
| Transition mass | > 0               |

Right now you are using transition mass.

---

# If You Want START = 0

Then compute word probabilities only from real words:

```ruby
real_indices = @states.each_index.reject do |i|
  @states[i] == START_STATE || @states[i] == END_STATE
end

real_total = real_indices.sum { |i| outgoing_totals[i] }

@word_probabilities =
  Vector.elements(
    @states.each_index.map do |i|
      if real_indices.include?(i)
        outgoing_totals[i].to_f / real_total
      else
        0.0
      end
    end
  )
```

Now START and END will be zero.

---

# Deeper Insight

In a true absorbing Markov chain:

* START is just an initial condition
* It is not part of long-term state probability
* It is not part of stationary distribution
* It exists only at time t = 0

So giving it a steady-state probability is conceptually artificial.

---

# The Clean Mathematical Approach

Best practice:

* Do NOT define a “word probability” separately.
* Use `distribution_after(k)` if you want real state probability.
* Or compute stationary distribution of Q if analyzing transient states.

---

# Bottom Line

Your code is doing exactly what you told it to do:

You asked it to compute probabilities from outgoing transitions.

START has outgoing transitions.

Therefore START gets probability mass.

No bug — just interpretation.

---

If you tell me what you want the number to *mean*, I’ll tell you the mathematically correct way to compute it.


# See also

https://chatgpt.com/share/698324ff-acb0-8008-814a-869f942b503a
