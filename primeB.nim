
let doc = """
Calculate all the prime numbers smaller than largest_num.

Usage:
  prime [ --size=<n> ] [ --largestPrime=<n> ]
  prime (-h | --help) 

Options:
  --size=<n>        The size of each chunk [default: 20]
  --largestPrime=<n>   How large primes to find [default: 200]
   -h --help            Show this help
  -v --version         Show version
"""
  
import strutils
import docopt
import typetraits
import math
#import nimprof
#
type Prime = int

type
    PrimeSet = seq[ bool ]
    PrimeList = object
      list : seq[ Prime ]
      next : int

proc len( l : PrimeList ) : int = return l.next
proc high( l : PrimeList ) : int = return l.next - 1
proc low( l : PrimeList ) : int = return 0
proc last( l : PrimeList ) : int = return l.list[l.next-1]
proc first( l : PrimeList ) : int = return l.list[0]

iterator items( primes : PrimeList ) : int =
  for i in 0..primes.high:
    yield primes.list[i]

iterator pairs( primes : PrimeList ) : tuple[ index: int, prime : Prime ] =
  for i in 0..primes.high:
    #echo "Returning index ", i," with value ", l.list[i]
    yield (i, primes.list[i] )

proc add( l : var PrimeList, p : Prime ) =
  l.list[l.next] = p
  l.next.inc

proc add( l : var PrimeList, p : PrimeList ) =
  for prime in p:
    l.list[l.next] = prime
    l.next.inc 

proc newPrimeList( n : int ) :  PrimeList =
  result.list = newSeq[Prime](n)
  result.next = 0

proc `[]`( l : var PrimeList, i : Prime ) : Prime =
  return l.list[ i ]

proc `$`( l : PrimeList ) : string =
  #result = "next: " & $l.next & "   Reserved: " & $l.list.len & "\n"
  result = ""
  result.add $(l.list[ 0..(l.next - 1) ] )


proc toLinStr( primes : PrimeList ) : string =
  result = ""
  for p in primes:
    echo p

proc NlogNinv( x : float ) : float =
  result = x
  for i in 1..10:
    result = x / math.ln(result)


proc `$`( t : PrimeSet ) : string =
  result = "@["
  for val in t:
    result.add( (if val : "T" else: "F") & " " )
  result.add "]"

proc mul( vect : PrimeList ) : int =
  result = 1
  for x in vect:
    result = result * x

proc diff[T]( v : seq[T] ) : seq[ T ] =
  result = @[]
  for i in 1..v.high:
    result.add v[i] - v[i-1]


proc collectTrue( all : PrimeSet, list : var PrimeList, offset = 0 )  =
  #echo "Size in newPrimeList: ", list.list.len
  #echo "Size of bitfield: ", all.len
  for i, v in all :
    if v:
      #echo i, " @ ",  list.len
      list.add i + offset

proc collectTrue( all : PrimeSet, offset = 0) : PrimeList =
  result =  newPrimeList( int ( 1.2 * NlogNinv( all.len.float ) ) )
  collectTrue( all, result, offset )

proc calculatePrimeN( size : int ) : tuple[ nextPrime: int,  bitField: PrimeSet, primeList : PrimeList ] =

  var numbers : PrimeSet =  newSeq[bool]( size  ) 

  proc unsetPrimes( n : Prime) =
    for i in countup( n*n, numbers.len - 1, n ):
      numbers[i] = false

  proc findNextPrime( n: Prime ): Prime =
    var n : Prime = n
    while n < numbers.len:
      if numbers[n]:
        return n
      n = n + 1
    return 0

  numbers[0] = false
  numbers[1] = false

  for i in 2..<numbers.len:
    numbers[i] = true

  var
    i : int = 1
    n_prime : Prime = 3
    mul = 1
    primeList = newPrimeList( 100 )

  while true:
    i = findNextPrime( i + 1 )
    if mul * i > size:
      break
    mul = mul * i
    n_prime = n_prime + 1
    primeList.add i
    unsetPrimes(i)
    
  return ( i, numbers, primeList)

let args = docopt( doc, version = "0.0.0.0.1" )

echo args

let primeN =parseInt( $args["--size"] ) 
let largestPrime = parseInt( $args["--largestPrime"] ) 

echo "RUnning calculatePrimeN"
var  (nextPrime, bitField, defPrimes) = calculatePrimeN( primeN )
echo "nextPrim: ", nextPrime
#echo  "bitFiel: ", bitField
#echo "Collected: ", collectTrue( bitField )
echo  "defPrimes: ", defPrimes

let size = defPrimes.mul()
echo "size ", size

var defBits = bitField[0..<size ]

defBits[1] = true
for i in defPrimes:
  defBits[i] = false

#echo "defBits = ", defBits

# The number of primes we need has to be reserved
#   When number of primes is N, the largest prime is about 1.2 N log N
#   So inverting that ...

let N = math.ceil( 1.2 * NlogNinv( largestPrime.float )).int
echo "Reserving room for ", N, " primes"

var
  bits = defBits
  extraPrimes =  newPrimeList( N )
  offset = 0

#echo extraPrimes
echo "First round"
while nextPrime != 0:

  extraPrimes.add nextPrime

  for i in countup( nextPrime * nextPrime, size, 2 * nextPrime ):
    bits[i] = false

  nextPrime = nextPrime + 2

  while true:
    if nextPrime > size:
      nextPrime = 0
      break
    if bits[ nextPrime ]:
      break
    nextPrime = nextPrime + 2

#echo extraPrimes

echo "Other rounds"

var e2 : int

offset.inc size
var nextOffset = offset + size


while offset <  largestPrime:
  bits = defBits

  for e in extraPrimes:

    e2 = e * e
    if e2 >= nextOffset: break

    for i in countup( e2, nextOffset, 2 * e ):
      if i >= offset:
        bits[ i - offset ] = false

  extraPrimes.add collectTrue( bits, offset )
  #echo collectTrue( bits, offset)
  #echo extraPrimes

  offset = nextOffset
  nextOffset.inc size
  #echo nextOffset
  
#echo toLinStr( defPrimes )
#echo toLinStr( extraPrimes )
echo extraPrimes.last
echo extraPrimes.len
echo "Max diff: ", max(diff( extraPrimes.list ) )
