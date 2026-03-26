def join_words(*words, with joiner)
  words.join(joiner)
end

pp join_words("a", "b", "c", with: "-")
