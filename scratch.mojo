from algorithm.functional import vectorize
from sys import simdwidthof
import time

alias simd_width = simdwidthof[UInt8]()


def main():
    # var x: List[UInt8] = List[UInt8](2**7 - 1, 2**7 - 6)
    var x0: List[UInt8] = List[UInt8](2**7 - 1, 2**7 - 1)
    var x = x0.unsafe_ptr()
    print(x[].__str__())

    var ret = (x.load[]() >> 1)
    print(ret.__str__())

    var s = "Hello, world!"
    var count = chars_count(s)
    print(count)

    print("-----------------")

    var s2 = "asdfgasdfasjdfkjasdlfjaskldjfasdjlfaksdfjabsdfbasdnfbasdmbfnamsbdfnqioweriqweur"
    var count2 = chars_count(s2)
    print(count2)

    print("-----------------")
    var l0 = List[UInt8](2**7, 2**6, 2**5, 2**4) * 40000
    print(l0.__str__())
    ret = chars_count2(l0)
    print(l0.__str__())

    print("-----------------")
    var l = List[UInt8](2**7, 2**6, 2**5, 2**4)
    print(l.__str__())
    for elem in l:
        elem[] >>= 1
    print(l.__str__())


@always_inline
fn chars_count(s: StringLiteral) -> Int:
    var p = s.as_bytes_slice().unsafe_ptr()
    var string_byte_length = len(s)
    var result = 0

    @parameter
    fn count[simd_width: Int](offset: Int):
        print("Hello")
        result += int(
            ((p.load[width=simd_width](offset) >> 6) != 0b10)
            .cast[DType.uint8]()
            .reduce_add()
        )

    vectorize[count, simd_width](string_byte_length)
    return result


fn chars_count2(l: List[UInt8]) -> Int:
    var p = l.unsafe_ptr()

    var string_byte_length = len(l)
    var result = 0

    @parameter
    fn count[simd_width: Int](offset: Int):
        q = p.load[width=simd_width](offset)
        q >>= 1
        p.store[width=simd_width](offset, q)

    vectorize[count, simd_width](string_byte_length)
    return result
