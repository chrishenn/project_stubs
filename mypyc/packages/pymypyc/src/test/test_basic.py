import time

from pymypyc import fib


def test_basic():
    t0 = time.time()
    fib.fib(32)
    print(time.time() - t0)
