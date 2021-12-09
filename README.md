# Advent of Code 2021

This repository contains code for Advent of Code 2021 in Swift. , and below are some notes about what I've
learned about the language.

## Day 1

Mostly learned async in practice, starting with `URL.lines` method and then extending `AsyncSequence` to add `slidingWindows`.
That also required to learn a bit about generics in Swift, like protocols and associated types. Different from C++ and Scala,
but OK.

## Day 2

First use of enumerations. 

## Day 3

Wrote another Sequence extension -- `countIf`. Learned using radix for parsing/formatting integers.

## Day 4

Had to use contrained generics. Finding the closed-closed ranges as default might be a design mistake;
C++ closed-open ranges are generally easier to work with. 


## Day 5

Swift does not appear to have native regular expression, and `NSRegularExpression` is awkward to use. I also miss
`Iterator.iterate` from Scala and `Sequence.take`. Generally, it starts to feel that Swift `Sequence` is way too lean.

## Day 8

Converting of pairs to map with `Dictionary(uniqueKeysAndValues:)` is to heavy-weight, compared to `toMap` in Scala.

## Day 9

Tried to look for swift array library. Swift-numerics does not even have arrays. Tensorflow/Swift is archived. 

Tuple is not `Hashable`, so you can't have `Set<(Int, Int>)`

I wish there are shorter syntax for data structures, similar to case classes in Scala and data classes in Kotlin.



## Conclusions

What I'd like from Swift

- Native regular expression, ideally integrated with matching (though this part might not be possible).
- After using Scala, the fact that `if` is not an expression is disappointing.
- More methods in the `Sequence` class (although swift-algorithms package fills some gaps)
- Replacement 
- Would be nice to have an equivalent of Python's `defaultdict`
