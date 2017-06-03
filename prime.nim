
let doc = """
Calculate all the prime numbers smaller than largest_num.

Usage:
  prime <primeN>
  prime (-h | --help) 

Options:
  -h --help     Show this help
  -v --version  Show version
"""
  
import strutils
import docopt
import typetraits
import math

proc `$`( t : seq[ bool ] ) : string =
  result = "@["
  for val in t:
    result.add( (if val : "T" else: "F") & " " )
  result.add "]"

proc calculatePrimeN( ct_prime : int ) : int =

  var numbers  =  newSeq[ bool ]( int( ln(float(ct_prime)) * ct_prime.float * 1.2 ) )

  proc unsetPrimes( n : int) =
    for i in countup( n*n, numbers.len - 1, n * 2 ):
      numbers[i] = false

  proc findNextPrime( n: int ): int =
    var n = n
    while n < numbers.len:
      if numbers[n]:
        return n
      n = n + 1
    return 0


  for i in 0..<numbers.len:
    numbers[i] = true

  var
    i : int = 1
    old : int
    n_prime : int = 2

  while n_prime <= ct_prime:
    old  = i
    i = findNextPrime( i + 1 )
    #echo n_prime, " ", i
    if 0 == i :
      break
    n_prime = n_prime + 1
    unsetPrimes(i)
  #echo "Last one ", old
  #echo  n_prime, ", ", old, ", ", float(old) / ( float( n_prime) * math.ln(float( n_prime ) ) )
  return i

let args = docopt( doc, version = "0.0.0.0.1" )

let primeN = parseInt( $args["<primeN>"] )

echo primeN, "\t", calculatePrimeN( primeN )

