import heapq
from collections import Counter


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


# Step 3: Generate Huffman codes from the tree
def generate_codes(node, prefix="", code_map={}):
    if node is not None:
        # It's a leaf node
        if node.char is not None:
            code_map[node.char] = prefix
        else:
            generate_codes(node.left, prefix + "0", code_map)
            generate_codes(node.right, prefix + "1", code_map)
    return code_map


# Step 4: Encoding the text
def encode_text(text, code_map):
    return "".join(code_map[char] for char in text)


# Step 5: Decoding the encoded text
def decode_text(encoded_text, root):
    decoded_text = []
    current_node = root

    for bit in encoded_text:
        # Traverse the Huffman tree based on the current bit
        current_node = current_node.left if bit == "0" else current_node.right
        # If we reach a leaf node, we found a character
        if current_node.char is not None:
            decoded_text.append(current_node.char)
            current_node = root  # Reset to start for next character

    return "".join(decoded_text)


# Main code to test the Huffman encoding
if __name__ == "__main__":
    text = "hello, huffman encoding!"

    # Build the Huffman tree
    root = build_huffman_tree(text)

    # Generate the Huffman codes
    code_map = generate_codes(root)
    print("Huffman Codes:", code_map)

    # Encode the text
    encoded_text = encode_text(text, code_map)
    print("Encoded Text:", encoded_text)

    # Decode the text back
    decoded_text = decode_text(encoded_text, root)
    print("Decoded Text:", decoded_text)

    # Check that encoding and decoding gives the original text
    assert text == decoded_text, "Decoding did not match the original text!"
