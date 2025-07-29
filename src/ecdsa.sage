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

def ecdsa_recover(p, a, b, G, n, h, r, s, m, verbose=False):
	if not all(1 < x < n for x in (r,s)):
		if verbose: print(f"r or s not within [1,n-1]")
		return None
	e = Integer(m) % n  # assume hashed message 
	r = Integer(r)
	s = Integer(s)	
	
	Q_list = list()
	
	for j in [0,1]:  # range(0,h+1):
  	# since for secp256k1 h (cofactor) is only 1, we have only two options here:
		# x = r 
		# x = r + n
		if verbose: print(f"j (recoverID) = {j}")
		# Compute x: 
		x = (r + j * n) % p 
		if verbose: print(f"x = {x}")
		
		# Compute y: 
		# Do prevent the runtime from generic Tonelli-Shanks algorithm
		# we can use a short cut since $ p \equiv 3 mod 4 $ in secp256k1 
		# $ y^2 = x^3 + 7 \mod p $
		# $ y = (x^3 + 7)^{(p+1)/4} \mod p $ 
		alpha = (x**3 + 7) % p 
		y = power_mod( alpha, ( (p + 1) // 4), p)
		if verbose: print(f"y = {y}")
		
		# Try with R and -R:
		for i in [0,1]:
			if i == 1: 
				y = p - y # try other y coordinate
			if E.is_on_curve(Fp(x),Fp(y)):
				R = E(Fp(x),Fp(y))
				if verbose: print(f"R = {R.xy()}")
			
				# Compute $ r^-1 \mod p $:
				r_inv = inverse_mod(r, n)
				if verbose: print(f"r^-1 = {r_inv}")
				
				# Compute Q:
				#sR = (s * R) 
				#eG = (e * G) 
				#Q = r_inv * (sR - eG)	
				
				u_1 = - e * r_inv % n
				u_2 = s * r_inv % n
				Q = u_1 * G + u_2 * R
				
				if verbose: print(f"Q = {Q.xy()}")
				Q_list.append(Q)
	
	return Q_list

