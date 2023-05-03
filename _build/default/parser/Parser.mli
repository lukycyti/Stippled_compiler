
(* The type of tokens. *)

type token = 
  | Y_ACCESSOR
  | X_ACCESSOR
  | TO
  | TAIL
  | SUB
  | STEP
  | SIN
  | SEMICOLON
  | R_SQ_BRK
  | R_PAR
  | RED_ACCESSOR
  | PRINT
  | POSITION_ACCESSOR
  | POINT
  | PI
  | OR
  | NOT
  | NE
  | MUL
  | MOD
  | L_SQ_BRK
  | L_PAR
  | LT
  | LIST
  | LE
  | INT_TYPE
  | INT of (int)
  | IN
  | IF
  | IDENTIFIER of (string)
  | HEAD
  | GT
  | GREEN_ACCESSOR
  | GE
  | FROM
  | FOREACH
  | FOR
  | FLOOR
  | FLOAT_TYPE
  | FLOAT_OF_INT
  | FLOAT of (float)
  | EQ
  | EOF
  | END
  | ELSE
  | DRAW
  | DOT
  | DIV
  | DEF
  | COS
  | COPY
  | COMMA
  | COLOR_ACCESSOR
  | BOOL_TYPE
  | BOOL of (bool)
  | BLUE_ACCESSOR
  | BEGIN
  | AND
  | ADD

(* This exception is raised by the monolithic API functions. *)

exception Error

(* The monolithic API. *)

val main: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (Ast.program)

module MenhirInterpreter : sig
  
  (* The incremental API. *)
  
  include MenhirLib.IncrementalEngine.INCREMENTAL_ENGINE
    with type token = token
  
  (* The indexed type of terminal symbols. *)
  
  type _ terminal = 
    | T_error : unit terminal
    | T_Y_ACCESSOR : unit terminal
    | T_X_ACCESSOR : unit terminal
    | T_TO : unit terminal
    | T_TAIL : unit terminal
    | T_SUB : unit terminal
    | T_STEP : unit terminal
    | T_SIN : unit terminal
    | T_SEMICOLON : unit terminal
    | T_R_SQ_BRK : unit terminal
    | T_R_PAR : unit terminal
    | T_RED_ACCESSOR : unit terminal
    | T_PRINT : unit terminal
    | T_POSITION_ACCESSOR : unit terminal
    | T_POINT : unit terminal
    | T_PI : unit terminal
    | T_OR : unit terminal
    | T_NOT : unit terminal
    | T_NE : unit terminal
    | T_MUL : unit terminal
    | T_MOD : unit terminal
    | T_L_SQ_BRK : unit terminal
    | T_L_PAR : unit terminal
    | T_LT : unit terminal
    | T_LIST : unit terminal
    | T_LE : unit terminal
    | T_INT_TYPE : unit terminal
    | T_INT : (int) terminal
    | T_IN : unit terminal
    | T_IF : unit terminal
    | T_IDENTIFIER : (string) terminal
    | T_HEAD : unit terminal
    | T_GT : unit terminal
    | T_GREEN_ACCESSOR : unit terminal
    | T_GE : unit terminal
    | T_FROM : unit terminal
    | T_FOREACH : unit terminal
    | T_FOR : unit terminal
    | T_FLOOR : unit terminal
    | T_FLOAT_TYPE : unit terminal
    | T_FLOAT_OF_INT : unit terminal
    | T_FLOAT : (float) terminal
    | T_EQ : unit terminal
    | T_EOF : unit terminal
    | T_END : unit terminal
    | T_ELSE : unit terminal
    | T_DRAW : unit terminal
    | T_DOT : unit terminal
    | T_DIV : unit terminal
    | T_DEF : unit terminal
    | T_COS : unit terminal
    | T_COPY : unit terminal
    | T_COMMA : unit terminal
    | T_COLOR_ACCESSOR : unit terminal
    | T_BOOL_TYPE : unit terminal
    | T_BOOL : (bool) terminal
    | T_BLUE_ACCESSOR : unit terminal
    | T_BEGIN : unit terminal
    | T_AND : unit terminal
    | T_ADD : unit terminal
  
  (* The indexed type of nonterminal symbols. *)
  
  type _ nonterminal = 
    | N_variable_expression : (Ast.expression) nonterminal
    | N_simple_data_type_declaration : (Ast.type_expr) nonterminal
    | N_main : (Ast.program) nonterminal
    | N_list_instanciation : (Ast.expression) nonterminal
    | N_instruction_list : (Ast.statement list) nonterminal
    | N_instruction_if : (Ast.statement) nonterminal
    | N_instruction_foreach : (Ast.statement) nonterminal
    | N_instruction_for : (Ast.statement) nonterminal
    | N_instruction_block : (Ast.statement) nonterminal
    | N_instruction : (Ast.statement) nonterminal
    | N_declaration_lines : (Ast.argument list) nonterminal
    | N_declaration_line : (Ast.argument) nonterminal
    | N_declaration_block : (Ast.argument list) nonterminal
    | N_content_list_instanciation : (Ast.expression list) nonterminal
  
  (* The inspection API. *)
  
  include MenhirLib.IncrementalEngine.INSPECTION
    with type 'a lr1state := 'a lr1state
    with type production := production
    with type 'a terminal := 'a terminal
    with type 'a nonterminal := 'a nonterminal
    with type 'a env := 'a env
  
end

(* The entry point(s) to the incremental API. *)

module Incremental : sig
  
  val main: Lexing.position -> (Ast.program) MenhirInterpreter.checkpoint
  
end
