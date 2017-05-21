
let doc = """
Calculate all the prime numbers smaller than largest_num.

Usage:
  prime <largest_num>
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

proc calculateLastPrime( largest_num : int ) : int =

  var numbers  =  newSeq[ bool ]( largest_num + 1)

  proc unsetPrimes( n : int) =
    for i in countup( n*2, largest_num, n ):
      numbers[i] = false

  proc findNextPrime( n: int ): int =
    var n = n
    while n < largest_num:
      if numbers[n]:
        return n
      n = n + 1
    return 0


  for i in 0..largest_num:
    numbers[i] = true

  var
    i : int = 1
    old : int
    n_prime : int = 2



  while i <= largest_num:
    old  = i
    i = findNextPrime( i + 1 )
    if 0 == i :
      break
    #echo  n_prime, ", ", i, ", ", float(i) / ( float( n_prime) * math.ln(float( n_prime ) ) )
    n_prime = n_prime + 1
    unsetPrimes(i)
  echo "Last one ", old
  echo  n_prime, ", ", old, ", ", float(old) / ( float( n_prime) * math.ln(float( n_prime ) ) )
  return old

let args = docopt( doc, version = "0.0.0.0.1" )

#const largest_num : int = parseInt( "234" )
let largest_num = parseInt( $args["<largest_num>"] )

echo largest_num

echo calculateLastPrime( largest_num )

