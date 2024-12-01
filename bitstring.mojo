import bit
from collections import Optional, Dict


fn to_binary_string(number: UInt8, bits: Int = 8) -> String:
    var binary_str: String = ""
    for i in range(bits - 1, -1, -1):
        if (number & (1 << i)) != 0:
            binary_str += "1"
        else:
            binary_str += "0"
    return binary_str


struct BitStringLegacy:
    var data: List[UInt8]
    var bit_size: UInt8

    fn __init__(inout self):
        self.data = List[UInt8]()
        self.bit_size = 0

    fn push_back(inout self, bit: Bool):
        if self.bit_size % 8 == 0:
            self.data.append(0)
        if bit:
            var index = int(self.bit_size / 8)
            self.data[index] |= 1 << (self.bit_size % 8)
        self.bit_size += 1

    fn get(self, index: Int) -> Optional[SIMD[DType.uint8, 1]]:
        if index >= int(self.bit_size):
            return None
        var byte_index = int(index / 8)
        var bit_offset = int(index % 8)
        var res = self.data[byte_index] & (1 << bit_offset)
        var ret = (res != 0)
        return ret.cast[DType.uint8]()

    fn __str__(self) -> String:
        var ret: String = ""
        for uint in self.data:
            ret += to_binary_string(uint[])
            ret += ", "
        return ret


struct BitString:
    var data: List[UInt8]
    var bit_size: Int

    fn __init__(inout self):
        self.data = List[UInt8]()
        self.bit_size = 0

    fn __init__(inout self, uint: UInt8):
        var width = bit.bit_width(uint)
        var res = uint << (8 - width)
        self.data = List[UInt8](res)
        self.bit_size = int(width) or 1

    fn __copyinit__(inout self, other: Self):
        self.bit_size = other.bit_size
        self.data = other.data

    fn __moveinit__(inout self, owned other: Self):
        self.bit_size = other.bit_size
        self.data = other.data

    fn push_back(inout self, bit: Bool):
        if self.bit_size % 8 == 0:
            self.data.append(0)
        var index = int(self.bit_size / 8)
        var bit_position = 7 - (self.bit_size % 8)  # Start from the MSB
        if bit:
            self.data[index] |= 1 << bit_position
        self.bit_size += 1

    fn push_back_uint(inout self, uint: UInt8) raises:
        var width = bit.bit_width(uint) or 1
        for i in range(width):
            var bit = (uint & (1 << (width - 1 - i))) != 0
            self.push_back(bit)

    fn push_back_uint_full(inout self, uint: UInt8) raises:
        for i in range(8):
            var bit = (uint & (1 << (8 - 1 - i))) != 0
            self.push_back(bit)

    fn push_backc(inout self, bit: Bool) -> BitString:
        var self_copy = self
        self_copy.push_back(bit)
        return self_copy

    fn get(self, index: Int) -> Optional[SIMD[DType.uint8, 1]]:
        if index >= int(self.bit_size):
            return None
        var byte_index = int(index / 8)
        var bit_offset = 7 - int(index % 8)  # Adjust for MSB-first storage
        var res = self.data[byte_index] & (1 << bit_offset)
        var ret = (res != 0)
        return ret.cast[DType.uint8]()

    fn get_bits(self, start: Int, length: Int) raises -> UInt8:
        var ret: UInt8 = 0
        if start < 0 or start + length > int(self.bit_size):
            return ret
        for i in range(length):
            var bit = self.get(start + i)
            if bit is None:
                raise Error("BitString.get_bits: bit is None")
            ret = (ret << 1) | bit.value()
        return ret

    # TODO: SIMD this guy up
    fn __iadd__(inout self, other: Self) raises:
        if len(other.data) > 1:
            raise Error("Adding BitStrings with multiple uint8s unsupported")
        var d = other.data[0]
        for ii in range(other.bit_size):
            to_push_back = bool(int(d) >> (7 - ii))
            self.push_back(to_push_back)
        return None

    # TODO: Make this more performant
    fn __str__(self) -> String:
        if not self.data:
            return ""

        # Grab all but last set of bits
        var ret: String = ""
        for uint in self.data[:-1]:
            ret += to_binary_string(uint[])

        # Grab last set of bits
        var last_item = to_binary_string(self.data[-1])
        if self.bit_size != 8:
            last_item = last_item[: int(self.bit_size % 8)]
        ret += last_item

        return ret


fn encode_huffman_tree(mapping: Dict[String, BitString]) raises -> BitString:
    var ret = BitString()
    for item in mapping.items():
        var char = item[].key
        var bit_string = item[].value

        # Encode the character itself
        for c in char:
            ret.push_back_uint_full(UInt8(ord(c)))

        # Encode the length of the bit sequence
        ret.push_back_uint_full(UInt8(bit_string.bit_size))

        # Encode the bit sequence
        for i in range(bit_string.bit_size):
            var bit = bit_string.get(i)
            if bit:
                ret.push_back(bit.value() != 0)
    return ret


fn decode_huffman_tree(encoded: BitString) raises -> Dict[String, BitString]:
    var mapping = Dict[String, BitString]()
    var index = 0

    while index < int(encoded.bit_size):
        # Decode the character itself (assuming single-byte characters)
        var char_code = encoded.get_bits(index, 8)
        var char = chr(int(char_code))
        index += 8

        # Decode the length of the bit sequence
        var bit_length = encoded.get_bits(index, 8)
        index += 8

        # Decode the bit sequence
        var bit_string = BitString()
        for _ in range(bit_length):
            var bit = encoded.get_bits(index, 1) != 0
            bit_string.push_back(bit)
            index += 1

        mapping[char] = bit_string

    return mapping
