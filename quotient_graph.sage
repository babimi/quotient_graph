# Programs to study the quotient graph X^s_\ell.

def is_reduced(w):
    """Is w a reduced word?"""
    return all(w[i] != -w[i+1] for i in range(len(w) - 1))

def reduced_words(r, n):
    """Generate the reduced words of length r in F_n."""
    if r == 0:
        yield tuple([])
    elif r == 1:
        for a in range(1, n + 1):
            for e in [1, -1]:
                yield (e * a,)
    else:
        for w0 in reduced_words(r - 1, n):
            for a in range(1, n + 1):
                for e in [1, -1]:
                    w = w0 + (e * a,)
                    if is_reduced(w):
                        yield w

def reduce(w):
    """Return the equivalent reduced word."""
    w = list(w).copy()
    i = 0
    while i < len(w) - 1:
        if w[i] != -w[i+1]:
            i += 1
        else:
            w.pop(i)
            w.pop(i)
            if i > 0:
                i -= 1
    return tuple(w)

def inverse(w):
    """Return the inverse of w."""
    return [-w[k] for k in range(len(w)-1, -1, -1)]

def prod(v, s):
    """Return the product of v and s."""
    return reduce(tuple(v) + tuple(s))

def quotient_graph(s, r, n):
    """Return the quotient graph of F_n with generator s and radius r."""
    V = []
    for i in range(r + 1):
        V += list(reduced_words(i, n))
 
    E = []
    for i in range(r):
        for v in reduced_words(i, n):
             E.append( (v, prod(v, s)[:r]) ) 
    for v in reduced_words(r, n):
        for i in range(len(s)):
            if s[i] == -v[-1]:
                w = prod(v, s[i:])[:r]
                E.append( (v, w))
    return Graph([V, E], multiedges=True)

def normalize(w):
    """Normalize w so that the first appearances of the letters are in sorted order,
    and the first appearance of each letter is positive."""
    # permute the letters to sort their first appearances
    perm = []
    for a in w:
        if abs(a) not in perm:
            perm.append(abs(a))
    wp = [sgn(a) * (perm.index(abs(a)) + 1) for a in w]
    # make the first appearance of each letter positive
    for k in range(len(wp)):
        if (wp[k] < 0) and (abs(wp[k]) not in wp[:k]):
            x = wp[k]
            wp = [-a if a in [x, -x] else a for a in wp]
    return tuple(wp)

def cyclic_perms(w):
    """List the (normalizations of) the words that can be obtained by cyclic permutations,
    or taking the inverse of the word."""
    rotates = ([normalize(w[k:] + w[:k]) for k in range(len(w))] # cyclic shifts
                    + [normalize(inverse(w[k:] + w[:k])) for k in range(len(w))]) # also inverses
    nodups = []
    for x in rotates:
        if x not in nodups:
            nodups.append(x)
    return nodups

def min_words(r, n):
    """To reduce duplication, only take the minimal word in each equivalence class."""
    for w in reduced_words(r, n):
        if w == min(cyclic_perms(w)):
            yield w

# The following script prints (minimal) words of length 2n for which X^s_3 is a cycle.
# Some of them may be in the same orbit under the automorphism group.

for n in [2, 3]:
    for s in min_words(2*n, n):
        if quotient_graph(s, 1, n).is_cycle():
            print(s)
    print()

# output:
# (1, 1, 2, 2)
# (1, 2, -1, 2)
# (1, 2, -1, -2)
# 
# (1, 1, 2, 2, 3, 3)
# (1, 1, 2, 3, -2, 3)
# (1, 1, 2, 3, -2, -3)
# (1, 1, 2, 3, 3, 2)
# (1, 2, 1, 3, 2, 3)
# (1, 2, -1, 3, 2, 3)
# (1, 2, -1, 3, -2, 3)
# (1, 2, 3, -1, -2, 3)
