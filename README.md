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

## Day 16: Packet Decoder

Expression trees, bit parsing. Nothing complex conceptually, struggled a bit because Swift ranges retain
indices of the original sequence, and I repeatedly used them as standalone containers.

## Day 17: Trick Shot

Probe is thrown with initial velocity, the x velocity gradually reduces to 0, the y velocity changes by gravity.
What is the largest height we can reach while still reaching a desired target area?

The task did not clearly indicate that target area is always below y=0, but with that assumption, the
solution is easy - the probe first goes up, then returns to y=0, then makes another jump, and we should
land at the lowest point of the target area of maximize height.

But then, part 2 of the task asks for actually enumerate all the possible velocities that end us in
target area. While I've tried to use quandatic equations to compute optimal bounds, I eventually
decided that I'll mess up something with floating point, and used coarse bounds. That worked fast enough.


## Day 18: Snailfish

Expression tree that must be simplified using fancy rules - in particular where changing a node must
propagage values left and right to siblings. 

Originally, I went with (value, depth) array that made transformation super easy, but the final evaluation
part was a bit tricky. In the end, just learned about indirect enums and did things 'properly'.

## Day 19: Beacon Scanner

Several sensors all report position of beacons in 3D space. We know that if sensor areas overlap, there
are at least 12 beacons in the overlap, and we want to count unique becons. The trick is that each sensor
can be randomly rotated.

The actual matching loop is easy, what took most time is generating all possible rotation. I cheated and
used simd/quaternion library to generate all possible rotations and trim duplicates - and finding that
simd_int conversion is truncating, not rounding.

## Day 20: Trench Map

Task involves taking neighbour pixels in 0/1 image, forming in index in array, and transforming. The trick
was assuming the image is infinite, and that the rules are setup so that outside pixels flip between 0 and 1
on each step. Used dictionary to brute-force unbounded image; most of run time is actually in the indexing
operation.

Best other solution: https://twitter.com/YassineAlouini/status/1472922768496865283 - that uses convolve2d
from scipy, and the fact that you can index numpy array by another array.


## Conclusions

What I'd like from Swift

- Native regular expression, ideally integrated with matching (though this part might not be possible).
- After using Scala, the fact that `if` is not an expression is disappointing.
- More methods in the `Sequence` class (although swift-algorithms package fills some gaps)
- Would be nice to have an equivalent of Python's `defaultdict`

Ecosystem maturity
- No equivalent for numpy
- The library documentation is generally poor, with very little overview docs.



