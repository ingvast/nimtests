
let doc = """
Calculate all the prime numbers smaller than largest_num.

Usage:
  prime [ --size=<n> ] [ --largestPrime=<n> ]
  prime (-h | --help) 

Options:
  --size=<n>        The size of each chunk [default: 20]
  --largestPrime=<n>   How large primes to find [default: 40]
  -h --help            Show this help
  -v --version         Show version
"""
  
import strutils
import docopt
import typetraits
import math

type primeSet = seq[ bool ]

proc `$`( t : primeSet ) : string =
  result = "@["
  for val in t:
    result.add( (if val : "T" else: "F") & " " )
  result.add "]"

proc mul[T]( vect : seq[ T ] ) : T =
  result = 1
  for x in  vect:
    result = result * x

proc collectTrue( all : primeSet, offset = 0 ) : seq[ int ] =
  result = @[]
  for i, v in all :
    if v : result.add i + offset

proc calculatePrimeN( size : int ) : tuple[ nextPrime: int,  bitField: primeSet, primeList : seq[ int ] ] =

  var numbers : primeSet =  newSeq[bool]( size  ) 
  echo "Reserved ", numbers.len div (1024 * 1024) , " MiB"

  proc unsetPrimes( n : int) =
    for i in countup( n*n, numbers.len - 1, n ):
      numbers[i] = false

  proc findNextPrime( n: int ): int =
    var n : int = n
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
    n_prime : int = 3
    mul = 1
    primeList : seq[ int ] = @[]

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

var  (nextPrime, bitField, defPrimes) = calculatePrimeN( primeN )
echo  defPrimes
echo nextPrime
echo  collectTrue( bitField )
echo  bitField

let size = defPrimes.mul

var defBits = bitField[0..<size ]

defBits[1] = true
for i in defPrimes:
  defBits[i] = false

echo "defBits = ", defBits

var
  bits = defBits
  extraPrimes : seq[ int ]  = @[]
  offset = 0

while nextPrime != 0:

  extraPrimes.add nextPrime

  for i in countup( nextPrime*nextPrime, size, 2 * nextPrime ):
    bits[i] = false

  nextPrime = nextPrime + 2

  while true:
    if nextPrime > size:
      nextPrime = 0
      break
    if bits[ nextPrime ]:
      break
    nextPrime = nextPrime + 2

echo extraPrimes


offset = offset + size
while offset <  largestPrime:
  bits = defBits
  echo bits
  echo "Offset = ", offset, ",  ", extraPrimes
  for e in extraPrimes:
    for i in countup( e*e, offset + size, 2 * e ):
      bits[i mod size] = false
  extraPrimes.add collectTrue( bits, offset )

  echo collectTrue( bits,offset )
  offset.inc size
  
echo extraPrimes


