
import macros

# What I want to do is replicate something looking vaugly as parse in REBOL.
#
#
type
  StringS = ref object
    val : string
  
type
  Text = object
    data : StringS
    pos : int

proc newText( data : string ) : Text =
  result = Text( pos : 0)
  result.data = StringS( val : data )

template tx( data : string ) : Text =
  newText(data)


proc inc( s1 : var Text, d : int = 1) =
  s1.pos.inc d
  if s1.pos > s1.data.val.len: 
    raise newException( Exception,  "String beyond limit")

template inc( s1 : var Text, s : string) =
  s1.inc s.len

proc `==`( s1, s2 : Text ) : bool =
  if (s1.data.val.len - s1.pos) != ( s2.data.val.len - s2.pos ): return false
  for i in 0..<(s1.data.val.len-s1.pos):
    if s1.data.val[i-s1.pos] != s2.data.val[i + s2.pos]: return false
  return true

proc `==`( ss : Text, sn : string ) : bool =
  if sn.len != ( ss.data.val.len - ss.pos ): return false
  for i in 0..<sn.len:
    if sn[i] != ss.data.val[i + ss.pos]: return false
  return true

template `==`( sn: string, ss : Text ) : bool =
  ss == sn

proc `$`( text : Text ) : string =
  return "(" & $text.pos & ") " & text.data.val[ text.pos .. text.data.val.high ]

proc `[]`( text: Text, indx : int ) : char =
  return text.data.val[ indx+text.pos ]

proc `[]`( text: Text, indxs : Slice ) : string =
  return text.data.val[ (indxs.a+text.pos) .. (indxs.b+text.pos) ]

proc intro( text : Text, str : string ) : bool =
  return str == text[ 0..<str.len ]

static:
  assert( tx"Johan" == newText( "Johan" ) )

  assert( newText("Johan") == "Johan" )
  assert( newText("Johan") == "Johan" )
  assert( newText("Johans") != "Johan" )
  assert( "Johan" == newText("Johan") )
  assert( newText("Johan")[0..2] == "Joh" )

  assert( intro( newText("Lallal"), "Lall" ))
  assert( not intro( newText("Lallal"), "Lalx" ))

type

  PatternType = enum
    Rstring, Rfunction, Rrules, Rskip, Rend, Rto, Rthru, Rcopy

  Rule = object
    case kind: RuleType
    of Rstring:
      str : string
    of Rinteger:
      count : int
    of Rslice:
      countRange: Slice[int]
    of Rrules:
      rules : ref Rules
    of Rfunction:
      fun : string
    of Rskip:

  Rules = object
    list : seq[Rule] 

proc rs( str: string ) : Rule =
  return Rule( kind = Rstring, str = str )

proc skip() = return Rule( kind = Rskip )

#
# Start with just implementing something simple
let space = " "
let rule = newRule( @[ "Nim", space, "is", space, "wonderful.", space ] )
echo rule

proc parse( rule : Rules, text : var Text ) : bool =
  for r in rule:
    if not text.intro( r ): return false
    text.inc r
  return true

var
  t1 = tx"Nim is wonderful. "
  t2 = tx"Nim will not work"

echo t1, parse( rule, t1 )
echo t2, parse( rule, t2 )
