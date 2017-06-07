
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

  var numbers  =  newSeq[ bool ]( int( ln(float(ct_prime)) * ct_prime.float * 1.2 / 2 ) )
  echo "Reserved ", numbers.len div (1024 * 1024) , " MiB"
  # index value
  # 0     1
  # 1     3
  # 2     5
  # 3     7
  
  #(2*n+1)*(2*n+1) div 2  = 2*n(n + 1)
  # value  N*N + 2 * N = N*N + 2* ( 2n+1) = N*N + 4*n + 2
  proc unsetPrimes( n : int)  {. inline .} =
    for i in countup( 2*n*(n+1), numbers.len - 1, 2*n + 1):
      numbers[i] = false

  proc findNextPrime( n: int ): int  {. inline .} =
    var n : int = n
    while n < numbers.len:
      if numbers[n]:
        return n
      n = n + 1
    return 0

  for i in 0..<numbers.len:
    numbers[i] = true

  var
    i : int = 0
    n_prime : int = 3

  while n_prime <= ct_prime:
    i = findNextPrime( i + 1 )
    #echo n_prime, " ", i * 2 + 1
    n_prime = n_prime + 1
    unsetPrimes(i)
    #echo numbers
  return i*2+1

let args = docopt( doc, version = "0.0.0.0.1" )

let primeN = parseInt( $args["<primeN>"] )

echo primeN, "\t", calculatePrimeN( primeN )

