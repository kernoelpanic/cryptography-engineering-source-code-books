from typing import Sequence, Union


def add(a: int, b: int) -> int:
    """Implements addition of `a` and b` in GF256.
    Added here for reference only. Addition may typically be inlined for better performance.
    """
    return a ^ b


def _multiply(a: int, b: int) -> int:
    """Implements multiplication of `a` times `b` in GF256, i.e.,
    multiplication modulo the AES irreducible polynomial `x**8 + x**4 + x**3 + x + 1`.
    """
    IRREDUCIBLE_POLYNOMIAL = 0b100011011

    product = 0
    while b > 0:
        # add (xor operation) `a` to the product if the last bit of `b` == 1
        product ^= a * (b & 1)

        # shift `a` one bit to the left
        # and perform a modulo reduction if there is an overflow after shifting (a >> 8 == 1)
        a <<= 1
        a ^= (a >> 8) * IRREDUCIBLE_POLYNOMIAL

        # move the next highest bit of `b` bit shifting it down
        b >>= 1

    return product


def multiply(a: int, b: int) -> int:
    """Implements multiplication of `a` times `b` in GF256, i.e.,
    multiplication modulo the AES irreducible polynomial `x**8 + x**4 + x**3 + x + 1`.
    Faster implementation using a pregenerated lookup table (64KB in size).
    """
    return MULTIPLICATION_TABLE[(a << 8) | b]


def inverse(e: int) -> int:
    """Implements finding the inverse of an GF256 element `e` via a lookup table."""
    if e == 0:
        raise ValueError("Zero has no inverse element!")
    return INVERSE_LOOKUP_TABLE[e]


def init_multiplication_table() -> bytes:
    """Initializes the lookup table (256*256 elements) for quickly multiplying elements in GF256.
    The product `a * b` is computed by accessing the lookup table at index `(a << 8) | b`.
    """
    return bytes(0 if (i == 0 or j == 0) else _multiply(i, j) for i in range(256) for j in range(256))


def init_inverse_lookup_table() -> bytes:
    """Initializes the lookup table (256 elements) for quickly finding inverse elements in GF256."""
    table = [0] * 256
    for e in range(1, 256):
        for i in range(e, 256):
            if multiply(e, i) == 1:
                table[e] = i
                table[i] = e
    return bytes(table)


MULTIPLICATION_TABLE: bytes = init_multiplication_table()
INVERSE_LOOKUP_TABLE: bytes = init_inverse_lookup_table()


class Polynomial:
    """ Holds the coefficients of a polynomial in GF256 and provides a function to evaluate the polynomial. 
    Example usage: f = Polynomial([17, 124, 33]
                   f(10) ==> 56
    """

    def __init__(self, coefficients: Union[bytes, Sequence[int]]) -> None:
        self.coefficients = coefficients

    def __call__(self, x: int) -> int:
        """Evaluates this `t+1`-degree polynomial for the given input `x` in GF256.
        f(x) = c[0] + c[1] x + c[2] x^2 + ... + c[t-1] x^{t-1}
        """
        c = self.coefficients
        t = len(c)
        if t == 0:
            return 0

        # Initialize the result with the first coeffcient c[0].
        result = c[0]

        # Add terms c[1] x + ... + c[t-2] x^{t-2} to `result`.
        # `xk` is a helper variable holding the value value x^k.
        xk = x
        for k in range(1, t - 1):
            result ^= multiply(c[k], xk)
            xk = multiply(xk, x)

        # Add the last term c[t-1] to `result` (ensure t[0] is not added twice).
        if t - 1 > 0:
            result ^= multiply(c[t - 1], xk)

        return result
