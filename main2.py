import heapq
from collections import Counter

# Node class definition, build_huffman_tree, generate_codes functions stay the same


# Step 1: Define a Node class for the Huffman tree
class Node:
    def __init__(self, char, freq):
        self.char = char
        self.freq = freq
        self.left = None
        self.right = None

    # Define comparison operators for heap sorting
    def __lt__(self, other):
        return self.freq < other.freq


# Step 2: Build the Huffman Tree
def build_huffman_tree(text):
    # Count the frequency of each character in the text
    frequency = Counter(text)

    # Create a priority queue (min-heap) with initial nodes
    heap = [Node(char, freq) for char, freq in frequency.items()]
    heapq.heapify(heap)

    # Merge nodes until only one root node is left
    while len(heap) > 1:
        left = heapq.heappop(heap)
        right = heapq.heappop(heap)
        merged = Node(None, left.freq + right.freq)
        merged.left = left
        merged.right = right
        heapq.heappush(heap, merged)

    # The final node is the root of the Huffman Tree
    return heap[0]


def generate_codes(node, prefix=0, length=0, code_map={}):
    """Generate Huffman codes as integers with their bit lengths."""
    if node is not None:
        if node.char is not None:
            code_map[node.char] = (prefix, length)
        else:
            generate_codes(node.left, (prefix << 1), length + 1, code_map)
            generate_codes(node.right, (prefix << 1) | 1, length + 1, code_map)
    return code_map


def encode_text(text, code_map):
    """Encode text to binary data using integer Huffman codes."""
    binary_data = 0  # Holds the binary representation of the encoded data
    total_bits = 0  # Total number of bits in the binary_data

    for char in text:
        code, length = code_map[char]
        binary_data = (binary_data << length) | code
        total_bits += length

    # Calculate padding to make total bits a multiple of 8
    padding = (8 - total_bits % 8) % 8
    binary_data = binary_data << padding  # Add padding bits

    # Convert binary_data to a byte array
    byte_array = []
    while binary_data:
        byte_array.insert(0, binary_data & 0xFF)  # Extract the last 8 bits
        binary_data >>= 8

    return bytes(byte_array), padding


def decode_bytes(byte_data, padding, root):
    """Decode the binary data back to the original text."""
    # Convert byte data back to a single integer (bitstream)
    bit_stream = 0
    for byte in byte_data:
        bit_stream = (bit_stream << 8) | byte

    # Remove the padding bits
    bit_stream >>= padding
    decoded_text = []
    current_node = root

    # Decode each bit by traversing the Huffman tree
    bit_length = bit_stream.bit_length()
    for i in range(bit_length - 1, -1, -1):
        bit = (bit_stream >> i) & 1
        current_node = current_node.left if bit == 0 else current_node.right

        if current_node.char is not None:
            decoded_text.append(current_node.char)
            current_node = root

    return "".join(decoded_text)


# Main code to test the Huffman encoding with direct binary storage
if __name__ == "__main__":
    text = "hello, huffman encoding!"

    # Build the Huffman tree and generate the codes
    root = build_huffman_tree(text)
    code_map = generate_codes(root)

    # Encode the text directly to bytes
    byte_data, padding = encode_text(text, code_map)
    print("Byte Data:", byte_data)

    # Decode the byte data back to text
    decoded_text = decode_bytes(byte_data, padding, root)
    print("Decoded Text:", decoded_text)

    # Check that encoding and decoding give the original text
    print(text)
