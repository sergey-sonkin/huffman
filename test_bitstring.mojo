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


fn main() raises:
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

    # # another 4
    # string2.push_back(1)
    # print(string2.__str__())
    # string2.push_back(1)
    # print(string2.__str__())
    # string2.push_back(0)
    # print(string2.__str__())
    # string2.push_back(1)
    # print(string2.__str__())

    # y = string2.data.__str__()
    # print(y)
