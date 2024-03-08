""" Implementation of the Shamir Secret Sharing for Mnemonic Phrases (SSS).
"""

import hmac
import secrets

from typing import List, Optional, Sequence, Tuple

import GF256

def random(b: int) -> bytes:
    """ Helper function to create a sequence of `b` random bytes using a cryptographically secure source of randomness.
    """
    return secrets.token_bytes(b)

def share(s: bytes, n: int, t: int) -> List[Tuple[int, bytes]]:
    """ Main function for creating `n` shares of a secret `s` such that any subset of at least `t` generated shares
    can be used to recovered the secret `s`.
    """
    b = len(s)
    if not (1 <= t <= n <= 255):
        raise ValueError("Invalid secret sharing parameters, ensure that 1 <= t <= n <= 255 holds.")

    # Generate t coefficients
    c: List[bytes] = [b""] * t
    for j in range(t):
        if j == 0:
            c[j] = s
        elif 0 < j < t:
            c[j] = random(b)
        else:
            raise ValueError("Invalid range for t.")

    # evaluate polynomial for each byte to share
    f: List[GF256.Polynomial] = []
    for k in range(b):
        f_k = GF256.Polynomial([c[j][k] for j in range(t)])
        f.append(f_k)

    shares: List[Tuple[int, bytes]] = []
    for i in range(1, n + 1):
        s_i = (i, bytes(f[k](i) for k in range(b)))
        shares.append(s_i)

    return shares

def recover(shares: Sequence[Tuple[int, bytes]]) -> bytes:
    """ Main function for recovering a previously shared secret from a list of given shares.
    """
    if not (1 <= len(shares) <= 255):
        raise ValueError("Invalid number of shares provided.")

    if len({xi for xi, _ in shares}) != len(shares):
        raise ValueError("Invalid shares provided, duplicate share indices detected.")
    if not all(1 <= xi <= 255 for xi, _ in shares):
        raise ValueError("Invalid shares provided, out of range share index/indices detected.")

    b = len(shares[0][1])
    if any(len(yi) != b for _, yi in shares):
        raise ValueError("Invalid shares provided, share lengths are inconsistent.")

    # Compute the secret via Lagrange interpolation.
    s = bytearray(b)
    for xi, yi in shares:
        li = 1
        for xj, _ in shares:
            if xi != xj:
                li = GF256.multiply(li, GF256.multiply(xj, GF256.inverse(xj ^ xi)))
        for k in range(b):
            s[k] ^= GF256.multiply(yi[k], li)
    s = bytes(s)

    # return the reconstructed secret
    return s





