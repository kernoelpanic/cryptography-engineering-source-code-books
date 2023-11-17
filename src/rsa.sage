#!/usr/bin/sage
#
# Simple sage script for RSA 
# 
# See sources:
# * https://www.math.ucdavis.edu/~anne/FQ2010/Number_Theory_RSA.html
# * https://www.uam.es/otros/openmat/software/files/rsa.sage
# * https://www.hyperelliptic.org/tanja/vortraege/facthacks-29C3.pdf

def rsa_gen(bits=2^1024,_p=None,_q=None,e=None,verbose=False):
	proof = (bits <= 2^1024) # turn off time consuming proof for large values 
	if _p and _q and _p in Primes() and _q in Primes():
		p = _p
		q = _q
	else:
		p = random_prime(bits, proof=proof)
		q = random_prime(bits, proof=proof)
	assert p!=q,"p and q must be distinct numbers!"
	n = p * q
	phi_n = (p-1) * (q-1)

	if not e: 
		while True:
				e = ZZ.random_element(1,phi_n)
				if gcd(e,phi_n) == 1: break

	d = inverse_mod(e,phi_n)
	
	if verbose: print(f"n = {n}\ne = {e}\nd = {d}\np = {p}\nq = {q}")
	return n,e,d,p,q 

def rsa_enc(n,e,m):
	return pow(m,e,n)

def rsa_dec(n,d,c):
	return pow(c,d,n)

def str_to_num(s,n):
	s = str(s)
	if len(s) > floor(log(n,256)):
			print("String larger than what can be handled in one rsa invocation")
			return None
	
	num = 0
	for i in range(len(s)):
		num += ord( s[i] )*256^i  # the ^i inverts 
	return num 
	#return sum( ord( s[i] )*256 ^i for i in range(len(s)) )	

def num_to_str(num):
	num = Integer(num) 
	v = [] 
	while num != 0: 
			v.append(chr( num % 256 )) 
			num //= 256 # this replaces num by floor(num/256) 
	return ''.join(v)


