import bit
from bitstring import BitString
import imports.heapq
import math
from collections import Counter, Optional, Dict
from collections.counter import CountTuple
from memory.unsafe_pointer import UnsafePointer

alias debug = True


@value
struct Node:
    var char: String
    var grouped_chars: UnsafePointer[Node]  # Can this be a Reference[Node]?
    var individual_char: UnsafePointer[Node]
    var count: UInt32
    var is_root: Bool

    fn __init__(
        inout self,
        count: UInt32,
        char: String,
    ):
        self.count = count
        self.char = char
        self.grouped_chars = UnsafePointer[Node].alloc(1)
        self.individual_char = UnsafePointer[Node].alloc(1)
        self.is_root = True

    fn __str__(inout self) -> String:
        var test: String = "Node count: {}, node value: {}."
        try:
            return test.format(self.count, self.char)
        except:
            return "Failed to print node"

    fn __lt__(self, other: Self) -> Bool:
        return self.count < other.count

    fn __gt__(self, other: Self) -> Bool:
        return self.count > other.count

    fn has_next(self) -> Bool:
        # We seemingly can't rely on unsafe pointer being unallocated. self.x.__as_bool__ seems to always return True
        return not self.is_root

    fn print_tree(
        self, indent: String = "", extra_pedantic: Bool = False
    ) raises:
        var s: String = "{}Node(char='{}', count={})"
        s = s.format(indent, self.char, self.count)
        print(s)

        if not self.is_root:
            var sleft: String = "{}  Left:"
            sleft = sleft.format(indent)
            if extra_pedantic:
                print(sleft)
            self.individual_char[].print_tree(indent + "    ", extra_pedantic)

            var sright: String = "{}  Right:"
            sright = sright.format(indent)
            if extra_pedantic:
                print(sright)
            self.grouped_chars[].print_tree(indent + "    ", extra_pedantic)


fn add_nodes(owned n1: Node, owned n2: Node) -> Node:
    n = Node(count=n1.count + n2.count, char=n1.char + n2.char)
    n.grouped_chars.init_pointee_move(n1^)
    n.individual_char.init_pointee_move(n2^)
    n.is_root = False
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


@always_inline
fn parse_input_to_node[
    input: String
]() -> Node:  # TODO: Refactor to reference. We hate copies!
    alias l = len(input)

    @parameter
    if l == 0:
        return Node(count=0, char="")
    elif l == 1:
        return Node(count=1, char=input[0])

    # Step 1: Convert string to list of char and get the counts
    input_char_list = List[String]()
    for char in input:
        input_char_list.append(String(char))

    var counts = Counter(input_char_list)
    var num_counts = len(counts)

    # If we just repeat all of the strings, just one node!
    if num_counts == 1:
        return Node(count=l, char=input[0])

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

    heapq.heapify[Node](counts_element_list)

    # Step 3: Combine nodes to form tree with root node
    # This is likely where the intel paper makes huge advancments
    while (
        len(counts_element_list) > 1
    ):  # Could replace while statement with subtraction to not keep checking len!
        var n1 = heapq.heappop(counts_element_list).value()
        var n2 = heapq.heappop(counts_element_list).value()
        var new = add_nodes(n1^, n2^)
        heapq.heappush(counts_element_list, new)

    return counts_element_list[0]


@always_inline
fn create_mapping(root_node: Node) -> Dict[String, BitString]:
    var char_mapping_2 = Dict[String, BitString]()
    var nodes_to_parse_2 = List[Node](root_node)
    var previous_encoding_list = List[BitString](BitString())

    while nodes_to_parse_2:
        current_node_2 = nodes_to_parse_2.pop()
        var previous_encoding = previous_encoding_list.pop()

        if current_node_2.is_root:
            print(current_node_2.__str__(), previous_encoding.__str__())
            char_mapping_2[current_node_2.char] = previous_encoding
        else:
            nodes_to_parse_2.append(current_node_2.individual_char[])
            nodes_to_parse_2.append(current_node_2.grouped_chars[])
            previous_encoding_list.append(previous_encoding.push_backc(1))
            previous_encoding_list.append(previous_encoding.push_backc(0))

    return char_mapping_2


fn huffman[input: String]() -> UInt64:
    root_node = parse_input_to_node[input]()
    mapping = create_mapping(root_node)

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

    var t = parse_input_to_node[input]()
    hoffman_encoding = huffman[input]()
    print(hoffman_encoding)
    print("made it to the end of main")
    return
