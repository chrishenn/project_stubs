from mypy_extensions import u8


def fib(n: u8) -> int:
    if n <= 1:
        return n
    else:
        return fib(n - 2) + fib(n - 1)
