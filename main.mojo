import heapq
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


fn add_nodes(owned n1: Node, owned n2: Node) -> Node:
    n = Node(count=n1.count + n2.count, char=n1.char + n2.char)
    n.grouped_chars.init_pointee_move(n1^)
    n.individual_char.init_pointee_move(n2^)
    return n


fn huffman[input: String]() -> UInt8:
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

    print("we made it here")
    # Step 4: Create mapping
    var char_mapping = Dict[String, UInt8]()
    var current_node = root_node
    var value: UInt8 = 0b0
    while current_node.has_next():
        current_char = current_node.individual_char[].char
        char_mapping[current_node.individual_char[].char] = value
        print(current_char, value)
        value = (value + 1) << 1
        current_node = current_node.grouped_chars[]
    # Last node: Manually create left and right
    char_mapping[current_node.char] = value + 1
    print(char_mapping.__str__())
    return 0


fn main():
    alias input: String = "ABRACADABRA"

    inp = huffman[input]()
    print("made it to the end of main")
    return
