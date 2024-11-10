import heapq
from collections import Counter, Optional
from collections.counter import CountTuple
from memory.unsafe_pointer import UnsafePointer


@value
struct Node:
    var count: UInt32
    var char: String
    var left: UnsafePointer[Node]
    var right: UnsafePointer[Node]

    fn __init__(
        inout self,
        count: UInt32,
        char: String,
    ):
        self.count = count
        self.char = char
        self.left = UnsafePointer[Node].alloc(1)
        self.right = UnsafePointer[Node].alloc(1)

    fn __str__(inout self) -> String:
        var test: String = "Node count: {}, node value: {}."
        try:
            return test.format(self.count, self.char)
        except:
            return "Failed to print node"


fn add_nodes(owned n1: Node, owned n2: Node) -> Node:
    n = Node(count=n1.count + n2.count, char=n1.char + n2.char)
    n.left = UnsafePointer[Node].address_of(n1)
    n.right = UnsafePointer[Node].address_of(n2)
    print(n.__str__())
    print(n.left[].__str__())
    print(n.right[].__str__())
    return n


fn huffman[input: String]() -> UInt8:
    alias l = len(input)

    @parameter
    if l == 0:
        return 0
    elif l == 1:
        return 1

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
    var counts_element_list = List[Node]()
    var ii = 0  # does mojo really not implement enumerate? stone age.
    for count_tuple in counts_list:
        ci = count_tuple[]._count
        vi = count_tuple[]._value
        new_node = Node(count=ci, char=vi)
        counts_element_list.insert(value=new_node, i=ii)
        ii += 1

    # This is likely where the intel paper makes huge advancments
    while (
        len(counts_element_list) > 1
    ):  # Could replace while statement with subtraction to not keep checking len!
        var n1 = counts_element_list.pop(0)
        var n2 = counts_element_list.pop(0)
        var new = add_nodes(n1^, n2^)
        print(new.left[].__str__())
        counts_element_list.insert(0, new)

    last = counts_element_list[0]

    print(last.count)
    print(last.char)
    print(last.__str__())
    print("going to print this thing that will fail")
    print(last.left[].__str__())

    return 0


fn main():
    alias input: String = "ABRACADABRA"

    inp = huffman[input]()
    print("made it to the end of main")
    return
