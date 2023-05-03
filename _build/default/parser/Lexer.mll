{
    open Parser
    exception Error of string
}

let digit = ['0'-'9']
let alphanum = ['a'-'z' 'A'-'Z' '0'-'9' '\'' '_']

rule token = parse
    | eof               { EOF }
    | "//" [^ '\n']* '\n' {Lexing.new_line lexbuf; token lexbuf}
    | "/*"              {commentary lexbuf}
    | [' ' '\t' '\r']   {token lexbuf}
    | '\n'              { Lexing.new_line lexbuf ; token lexbuf }
    | "+"               { ADD }
    | "-"               { SUB }
    | "*"               { MUL }
    | "/"               { DIV }
    | "%"               { MOD }
    | "And"             { AND }
    | "Or"              { OR }
    | "Bool"            { BOOL_TYPE }
    | "="               { EQ }
    | "<>"              { NE }
    | "<"               { LT }
    | ">"               { GT }
    | "<="              { LE }
    | ">="              { GE }
    | "::"              { DEF }
    | "."               { DOT }
    | ";"               { SEMICOLON }
    | ","               { COMMA }
    | "["               { L_SQ_BRK }
    | "]"               { R_SQ_BRK }
    | "("               { L_PAR }
    | ")"               { R_PAR }
    | "Float_of_int"    { FLOAT_OF_INT } 
    | "Not"             { NOT }
    | "Head"            { HEAD }
    | "Tail"            { TAIL }
    | "Floor"           { FLOOR }
    | "Cos"             { COS } 
    | "Sin"             { SIN } 
    | "Color"           { COLOR_ACCESSOR } 
    | "Pos"             { POSITION_ACCESSOR } 
    | "X"               { X_ACCESSOR } 
    | "Y"               { Y_ACCESSOR } 
    | "Red"             { RED_ACCESSOR } 
    | "Green"           { GREEN_ACCESSOR } 
    | "Blue"            { BLUE_ACCESSOR } 
    | "Begin"           { BEGIN } 
    | "End"             { END } 
    | "Copy"            { COPY } 
    | "Draw"            { DRAW } 
    | "If"              { IF } 
    | "Else"            { ELSE } 
    | "For"             { FOR } 
    | "From"            { FROM } 
    | "To"              { TO }
    | "Foreach"         { FOREACH } 
    | "In"              { IN }
    | "List"            { LIST }
    | "Point"           { POINT }
    | "Print"           { PRINT }
    | "Step"            { STEP }    
    | "True"            { BOOL(true) }
    | "False"           { BOOL(false) }
    | "Int"             { INT_TYPE }
    | "Float"           { FLOAT_TYPE }
    | "Pi"              { PI }


    |['a'-'z'] (alphanum)* as s  { IDENTIFIER(s) }
    | (digit)* "." (digit)* as s {FLOAT(try float_of_string s with Failure _ -> raise (Error(s)) )}
    | (digit)+ as s     { INT(try int_of_string s with Failure _ ->(let pos = Lexing.lexeme_start_p lexbuf in raise (Error(Format.sprintf "Line %d, char %d ,Read: '%s'. It is not a valid integer" pos.pos_lnum (pos.pos_cnum - pos.pos_bol +1) s)) ))}

    | _ as s            { let pos = Lexing.lexeme_start_p lexbuf in raise (Error(Format.sprintf "Line %d, char %d ,Read: '%c'. It is not an acceptable character" pos.pos_lnum (pos.pos_cnum - pos.pos_bol +1) s)) }

    and commentary = parse
    | '\n'      {Lexing.new_line lexbuf; commentary lexbuf}
    | "*/"      { token lexbuf }
    | _ { commentary lexbuf }
