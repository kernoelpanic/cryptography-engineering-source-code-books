""" Implementation of the Shamir Secret Sharing for Mnemonic Phrases (SSS).
"""

import secrets


from typing import List, Optional, Sequence, Tuple

import hashlib
# Create global a SHAKE256 hash object upon import or reload 
shake = hashlib.shake_256()
SEEDED = False

def get_random(b: int) -> bytes:
    """ Helper function to create a sequence of `b` random bytes using a cryptographically secure source of randomness.
    """
    return secrets.token_bytes(b)

def get_pseudorandom(b: int,seed: bytes=None) -> bytes:
    global SEEDED, shake
    if not SEEDED:
        # Feed the seed as data to the SHAKE object only once
        SEEDED = True
        shake.update(seed)

    # Generate a pseudorandom sequence of b bytes
    pseudorandom_bytes = shake.digest(b)
    
    # Use the generated sequence to update SHAKE object 
    shake.update(pseudorandom_bytes)
    #print(f"pseudorandom_bytes = {pseudorandom_bytes.hex()} ")
    return pseudorandom_bytes

def eval_poly(coefficients: List[bytes], x, prime):
    """ Evaluate polynomial of the finite field represented by the prime given. 
    """
    t = len(coefficients)
    if t == 0:
        return 0 
    y = int.from_bytes(coefficients[0],"big")
    xk=x
    for j in range(1,t):
        y = (y + int.from_bytes(coefficients[j],"big") * xk) % prime
        xk = (xk * x) % prime
    
    return y 


def share(s: bytes, n: int, t: int, prime: int, pseudo_random_seed: bytes=None) -> List[Tuple[int, bytes]]:
    """ Main function for creating `n` shares of a secret `s` such that any subset of at least `t` generated shares
    can be used to recovered the secret `s`.
    """
    b = len(s)
    if not (1 <= t <= n):
        raise ValueError("Invalid secret sharing parameters, ensure that 1 <= t <= n holds.")
    if b*8 > prime.bit_length():
        raise ValueError("Secret too large for chosen finite field prime.")
    if n > prime:
        raise ValueError("Number of shares to large for chosen finite field prime.")

    # Generate t coefficients
    c: List[bytes] = [b""] * t
    for j in range(t):
        if j == 0:
            c[j] = s
        else:
            if pseudo_random_seed:
                c[j] = get_pseudorandom(b,pseudo_random_seed)
            else:
                c[j] = get_random(b)

    # Evaluate polynomial and generate shares 
    shares: List[Tuple[int, bytes]] = []
    for i in range(1, n + 1):
        s_i = (i, eval_poly(c,i,prime))
        shares.append(s_i)

    return shares


def recover(shares: Sequence[Tuple[int, bytes]], prime: int) -> bytes:
    """ Function for recovering a previously shared secret from a list of given shares.
    """
    if not (1 <= len(shares)):
        raise ValueError("Invalid number of shares provided.")

    if len({xi for xi, _ in shares}) != len(shares):
        raise ValueError("Invalid shares provided, duplicate share indices detected.")
    if not all(1 <= xi for xi, _ in shares):
        raise ValueError("Invalid shares provided, out of range share index/indices detected.")

    # Compute the secret via Lagrange interpolation
    s = 0
    for xi, yi in shares:
        li = 1
        for xj, _ in shares:
            if xi != xj:
                # ( x_j / (x_j - x_i) ) * ...
                li_current = (xj * pow((xj - xi),-1,prime)) % prime
                li = (li * li_current) % prime
        s = (s + yi * li) % prime

    # return the reconstructed secret
    return s 





