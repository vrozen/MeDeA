@license{
  Copyright (c) 2009-2015 CWI / HvA
  All rights reserved. This program and the accompanying materials
  are made available under the terms of the Eclipse Public License v1.0
  which accompanies this distribution, and is available at
  http://www.eclipse.org/legal/epl-v10.html
}
/*****************************************************************************/
/*!
* Micro-Machinations Abstract Syntax
* @package      lang::mm
* @file         AST.rsc
* @brief        Defines Machinations Abstract Syntax
* @contributor  Riemer van Rozen - rozen@cwi.nl - HvA, CREATE-IT / CWI
* @date         February 5th 2015
* @note         Language: Rascal
*/
/*****************************************************************************/
module lang::mm::AST
import ParseTree;

/***************************************************************************** 
 * Public APIs
 *****************************************************************************/
public lang::mm::AST::MM mm_implode(Tree tree)
  = implode(#lang::mm::AST::MM, tree);
  
public lang::mm::AST::Exp mm_implode_exp(Tree tree)
  = implode(#lang::mm::AST::Exp, tree);

/***************************************************************************** 
 * Source location annotations
 *****************************************************************************/
anno loc MM@location;
anno loc Diagram@location;
anno loc NodeType@location;
anno loc Element@location;
anno loc Pos@location;
anno loc At@location;
anno loc Add@location;
anno loc Max@location;
anno loc When@location;
anno loc Act@location;
anno loc How@location;
anno loc Category@location;
anno loc Exp@location;
anno loc ID@location;

anno Pos Element@position;

/***************************************************************************** 
 * Micro Machinations AST
 *****************************************************************************/
data MM    //micro-machinations
  = mach(list[Element] elements);

data Diagram
  = diagram(set[Element] elements);

data NodeType
  = t_var() | t_pool() | t_gate() | t_source() | t_drain() | t_converter();

data EdgeType
  = t_flow() | t_state() | t_trigger() | t_condition();

data Element
  //desugared
  = e_node  (NodeType nodeType, When when, Act act, How how, ID name, Category cat)
  | e_edge  (EdgeType edgeType, ID name, ID src, Exp exp, ID tgt)
  //sugared
  | flow      (ID name, ID src, Exp exp, ID tgt, Pos pos)
  | state     (ID name, ID src, Exp exp, ID tgt, Pos pos)
  | constr    (ID var, ID expName, Monotonic mon)  
  | absNode   (When when, Act act, How how, ID name, Pos pos)
  | source    (When when, Act act, How how, ID name, Pos pos)
  | drain     (When when, Act act, How how, ID name, Pos pos)
  | pool      (When when, Act act, How how, ID name, At at, Add add, Max max, Category cat, Pos pos)
  | converter (When when, Act act, How how, ID name, Pos pos)
  | gate      (When when, Act act, How how, ID name, Pos pos)
  ;

data Monotonic
  = mNone()
  | mInc()
  | mDec();  

data Pos
  = pos_none()
  | pos(int x, int y);

data At //start value
  = at_none()
  | at_val(int v);

data Add //node modifier edges together form an expression that adjusts the value of a pool
  = add_none()
  | add_exp(Exp exp);

data Max //maximum pool value
  = max_none()
  | max_val(int v);

data When
  = when_var() | when_passive() | when_user() | when_auto() | when_start();

data Act
  = act_var() | act_pull() | act_push();
  
data How
  = how_var() | how_any() | how_all();
  
data Category
  = cat_var() | cat(str name);
  
//specifies if edges are restricted to the ones in the pattern (i.e. no other input or output exists)
//data Restrict
//  = restrict_true() | restrict_false();

data Exp
  // expand the following implicit notation
  = e_one()                 //desugar --> usually: e_val(1.0, [])
  | e_trigger()             //desugared e_mul(e_one(), e_one())
  | e_ref()                 //may not appear as any sub expression, only valid use is in state as parent exp
  | e_range(int low, int high)
  | e_die(int size)         //desugar --> e_range(1, size)
  | e_percent(Exp e)
  | e_per(Exp e, int n)      //desugar --> buffer. NOTE: in Machinations changing n is possible.
  | e_val(real v)            //Arithmetic value Expression
  | e_true()                 //Boolean true Expression
  | e_false()                //Boolean false Expression
  | e_all()                  //Arithmetic all Expression --> desugar: e_name(src name)
  //| e_name(list[ID] names)   //namespace query
  | e_name(ID name)          //flattened name space query
  | e_var(str exp)           //variable in a pattern
  | e_active(list[ID] names) //activity query
  | e_active(ID name)        //flattened activity query 
  | e_override(Exp e)        //Overriden expression
  | e_not(Exp e)             //Boolean Unary Not Expression
  | e_unm(Exp e)             //Arithmetic Negation Unary Expression
  | e_lt(Exp e1, Exp e2)     //Relational Less Than Expression
  | e_gt(Exp e1, Exp e2)     //Relational Greater Than Expression
  | e_le(Exp e1, Exp e2)     //Relational Less-Equals Expression
  | e_ge(Exp e1, Exp e2)     //Relational Greater-Equals Expression
  | e_neq(Exp e1, Exp e2)    //Relational Not-Equals Expression
  | e_eq(Exp e1, Exp e2)     //Relational Equals Expression
  | e_and(Exp e1, Exp e2)    //Boolean and Expression
  | e_or(Exp e1, Exp e2)     //Boolean or Expression
  | e_mul(Exp e1, Exp e2)    //Arithmetic Multiply Binary Expression
  | e_div(Exp e1, Exp e2)    //Arithmetic Divide Binary Expression
  | e_add(Exp e1, Exp e2)    //Arithmetic Plus Binary Expression
  | e_sub(Exp e1, Exp e2)    //Arithmetic Minus Binary Expression
  ;
  
data ID
  = id(str name);