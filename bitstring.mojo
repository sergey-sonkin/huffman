import bit
from collections import Optional


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
    var bit_size: UInt8

    fn __init__(inout self):
        self.data = List[UInt8]()
        self.bit_size = 0

    fn push_back(inout self, bit: Bool):
        if self.bit_size % 8 == 0:
            self.data.append(0)
        var index = int(self.bit_size / 8)
        var bit_position = 7 - (self.bit_size % 8)  # Start from the MSB
        if bit:
            self.data[index] |= 1 << bit_position
        self.bit_size += 1

    fn get(self, index: Int) -> Optional[SIMD[DType.uint8, 1]]:
        if index >= int(self.bit_size):
            return None
        var byte_index = int(index / 8)
        var bit_offset = 7 - int(index % 8)  # Adjust for MSB-first storage
        var res = self.data[byte_index] & (1 << bit_offset)
        var ret = (res != 0)
        return ret.cast[DType.uint8]()

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