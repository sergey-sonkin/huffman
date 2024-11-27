Notes


2024/11/17

How do we add all encodings into one bitstring?

2 Options

1. Add data right away to BitString


2. Store all of the UInt8s, later conacatenate


Pros:
We save all of the computation for the very end. Don't need to append to BitString each time

We can likely also take advantage of some sort of SIMD native mapping

So we do SIMD mapping, SIMD concat

Instead of iterative mapping, iterative concat

Cons:
Later concatenate: Takes up more memory for large corpus of text


[0010010, 00101101, 10110100]
-> [10010, 101101, 10110100]
3 digits here, 2 digits here, 0 digits here
[0, 3, 5]
[10010101 101]

Ultimately we will need to try both approaches to understand which is faster.

Notes: From exploring further, I'm not sure there is an elegant way to perform SIMD mapping. Doesn't seem like the intrinsic is supported in Mojo.