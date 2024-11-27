from huffman import *
from testing import assert_equal


fn test_create_mapping() raises:
    node = parse_input_to_node[input="ABRACADABRA"]()
    node.print_tree()
    mapping = create_mapping(node)
    for item in mapping.items():
        print(item[].key)
        print((item[].value).__str__())


fn main() raises:
    test_create_mapping()
