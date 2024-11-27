import bitstring
from testing import assert_equal


fn test_bitstring_legacy() raises:
    string = bitstring.BitStringLegacy()

    string.push_back(1)
    assert_equal(string.__str__(), "00000001, ")

    string.push_back(1)
    assert_equal(string.__str__(), "00000011, ")

    string.push_back(0)
    assert_equal(string.__str__(), "00000011, ")

    string.push_back(1)
    assert_equal(string.__str__(), "00001011, ")


fn test_iadd() raises:
    s1 = bitstring.BitString()
    s1.push_back(0)

    s2 = bitstring.BitString()
    s2.push_back(1)
    s2.push_back(1)

    assert_equal(s1.__str__(), "0")
    s1.__iadd__(s2)
    assert_equal(s1.__str__(), "011")


fn test_push_back() raises:
    string = bitstring.BitString()
    assert_equal(string.__str__(), "")

    string.push_back(1)
    assert_equal(string.__str__(), "1")
    string.push_back(1)
    assert_equal(string.__str__(), "11")
    string.push_back(0)
    assert_equal(string.__str__(), "110")
    string.push_back(1)
    assert_equal(string.__str__(), "1101")

    ## next 4
    string.push_back(1)
    assert_equal(string.__str__(), "11011")
    string.push_back(1)
    assert_equal(string.__str__(), "110111")
    string.push_back(0)
    assert_equal(string.__str__(), "1101110")
    string.push_back(1)
    assert_equal(string.__str__(), "11011101")


fn test_init_fromint() raises:
    s1 = bitstring.BitString(0)
    assert_equal(s1.__str__(), "0")
    assert_equal(s1.bit_size, 1)

    s2 = bitstring.BitString(1)
    assert_equal(s2.__str__(), "1")
    assert_equal(s2.bit_size, 1)

    s3 = bitstring.BitString(2)
    assert_equal(s3.__str__(), "10")
    assert_equal(s3.bit_size, 2)

    s4 = bitstring.BitString(0b11111111)
    assert_equal(s4.__str__(), "11111111")
    assert_equal(s4.bit_size, 8)


fn main() raises:
    test_push_back()
    test_iadd()
    test_init_fromint()
