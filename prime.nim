echo "Hello World!"

const largest_num = 300_000_000

type vect  = array[ 2..largest_num, bool ]

var numbers :  vect

for i in 2..largest_num:
  numbers[i] = true

proc `$`( t : vect ) : string =
  result = "["
  for val in t:
    result.add( (if val : "T" else: "F") & " " )
  result.add "]"

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


var
  i : int = 1
  old : int

while i <= largest_num:
  old  = i
  i = findNextPrime( i + 1 )
  if 0 == i :
    break
  #echo  i
  unsetPrimes(i)
echo "Last one ", old
