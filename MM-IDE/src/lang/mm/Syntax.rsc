@license{
  Copyright (c) 2009-2015 CWI / HvA
  All rights reserved. This program and the accompanying materials
  are made available under the terms of the Eclipse Public License v1.0
  which accompanies this distribution, and is available at
  http://www.eclipse.org/legal/epl-v10.html
}
/*****************************************************************************/
/*!
* Micro-Machinations lang::mm::Syntax
* @package      lang::mm
* @file         Syntax.rsc
* @brief        Defines the syntax of Micro-Machiations
* @contributor  Riemer van Rozen - rozen@cwi.nl - HvA, CREATE-IT / CWI
* @date         February 5th 2015
* @note         Language: Rascal
*/
/*****************************************************************************/
module lang::mm::Syntax

start syntax MM
  = mach: Element*;
 
syntax Element
  = ctype:     TID "{" Element* "}"
  | constr:    "exp" "(" /*{*/NID /*","}**/ ")" "=\>" NID Monotonic
  | absNode:   When Act How "node" NID Pos 
  | source:    When Act How "source" NID Pos  //ACT --> always push
  | drain:     When Act How "drain" NID Pos      //ACT --> always pull
  | pool:      When Act How "pool" NID At Add Max Category Pos
  | ref:       When Act How "ref" NID Pos
  | converter: When Act How "converter" NID Pos
  | gate:      When Act How "gate" NID Pos
  | flow:      NID ":" NID "-" Exp "-\>" NID Pos
  | state:     NID ":" NID "." Exp ".\>" NID Pos;

syntax Monotonic
  = nNone:
  | mInc: ":" "monotonic" "+"
  | mDec: ":" "monotonic" "-";

syntax Pos
  = pos_none:
  | pos: "@(" VALUE "," VALUE ")";

syntax At    //initial value of a pool
  = at_none: //default is zero
  | at_val: "at" VALUE;

syntax Category
  = cat_var:
  | cat: "is" String; 
  
syntax Add    //modification expression of a pool
  = add_none: //default is no modification
  | add_exp: "add" Exp;

syntax Max    //maximum value of a pool
  = max_none: //default is no upper bound
  | max_val: "max" VALUE;
                        
syntax When //when does a node act?
  = when_passive: //default
  | when_passive: "passive"
  | when_user:    "user"
  | when_auto:    "auto"
  | when_start:   "start"
  | when_extern:  "extern";

syntax Act //what does a node do?
  = act_pull: //default
  | act_pull: "pull"
  | act_push: "push";

syntax How //how does a pool perform an act?
  = how_any:  //default
  | how_any: "any"
  | how_all: "all";

syntax Exp
  = e_one:
  | e_val:      VALUE     //Value with optional unit of measurement
  | @category="Value"  e_true:  "true"
  | @category="Value"  e_false: "false"
  | e_name:      NID //{NID "."}+      //Name space query
  | e_override:  "(" Exp ")"     //Override priorities
  | e_active: "active" {NID "."}+
  | e_all: "all"
  | e_ref: "="
  | e_die: VALUE "dice"          //Random number in {1..VALUE+1}
  | e_range: VALUE ".." VALUE    //Random number in {VALUE..VALUE+1}
  > e_per: Exp "|" VALUE !>> Exp //amount that will flow after N iterations  --> desugar to buffer      
  > e_percent: Exp "%"           //state (trigger from gate to node) percentage adds up to 100%                             
                                 //flow percentage refers to the source            
  > e_unm: "~" Exp               //Arithmetic Negation Unary Expression
  | e_not: "!" Exp
  > left
    ( left e_mul: Exp "*" Exp   //Arithmetic Multiply Binary Expression
    | left e_div: Exp "/" Exp   //Arithmetic Divide Binary Expression
    )
  > left
    ( left e_add: Exp "+" Exp   //Arithmetic Plus Binary Expression
    | left e_sub: Exp "-" Exp   //Arithmetic Minus Binary Expression
    )
  > left
    ( left e_lt:  Exp "\<" Exp  //Relational Less Than Binary Expression
    | left e_gt:  Exp "\>" Exp  //Relational Greater Than Binary Expression
    | left e_le:  Exp "\<=" Exp //Relational Less-Equals Binary Expression
    | left e_ge:  Exp "\>=" Exp //Relational Greater-Equals Binary Expression
    | left e_neq: Exp "!=" Exp  //Relational Not-Equals Binary Expression
    | left e_eq:  Exp "==" Exp  //Relational Equals Binary Expression 
    )
  > left e_and: Exp "&&" Exp
  > left e_or: Exp "||" Exp
  ;

syntax String
  = @category="String"  "\"" STRING "\"";
    
syntax NID
  = @category="Name" ID;
  
syntax TID
  = @category="TypeName" ID; 
  
syntax UID
  = @category="UnitName" ID;
    
syntax ID
  = id: NAME;

lexical VALUE
  = @category="Value" ([0-9]+([.][0-9]+?)?);  

lexical NAME
  = ([a-zA-Z_$] [a-zA-Z0-9_$]* !>> [a-zA-Z0-9_$]) \ Keyword;
  
lexical STRING
  = ![\"]*;
  
layout LAYOUTLIST
  = LAYOUT* !>> [\t-\n \r \ ] !>> "//" !>> "/*";

lexical LAYOUT
  = Comment
  | [\t-\n \r \ ];
  
lexical Comment
  = @category="Comment" "/*" (![*] | [*] !>> [/])* "*/" 
  | @category="Comment" "//" ![\n]* [\n];

keyword Keyword
  = "node" | "source" | "pool" | "drain" | "gate" | "converter" | "delay" | "assert" | "delete" |
  | "of" | "from" | "to" | "add" | "at" | "min" | "max" | "is"
  | "passive" | "user" | "auto" | "start"
  | "push" | "pull" | "any" | "all"
  | "true" | "false" | "dice" | "active"
  | "ref" | "in" | "out" | "inout" |
  | "step" | "violate"
  | "pattern" | "monotonic" | "exp" | "intent" | "useWhen";

public Exp mm_parse_exp(str src) = 
  parse(#Exp, src);

public start[MM] mm_parse(str src, loc file) = 
  parse(#start[MM], src, file);
  
public start[MM] mm_parse(loc file) = 
  parse(#start[MM], file); 