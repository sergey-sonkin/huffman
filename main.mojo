import bit
import heapq
import math
from collections import Counter, Optional, Dict
from collections.counter import CountTuple
from memory.unsafe_pointer import UnsafePointer

alias debug = True


@value
struct Node:
    var count: UInt32
    var char: String
    var grouped_chars: UnsafePointer[Node]  # Can this be a Reference[Node]?
    var individual_char: UnsafePointer[Node]

    fn __init__(
        inout self,
        count: UInt32,
        char: String,
    ):
        self.count = count
        self.char = char
        self.grouped_chars = UnsafePointer[Node].alloc(1)
        self.individual_char = UnsafePointer[Node].alloc(1)

    fn __str__(inout self) -> String:
        var test: String = "Node count: {}, node value: {}."
        try:
            return test.format(self.count, self.char)
        except:
            return "Failed to print node"

    fn has_next(self) -> Bool:
        # We seemingly can't rely on unsafe pointer being unallocated. self.x.__as_bool__ seems to always return True
        return len(self.char) != 1


struct BitString:
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


fn add_nodes(owned n1: Node, owned n2: Node) -> Node:
    n = Node(count=n1.count + n2.count, char=n1.char + n2.char)
    n.grouped_chars.init_pointee_move(n1^)
    n.individual_char.init_pointee_move(n2^)
    return n


# TODO: Surely there's something better than casting back and forth
fn len_binary(x: UInt8) -> UInt8:
    float_x = x.cast[DType.float16]()
    if x == 0:
        return 0
    if x > 64 and x % 2 != 0:
        ret = math.floor(math.log2(float_x)) + 2
    else:
        ret = math.floor(math.log2(float_x)) + 1
    return ret.cast[DType.uint8]()


fn to_binary_string(number: UInt64, bits: Int = 32) -> String:
    var binary_str: String = ""
    for i in range(bits - 1, -1, -1):
        if (number & (1 << i)) != 0:
            binary_str += "1"
        else:
            binary_str += "0"
    return binary_str


fn huffman[input: String]() -> UInt64:
    alias l = len(input)

    @parameter
    if l == 0:
        return 0
    elif l == 1:
        return 1

    # Step 1: Convert string to list of char and get the counts
    input_char_list = List[String]()
    for char in input:
        input_char_list.append(String(char))

    var counts = Counter(input_char_list)
    var num_counts = len(counts)

    if num_counts == 0:
        return 0
    if num_counts == 1:
        return ord(str(input)[0])

    var counts_list = counts.most_common(num_counts)
    counts_list.reverse()

    # Step 2: From list of counts, convert into base nodes
    var counts_element_list = List[Node]()
    var ii = 0  # does mojo really not implement enumerate? stone age.
    for count_tuple in counts_list:
        ci = count_tuple[]._count
        vi = count_tuple[]._value
        new_node = Node(count=ci, char=vi)
        counts_element_list.insert(value=new_node, i=ii)
        ii += 1

    # Step 3: Combine nodes to form tree with root node
    # This is likely where the intel paper makes huge advancments
    while (
        len(counts_element_list) > 1
    ):  # Could replace while statement with subtraction to not keep checking len!
        var n1 = counts_element_list.pop(0)
        var n2 = counts_element_list.pop(0)
        var new = add_nodes(n1^, n2^)
        counts_element_list.insert(0, new)

    root_node = counts_element_list[0]

    # Step 4: Create mapping
    var char_mapping = Dict[String, UInt8]()
    var current_node = root_node
    var value: UInt8 = 0b0
    while current_node.has_next():
        char_mapping[current_node.individual_char[].char] = value
        value = (value + 1) << 1
        current_node = current_node.grouped_chars[]
    char_mapping[current_node.char] = value >> 1

    var ret: UInt64 = 0b01
    # Step 5: Encoding the message
    for char in input:
        binary_mapping = char_mapping.get(char, 0)
        padding_length = max(bit.bit_width(binary_mapping), 1).cast[
            DType.uint64
        ]()
        ret.__ilshift__(padding_length)
        ret += binary_mapping.cast[DType.uint64]()
        print(
            "Value:",
            char,
            "Mapping",
            to_binary_string(binary_mapping.cast[DType.uint64]()),
            "Calculated length",
            len_binary(binary_mapping),
            "Padding",
            padding_length,
        )
        print("Mapping", binary_mapping, "Ret:", ret, to_binary_string(ret))

    # ## Step 6: Decoding the message
    # for char in ret:

    return ret


fn main():
    alias input: String = "ABRACADABRA"

    hoffman_encoding = huffman[input]()
    print(hoffman_encoding)
    print("made it to the end of main")
    return
