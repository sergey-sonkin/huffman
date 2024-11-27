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

Notes: From exploring further, I'm not sure there is an elegant way to perform SIMD mapping.

For context, this is what the code might look like:

Hi Tiffany. I ask that you don't. Please just let me know 
Hi Tiffany. We are going our separate ways and I do not want to communicate further. I ask that you do not text or call me outside of letting me know when you will leave the apartment and once you have done so.

Tiffany I understand this is a really hard time, but we've broken up and we are going our separate ways. I ask that we limit our communication going forward. Please only contact me (via text) to let me know when you plan to leave the apartment and once you have done so.