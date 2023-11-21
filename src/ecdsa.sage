#!/usr/bin/sage
# inspired by
# https://asecuritysite.com/sage/sage_04

import hashlib
import secrets 

# Secp256k1 
# As specified in https://www.secg.org/sec2-v2.pdf
# define curve to use (beware of global parameters!)
p  = 2**256-2**32-2**9 -2**8 - 2**7 - 2**6 - 2**4 - 1
Fp = FiniteField(p)
a  = 0
b  = 7
E  = EllipticCurve(Fp, [a, b])
G  = E((55066263022277343669578718895168534326250603453777594175500187360389116729240, 
32670510020758816978083085130507043184471273380659243275938904335757337482424))
n  = 115792089237316195423570985008687907852837564279074904382605163141518161494337
h  = 1
Fn = FiniteField(n)

def ecdsa_hashtoint(msg):
  """ Hash value to SHA256 sum intepreted as integer """
  return Integer('0x' + hashlib.sha256(msg.encode()).hexdigest())

def ecdsa_keygen(verbose=False):
  """ generate random private key and compute ECDSA public key """
  d = secrets.randbelow(int(n))
  Q = d * G
  if verbose: print(f"d   = {hex(d)}\nQ_x = {hex(Q.xy()[0])}\nQ_y = {hex(Q.xy()[1])}")
  return (Q, d)

def ecdsa_sign(d, m, nonce=None, verbose=False):
  r = 0
  s = 0
  while s == 0:
    while r == 0:
      if nonce:
        k = nonce
      else:
        k = secrets.randbelow(int(n))
      R = k * G
      (x1, y1) = R.xy()
      r = Fn(x1)
    e = Fn(m) # assume hashed message
    #e = ecdsa_hashtoint(m)
    s = Fn(k) ^ (-1) * (Fn(e) + Fn(d) * Fn(r))
  if verbose: print(f"k   = {hex(k)}\nG_x = {hex(G.xy()[0])}\nG_y = {hex(G.xy()[1])}\ne   = {hex(e)}\nr   = {hex(r)}\ns   = {hex(s)}")
  return (r, s)

def ecdsa_verify(Q, m, r, s, verbose=False):
  #e = ecdsa_hashtoint(m)
  e = Fn(m) # assume hashed message
  w = Fn(s) ^ (-1)
  u1 = (e * w)
  u2 = (r * w)
  P1 = Integer(u1) * G
  P2 = Integer(u2) * Q
  P = P1 + P2
  (x, y) = P.xy()
  p_x = Fn(x)
  if verbose: print(f"w   = {hex(w)}\ne   = {hex(e)}\nu1  = {hex(u1)}\nu2  = {hex(u2)}\nr   = {hex(r)}\np_x = {hex(p_x)}")
  return p_x == r


