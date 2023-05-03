%{
    open Ast

    (*Le parseur doit générer des Ast.program.
    Pour les annotation, il vous suffit de créer l’annotation avec [Annotation.create $loc] qui sera ce qu’il vous faut dans tous les cas : $loc est un paramètre qui correspond aux positions délimitant la chaîne de caractères parsée par la règle où il est utilisé, ce qui est exactement ce qu’il faut mettre dans l’annotation.*)
%}

%token EOF
%token ADD
%token SUB
%token MUL
%token DIV 
%token MOD
%token AND
%token OR
%token EQ
%token NE
%token LT
%token GT
%token LE
%token GE
%token DEF
%token DOT
%token COMMA
%token SEMICOLON
%token L_SQ_BRK
%token R_SQ_BRK
%token L_PAR
%token R_PAR
%token FLOAT_OF_INT
%token NOT
%token HEAD
%token TAIL
%token FLOOR
%token COS
%token SIN
%token COLOR_ACCESSOR
%token POSITION_ACCESSOR
%token X_ACCESSOR
%token Y_ACCESSOR
%token RED_ACCESSOR
%token GREEN_ACCESSOR
%token BLUE_ACCESSOR
%token BEGIN
%token END
%token COPY
%token DRAW
%token IF
%token ELSE
%token FOR
%token FROM 
%token TO
%token FOREACH
%token IN
%token LIST
%token POINT 
%token PRINT
%token STEP
%token INT_TYPE
%token FLOAT_TYPE
%token PI
%token BOOL_TYPE
%token <string> IDENTIFIER
%token <int> INT
%token <float> FLOAT
%token <bool> BOOL

%left IF
%right ELSE
%left AND OR
%left EQ NE LT GT LE GE
%left ADD SUB 
%left MUL DIV MOD 
%nonassoc NOT
%left DOT
%left DEF

%start <program> main
%%

main:
| EOF { Program([],Block([],Annotation.create $loc)) }
| b = declaration_block i = instruction_block EOF {Program(b, i) }
| i = instruction_block EOF {Program([], i)}
| e = variable_expression EOF { Program([], Print(e, Annotation.create $loc))}

// DECLARATION BLOCK
declaration_block:
| LT d = declaration_lines GT {d}
| LT GT {[]}

declaration_lines:
| d = declaration_line SEMICOLON d2 = declaration_lines {d::d2}
| dl = declaration_line {[dl]}

declaration_line: 
| s = simple_data_type_declaration L_PAR name = IDENTIFIER R_PAR {Argument(name, s, Annotation.create $loc)}

instruction_block:
| BEGIN e = instruction_list END {Block(e, Annotation.create $loc)}
| BEGIN END {Nop}


instruction_list:
| i = instruction SEMICOLON l = instruction_list {i::l}
| i = instruction {[i]}

instruction: 
| COPY L_PAR e1 = variable_expression COMMA e2 = variable_expression R_PAR {Assignment(e1,e2,Annotation.create $loc )}
| DRAW L_PAR e1 = variable_expression R_PAR {Draw(e1,Annotation.create $loc)}
| PRINT L_PAR e1 = variable_expression R_PAR {Print(e1,Annotation.create $loc)}
| i = simple_data_type_declaration L_PAR name = IDENTIFIER R_PAR {Variable_declaration(name, i, Annotation.create $loc)}
| i = instruction_block {i}
| i = instruction_for {i}
| i = instruction_if {i}
| i = instruction_foreach {i}

instruction_foreach: 
| FOREACH e1 = IDENTIFIER IN e2 = variable_expression i = instruction {Foreach(e1,e2,i,Annotation.create $loc)}

instruction_for: 
| FOR s = IDENTIFIER FROM e1 = variable_expression TO e2 = variable_expression STEP e3 = variable_expression i = instruction {For(s,e1,e2,e3,i,Annotation.create $loc)}

instruction_if: 
| IF e = variable_expression i1 = instruction {IfThenElse(e, i1,Nop , Annotation.create $loc)}
| IF e = variable_expression i1 = instruction ELSE i2 = instruction {IfThenElse(e, i1, i2, Annotation.create $loc)} 

variable_expression:
| vc = variable_content {vc}
| POSITION_ACCESSOR L_PAR e1 = variable_expression COMMA e2 = variable_expression R_PAR  {Pos(e1,e2,Annotation.create $loc)}
| COLOR_ACCESSOR L_PAR e1 = variable_expression COMMA e2 = variable_expression COMMA e3 = variable_expression R_PAR {Color(e1,e2,e3,Annotation.create $loc)}
| POINT L_PAR e1 = variable_expression COMMA e2 = variable_expression R_PAR  {Point(e1, e2, Annotation.create $loc)}
| e1 = variable_expression op = binary_operator e2 = variable_expression {Binary_operator(op, e1 ,e2, Annotation.create $loc)}
| op = unary_operator e1 = variable_expression {Unary_operator(op, e1, Annotation.create $loc)} %prec NOT
| e1 = variable_expression DOT field = field_accessor {Field_accessor(field, e1, Annotation.create $loc)}
| l = list_instanciation {l}
| e1 = variable_expression DEF e2 = variable_expression {Cons(e1,e2,Annotation.create $loc)}
| L_PAR e = variable_expression R_PAR {e}

%inline variable_content: 
| i = INT { Constant_i(i,Annotation.create $loc) }
| f = FLOAT { Constant_f (f,Annotation.create $loc) }
| b = BOOL { Constant_b (b,Annotation.create $loc) }
| v = IDENTIFIER { Variable(v,Annotation.create $loc) }
| PI {Constant_f(Float.pi, Annotation.create $loc)}

simple_data_type_declaration:
| INT_TYPE {Type_int}
| FLOAT_TYPE {Type_float}
| BOOL_TYPE {Type_bool}
| POSITION_ACCESSOR {Type_pos}
| COLOR_ACCESSOR {Type_color}
| POINT {Type_point}
| LIST L_PAR s = simple_data_type_declaration R_PAR {Type_list(s)}


%inline field_accessor: 
| COLOR_ACCESSOR {Color_accessor}
| POSITION_ACCESSOR {Position_accessor}
| X_ACCESSOR {X_accessor}  
| Y_ACCESSOR {Y_accessor}
| BLUE_ACCESSOR {Blue_accessor}
| RED_ACCESSOR{Red_accessor}
| GREEN_ACCESSOR {Green_accessor}

%inline binary_operator: 
| MUL {Mul}
| DIV {Div}
| ADD {Add}
| SUB {Sub}
| MOD {Mod}
| EQ {Eq}
| NE {Ne}
| LT {Lt}
| GT {Gt}
| LE {Le}
| GE {Ge}
| AND {And}
| OR {Or}

%inline unary_operator: 
| SUB INT {USub}
| NOT {Not}
| HEAD {Head}
| TAIL {Tail}
| FLOOR {Floor}
| FLOAT_OF_INT {Float_of_int}
| COS {Cos}
| SIN {Sin}

list_instanciation: 
| L_SQ_BRK l = content_list_instanciation R_SQ_BRK {List(l,Annotation.create $loc)}
| L_SQ_BRK R_SQ_BRK {List([],Annotation.create $loc )}

content_list_instanciation: 
| e = variable_expression COMMA c = content_list_instanciation {e::c}
| e = variable_expression {[e]}
