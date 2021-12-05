# Advent of Code 2021

This repository contains for for Advent of Code 2021 in Swift, and below are some notes about what I've
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

