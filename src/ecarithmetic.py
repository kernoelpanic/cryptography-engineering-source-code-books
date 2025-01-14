#!/usr/bin/python
# Basic EC arithmetic illustration in python:
# No optimizations, not constant time,
# only rudimentary point at infinity handling

def add_points(P1, P2, a, p):
    if P1 is None or P2 is None:
        # P + O = P
        # check for the zero point/point at infinity
        return P1 or P2
    if P1 is None and P2 is None:
        # O + O = O
        return None
    x1, y1 = P1
    x2, y2 = P2

    if x1 == x2:
        return double_point(P1,a,p)
    m = ( (y1 - y2) * pow(x1 - x2,-1,p) ) % p
    xr = ( m**2 - x1 - x2 ) % p
    yr = ( m * (x1 - xr) - y1 ) % p
    return (xr, yr)

def double_point(P,a,p):
    if P is None:
        return None
    xp, yp = P
    if yp == 0:
        # Point at infinity (vertical tangent line)
        return None
    m =  ( (3 * xp ** 2 + a) * pow(2 * yp,-1,p) ) % p
    xr =  ( m**2 - 2*xp ) % p
    yr =  ( m * (xp - xr) - yp ) % p
    return (xr, yr)

def double_and_add(k, P, a, p):
    result = None # Initialize with point at infinity
    addend = P
    for b in [int(bit) for bit in bin(int(k))[2:][::-1]]: # from LSB to MSB
        if b == 1:
            result = add_points(result, addend, a=a, p=p)
        addend = double_point(addend, a=a, p=p)
    return result

