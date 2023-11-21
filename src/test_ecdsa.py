""" pytest script for ecdsa.sage

This script imports all from sagemath
and loads ecdsa.sage to test it using pytest

$ python3 -m pytest test_ecdsa.p
"""
import pytest
from sage.all import *

def read_test_cases_from_txt(file_path):
    test_cases = []
    current_test_case = {}

    with open(file_path, 'r') as file:
        for line in file:
            line = line.strip()
            if line.startswith("k ="):
                current_test_case['k'] = int(line.split('=')[1].strip(),10)
            elif line.startswith("x ="):
                current_test_case['x'] = int(line.split('=')[1].strip(),16)
            elif line.startswith("y ="):
                current_test_case['y'] = int(line.split('=')[1].strip(),16)
                test_cases.append((
                    current_test_case['k'],
                    current_test_case['x'],
                    current_test_case['y']
                ))
                current_test_case = {}  # Reset for the next test case
    return test_cases

load("./ecdsa.sage")

def test_sagemath_import():
    F=GF(5)
    assert len(GF(5).list()) == 5,"Sage math import did not work properly"

def test_ecdsa_sign_and_verify():
    # test sign and verify
    (Q_A,d_A) = ecdsa_keygen(verbose=False)
    message_hash = ecdsa_hashtoint("some string")
    (r,s) = ecdsa_sign(d_A,message_hash,verbose=False)
    assert True == ecdsa_verify(Q_A, message_hash, r, s, verbose=False)
    message_hash = ecdsa_hashtoint("other message")
    assert False == ecdsa_verify(Q_A, message_hash, r, s, verbose=False)

def test_ecdsa_sign():
    # a test vector from https://crypto.stackexchange.com/questions/41316/complete-set-of-test-vectors-for-ecdsa-secp256k1
    d = 0xebb2c082fd7727890a28ac82f6bdf97bad8de9f5d7c9028692de1a255cad3e0f
    k = 0x49a0d7b786ec9cde0d0721d72804befd06571c974b191efb42ecf322ba9ddd9a
    sighash = 0x4b688df40bcedbe641ddb16ff0a1842d9c67ea1c3bf63f3e0471baa664531d1a
    r_expected = 0x241097efbf8b63bf145c8961dbdf10c310efbb3b2676bbc0f8b08505c9e2f795
    s_expected = 0x021006b7838609339e8b415a7f9acb1b661828131aef1ecbc7955dfb01f3ca0e

    (r,s) = ecdsa_sign(d,sighash,nonce=k,verbose=False)
    assert (r,s) == (r_expected,s_expected),"Wrong signature"

def test_ecdsa_verify():
    # a test vector from https://crypto.stackexchange.com/questions/41316/complete-set-of-test-vectors-for-ecdsa-secp256k1
    sighash = 0x4b688df40bcedbe641ddb16ff0a1842d9c67ea1c3bf63f3e0471baa664531d1a
    r = 0x241097efbf8b63bf145c8961dbdf10c310efbb3b2676bbc0f8b08505c9e2f795
    s = 0x021006b7838609339e8b415a7f9acb1b661828131aef1ecbc7955dfb01f3ca0e
    x = 0x779dd197a5df977ed2cf6cb31d82d43328b790dc6b3b7d4437a427bd5847dfcd
    y = 0xe94b724a555b6d017bb7607c3e3281daf5b1699d6ef4124975c9237b917d426f
    Q_A = E((x,y))
    assert ecdsa_verify(Q_A, sighash, r, s, verbose=False)

def test_secp256k1_trace():
    assert p+1 - E.order() == E.trace_of_frobenius() == 432420386565659656852420866390673177327,"Wrong trace for secp256k1"

@pytest.mark.parametrize("k, x, y", read_test_cases_from_txt("./test_cases_secp256k1.txt"))
def test_secp256k1_mul(k, x, y):
    #k = 2
    #x = 0xC6047F9441ED7D6D3045406E95C07CD85C778E4B8CEF3CA7ABAC09B95C709EE5
    #y = 0x1AE168FEA63DC339A3C58419466CEAEEF7F632653266D0E1236431A950CFE52A

    P = k*G
    (P_x,P_y)=P.xy()
    assert x == P_x and y == P_y,"k*G does not match expected (x,y)"


