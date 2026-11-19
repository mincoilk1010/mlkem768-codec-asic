import math
from fractions import Fraction #can use real fraction (1/3 = 1/3 != 0.3333)

Q = 3329

def compress(x: int, d: int) -> int:
    assert 0 <= x < Q and d in (1, 4, 10) #rules to follow
    return ((x << (d + 1)) + Q) // (2 * Q) % (1 << d)

def decompress(y: int, d: int) -> int:
    assert 0 <= y < (1 << d)
    return ((Q * y) + (1 << (d - 1))) >> d

def selfcheck():
    for d in (1, 4, 10):
        for x in range(Q):
            v = Fraction((1 << d) * x, Q) #calculate (2^d * x)/q
            ref = math.floor(v + Fraction(1, 2)) % (1 << d) # (v + 1/2) mod 2^d
            assert compress(x, d) == ref, (d, x)
        for y in range(1 << d):
            assert compress(decompress(y, d), d) == y, (d, y)
    print("selfcheck OK")

def dump_vectors():
    for d in (1, 4, 10):
        w = (d + 3) // 4  
        with open(f"compress_d{d}_in.hex", "w") as fi, \
             open(f"compress_d{d}_exp.hex", "w") as fo:
            for x in range(Q):
                fi.write(f"{x:03x}\n")
                fo.write(f"{compress(x, d):0{w}x}\n")
        print(f"đã ghi compress_d{d}_in.hex / compress_d{d}_exp.hex")

if __name__ == "__main__":
    selfcheck()
    dump_vectors()