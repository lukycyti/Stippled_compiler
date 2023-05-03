open Ast

(* Codez ici le simplificateur de termes.

    Tout comme pour le langage du cours, l’idée consiste à remplacer les termes constants par le résultat de leur calcul.

    Faites une sous-fonctions récursive pour les expressions et les statements.
    Ces fonction font un pattern matching sur leur argument et traitent chaque cas séparément. Elles renvoient un argument de même type que celui reçu.
    Par exemple : simplify_expression : Ast.expression -> Ast.expression

    Les cas minimaux attendus sont les cas sur les entiers, les flottants, les booléens, ainsi que les if dont le test est constant, et les for qui ne s’exécutent jamais.

    Deux points qui peuvent vous permettre d’aller plus loin :
      - les expressions ne peuvent pas faire d’effet de bord ici, ce qui permet de simplifier des expressions pas nécessairement constantes.
      - Les types composés (point, position et couleur) peuvent également être simplifiés (e.g., (1,2) + (2,x) peut être simplifié en (3,2+x)).

    Vous détaillerez dans le rapport les différents cas que vous simplifiez dans votre simplificateur.
*)



let rec simplify_expr (expr) =
  let simplified_expr =
    match expr with
    | Constant_i(i, a) -> Constant_i(i, a)
    | Constant_f(f, a) -> Constant_f(f, a)
    | Constant_b(b, a) -> Constant_b(b, a)
    | Variable(v, a) -> Variable(v,a)
    | Pos (ex1, ex2, a) -> (
      let e1 = simplify_expr ex1 in
      let e2 = simplify_expr ex2 in
      match(e1, e2) with 
      | Constant_i(e1, _), Constant_i(e2, _) 
        -> Pos(Constant_i(e1,a), Constant_i(e2,a), a)
      | _ -> Pos(e1, e2, a)
    )
    | Color (ex1, ex2, ex3, a) -> (
      let e1 = simplify_expr ex1 in
      let e2 = simplify_expr ex2 in
      let e3 = simplify_expr ex3 in
      match(e1, e2, e3) with 
      | Constant_i(e1, _), Constant_i(e2, _), Constant_i(e3, _)
        -> Color(Constant_i(e1,a), Constant_i(e2,a), Constant_i(e3,a), a)
      | _ -> Color(e1, e2, e3, a)
    )
    | Point (ex1, ex2, a) -> (
      let e1 = simplify_expr ex1 in
      let e2 = simplify_expr ex2 in
      match(e1, e2) with 
      | Pos(_, _, _), Color(_, _, _, _) 
        -> Point(e1, e2, a)
      | _ -> Point(e1, e2, a)
    )
    | Unary_operator (op ,exp, a) -> (
      let e = simplify_expr exp in
      match (op, e) with
      | USub, Constant_i(i, _) -> Constant_i(-i, a)
      | USub, Constant_f(f, _) -> Constant_f(-.f, a)
      | USub, Pos(x, y, _) -> (let xe = (simplify_expr x) in
                              let ye = (simplify_expr y) in 
                              match (xe, ye) with  
                              | Constant_i(xe, _), Constant_i(ye, _) 
                                -> Pos(Constant_i(-xe, a), Constant_i(-ye, a), a)
                                | _ -> Pos(xe, ye, a))
      | USub, Color(r,g,b, _) -> (let re = (simplify_expr r) in
                                 let ge = (simplify_expr g) in
                                 let be = (simplify_expr b) in
                                 match (re, ge, be) with
                                 | Constant_i(re, _), Constant_i(ge, _), Constant_i(be, _)
                                   -> Color(Constant_i(255 - re, a),
                                            Constant_i(255 - ge, a),
                                            Constant_i(255 - be, a), a)
                                 | _ -> Color(re, ge, be ,a))
      | Not, Constant_b(b, _) -> Constant_b(not b, a)
      | Head, List(l, _) -> List.hd l
      | Tail, List(l, _) -> List(List.tl l, a)
      | Floor, Constant_f(f, _) -> Constant_i(int_of_float f, a)
      | Float_of_int, Constant_i(i, _) -> Constant_f(float_of_int i, a)
      | Cos, Constant_f(f, _) -> Constant_f(cos f, a)
      | Sin, Constant_f(f, _) -> Constant_f(sin f, a)
      | _ -> Unary_operator (op , e, a)
    )
    | Binary_operator (op, e1, e2, a) -> (
      let e1 = simplify_expr e1 in
      let e2 = simplify_expr e2 in
      match (op, e1, e2) with
      | Add, Constant_i(i1,_), Constant_i(i2, _) -> Constant_i (i1 + i2, a)
      | Add, Constant_f(f1,_), Constant_f(f2,_) -> Constant_f (f1 +. f2, a)
      | Sub, Constant_i (i1,_), Constant_i (i2,_) -> Constant_i (i1 - i2, a)
      | Sub, Constant_f (f1,_), Constant_f (f2,_) -> Constant_f (f1 -. f2, a)
      | Mul, Constant_i (i1,_), Constant_i (i2,_) -> Constant_i (i1 * i2, a)
      | Mul, Constant_f (f1,_), Constant_f (f2,_) -> Constant_f (f1 *. f2, a)
      | Div, Constant_i (i1,_), Constant_i (i2,_) -> Constant_i (i1 / i2, a)
      | Div, Constant_f (f1,_), Constant_f (f2,_) -> Constant_f (f1 /. f2, a)
      | Mod, Constant_i (i1,_), Constant_i (i2,_) -> Constant_i (i1 mod i2, a)
      | Mod, Constant_f (f1,_), Constant_f (f2,_) -> Constant_f (mod_float f1 f2, a)
      | And, Constant_b (b1,_), Constant_b (b2,_) -> Constant_b (b1 && b2, a)
      | Or, Constant_b (b1,_), Constant_b (b2,_) -> Constant_b (b1 || b2, a)
      | Eq, Constant_i _, Constant_i _ | Eq, Constant_b _, Constant_b _ | Eq, Constant_f _, Constant_f _ ->
          Constant_b (e1 = e2, a)
      | Ne, Constant_i _, Constant_i _ | Ne, Constant_b _, Constant_b _ | Ne, Constant_f _, Constant_f _
        ->
          Constant_b (e1 <> e2, a)
      | Le, Constant_i _, Constant_i _ | Le, Constant_b _, Constant_b _ | Le, Constant_f _, Constant_f _
        ->
          Constant_b (e1 <= e2, a)
      | Ge, Constant_i _, Constant_i _ | Ge, Constant_b _, Constant_b _ | Ge, Constant_f _, Constant_f _
        ->
          Constant_b (e1 >= e2, a)
      | Lt, Constant_i _, Constant_i _ | Lt, Constant_b _, Constant_b _ | Lt, Constant_f _, Constant_f _ ->
          Constant_b (e1 < e2, a)
      | Gt, Constant_i _, Constant_i _ | Gt, Constant_b _, Constant_b _ | Gt, Constant_f _, Constant_f _ ->
          Constant_b (e1 > e2, a)
      | _ -> Binary_operator (op, e1, e2, a)
    )
    | Field_accessor (op ,exp, a) -> (
      let e = simplify_expr exp in
      match (op, e) with
      | Color_accessor, Point(_, c, _) -> c
      | Red_accessor, Color(r,_,_,_) -> r
      | Green_accessor, Color(_,g,_,_) -> g
      | Blue_accessor, Color(_,_,b,_) -> b
      | Position_accessor, Point(p, _, _) -> p
      | X_accessor, Pos(x,_,_) -> x
      | Y_accessor, Pos(_,y,_) -> y
      | _ -> Field_accessor (op ,e, a)
    )
    | List (exp_list, a) -> let exp_list = List.map simplify_expr exp_list in List(exp_list, a) 
    | Cons (e1, e2, a) -> let e1' = simplify_expr e1 in
                          let e2' = simplify_expr e2 in
                          Cons (e1', e2', a)
  in
  (simplified_expr)

let rec simplify_statement (statement) =
  let simplify_statement =
    match statement with
    | Assignment (expr1, expr2, a) -> Assignment (simplify_expr expr1, simplify_expr expr2, a)
    | Variable_declaration(str, type_expr, a) -> Variable_declaration(str, type_expr, a)
    | Block(l, a) -> Block (List.map (fun instr -> simplify_statement instr) l, a)
    | IfThenElse(test, i_then, i_else, a) -> (
      let test = simplify_expr test in
      match test with
    | Constant_b(true, _) -> (simplify_statement i_then)
    | Constant_b(false,_) -> (simplify_statement i_else)
    | _ ->
        IfThenElse
          (test, simplify_statement i_then, simplify_statement i_else, a))
    | For(str, e_init, e_target, e_step, stmt, a) -> (
      let init = simplify_expr e_init in
      let target = simplify_expr e_target in
      let step = simplify_expr e_step in
      match (init, target, step) with
      | Constant_i(init, _), Constant_i(target, _) , Constant_i(step, _) -> (
        (* Cas ou on a des int*)
          match Constant_b(init <= target, a) with
          | Constant_b(true, a) -> let stm_list : statement list = [simplify_statement stmt;
                                                For(str,
                                                  Constant_i(init+step, a),
                                                  Constant_i(target, a),
                                                  Constant_i(step, a), 
                                                  simplify_statement stmt, a)]
            in Block(stm_list, a)
          | Constant_b(false, _) -> Nop
          | _ -> For(str, e_init, e_target, e_step, stmt, a)
      )
      | Constant_f(init, _), Constant_f(target, _) , Constant_f(step, _) -> (
        (* Cas ou on a des float*)
          match Constant_b(init <= target, a) with
          | Constant_b(true, a) -> let stm_list : statement list = [simplify_statement stmt;
                                                For(str,
                                                  Constant_f(init+.step, a),
                                                  Constant_f(target, a),
                                                  Constant_f(step, a), 
                                                  simplify_statement stmt, a)]
            in Block(stm_list, a)
          | Constant_b(false, _) -> Nop
          | _ -> For(str, e_init, e_target, e_step, stmt, a)
      )
      | _ -> For(str, e_init, e_target, e_step, stmt, a)
    )
    | Foreach(str, expr, stmt, a) -> (
       let list = simplify_expr expr in match list with
       | List(expr, _) -> (let size =
            List.length expr in match size with
            | 0 -> Nop
            | 1 -> simplify_statement stmt
            | _ -> Foreach(str, list, stmt, a)
       )
       | _ -> Foreach(str, list, stmt, a)
    )
    | Draw(expr, a) -> Draw(simplify_expr expr, a)
    | Print(expr, a) -> Print(simplify_expr expr, a)
    | Nop -> Nop
    
  in
  (simplify_statement)

  let simplifier program =
    match program with 
    | Program (arg, stat) -> Program(arg, simplify_statement stat)