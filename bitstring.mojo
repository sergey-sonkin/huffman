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

    fn __init__(inout self, uint: UInt8):
        var width = bit.bit_width(uint)
        var res = uint << (8 - width)
        self.data = List[UInt8](res)
        self.bit_size = width or 1

    fn __copy__(inout self, other: Self):
        self.bit_size = other.bit_size
        self.data = other.data

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

    fn push_backc(inout self, bit: Bool) -> BitString:
        var self_copy = self
        if self_copy.bit_size % 8 == 0:
            self_copy.data.append(0)
        var index = int(self_copy.bit_size / 8)
        var bit_position = 7 - (self_copy.bit_size % 8)  # Start from the MSB
        if bit:
            self_copy.data[index] |= 1 << bit_position
        self_copy.bit_size += 1
        return self_copy

    fn get(self, index: Int) -> Optional[SIMD[DType.uint8, 1]]:
        if index >= int(self.bit_size):
            return None
        var byte_index = int(index / 8)
        var bit_offset = 7 - int(index % 8)  # Adjust for MSB-first storage
        var res = self.data[byte_index] & (1 << bit_offset)
        var ret = (res != 0)
        return ret.cast[DType.uint8]()

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
