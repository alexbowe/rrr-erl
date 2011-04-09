def element_0(c):
    """Generates first permutation with a given amount of set bits, which is used to generate the rest."""
    return (1 << c) - 1

def next_perm(v):
    """
    Generates next permutation with a given amount of set bits, given the previous lexicographical value.
    Taken from http://graphics.stanford.edu/~seander/bithacks.html#NextBitPermutation
    """
    t = (v | ( v - 1)) + 1
    w = t | ((((t & -t) / (v&-v)) >> 1) - 1)
    return w

def gen_blocks(c, b):
    """
    Generates all blocks of a given class and blocksize
    """
    initial = element_0(c)
    v = initial
    block_mask = (1 << b) - 1

    while (v >= initial):
        yield v
        v = next_perm(v) & block_mask

def all_blocks(b):
    """
    rev_offsets is only needed during construction of a RRR sequence...
    class_bases gives the first position of the blocks in the class
    blocks is all permutations enumerated and clustered by class number
    """
    blocks = [0]
    rev_offsets = [0] * 2**b
    class_bases = [0] * (b+1)
    global_idx = 1
    for c in range(1, b+1):
        l = list(gen_blocks(c, b))
        class_bases[c] = global_idx
        for (o, block) in enumerate(l):
            blocks.append(block)
            rev_offsets[block] = o
            global_idx += 1
    return blocks, rev_offsets, class_bases

def pascal_row(n):
    """Returns a generator for the nth row of pascal's triangle"""
    # Which side of pascal's triangle is the kth position on?
    v = 1
    yield v
    for i in range(0, n):
        v = ((n - i) * v) / (i+1)
        yield v

def bits_from_0_to(n):
    """Returns amount of bits required to represent the values 0..n"""
    n = n
    result = 0
    while (n > 0):
        result +=1
        n = n >> 1
    return result

def gen_ceillog2binomial(n):
    """Generates the values for the number of bits required for each class in the blocksizeth row of pascal's
    triangle"""
    for element in list(pascal_row(n)):
        yield bits_from_0_to(element - 1)

def table_string(table):
    """
    Convert an array to to a string for use with a template for another langauge.
    """
    s = ''
    last = str(table[-1:][0])
    for i in range(len(table) - 1):
        s += str(table[i]) + ','
    return s + last

def lookup(c, o, blocks, class_start):
    """
    This is really just an example of how to look things up.
    """
    index = class_start[c] + o
    return blocks[index]

def output_filename(filename):
    strip_size = len('.template')
    return filename[:-strip_size]

if __name__ == '__main__':
    from glob import glob
    from string import Template

    b = 15 # fix this to be a param
    (blocks, reverse_offsets, class_bases) = all_blocks(b)
    data = {}
    data['blocksize'] = b
    data['classbits'] = bits_from_0_to(b)
    data['ceillog2binomial'] = table_string(list(gen_ceillog2binomial(b)))
    data['blocks'] = table_string(blocks)
    data['rev_offsets'] = table_string(reverse_offsets)
    data['class_bases'] = table_string(class_bases)

    for filename in glob('*.template'):
        with open(filename, 'r') as f:
            t = Template(f.read())

        with open(output_filename(filename), 'w') as f:
            output = t.safe_substitute(data)
            f.write(output)
