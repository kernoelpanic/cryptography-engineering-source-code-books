import ecarithmetic as eca
import secp256k1params 

def test_add_points():
    P1 = (9, 16)
    P2 = (26, 6)
    p = 31
    a = -1
    Q = eca.add_points(P1,P2,a=a,p=p)
    assert (6,26) == Q

def test_double_points():
    P= (1, 1)
    p = 31
    a = -1
    Q = eca.double_point(P,a=a,p=p)
    assert (30,1) == Q

def test_doube_and_add():
    P = (5, 11)
    p = 31
    a = -1
    Q = eca.double_and_add(3, P, a=a, p=p )
    assert (18,7) == Q

def test_doube_and_add_2():
    P = (26, 6)
    p = 31
    a = -1
    Q = eca.double_and_add(12, P, a=a, p=p )
    assert (2,21) == Q

def test_secp256k1_double_and_add():
    P = secp256k1params.G
    p = secp256k1params.p
    a = secp256k1params.a
    k = 104180048334815325830625441518578326979476797852517177973225433558381925820558
    Q = eca.double_and_add(k, P, a=a, p=p )
    R = (2218404120244963262942688441315034122895494739329766368892963870531381984674,
    95623813759907722199505071633719440492035181416518679137887147878608899256700)
    assert R == Q

