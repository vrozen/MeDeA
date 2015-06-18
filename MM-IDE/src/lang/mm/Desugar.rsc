@license{
  Copyright (c) 2009-2015 CWI / HvA
  All rights reserved. This program and the accompanying materials
  are made available under the terms of the Eclipse Public License v1.0
  which accompanies this distribution, and is available at
  http://www.eclipse.org/legal/epl-v10.html
}
/*****************************************************************************/
/*!
* Desugars AST to pattern format
* @package      lang::mm
* @file         Desugar.rsc
* @brief        Defines Desugaring
* @contributor  Riemer van Rozen - rozen@cwi.nl - HvA, CREATE-IT / CWI
* @date         February 5th 2015
* @note         Language: Rascal
*/
/*****************************************************************************/
module lang::mm::Desugar

import lang::mm::AST;
import lang::mpl::AST;
import Node;
import IO;

Pattern desugar(pttr(ID name, list[ID] params, str intent, str useWhen, list[Element] elements))
  = pattern
    (
      name, intent, useWhen,
      {p | p <- params},
      {replaceVars(desugar(e),params) | e <- elements, \constr (ID var, ID expName, Monotonic mon) !:= e},        
      {constraint(var, expName, delAnnotations(mon)) | c: constr (ID var, ID expName, Monotonic mon)  <- elements}
    );
    
Element replaceVars(Element e, list[ID] params)
  = visit(e)
  {
    case e_name(id(str n)):
    {
      if(id(n) in params)
      {
        insert e_var(n);
      }
    }
  };
      
Diagram desugar(mach(list[Element] elements))
  =  diagram ({desugar(e) | e <- elements});

Element desugar(absNode (When when, Act act, How how, ID name, Pos pos))
   = e_node (t_var(), when, act, how, name, cat_var())[@position = delAnnotations(pos)];
   
Element desugar(source (When when, Act act, How how, ID name, Pos pos))
   = e_node (t_source(), when, act, how, name, cat_var())[@position = delAnnotations(pos)];
 
Element desugar(drain (When when, Act act, How how, ID name, Pos pos))
   = e_node (t_drain(), when, act, how, name, cat_var())[@position = delAnnotations(pos)];

Element desugar(pool (When when, Act act, How how, ID name, At at, Add add, Max max, Category cat, Pos pos))
   = e_node (t_pool(), when, act, how, name, cat)[@position = delAnnotations(pos)];

Element desugar(converter (When when, Act act, How how, ID name, Pos pos))
   = e_node (t_converter(), when, act, how, name, cat_var())[@position = delAnnotations(pos)];

Element desugar(gate(When when, Act act, How how, ID name, Pos pos))
   = e_node (t_gate(), when, act, how, name, cat_var())[@position = delAnnotations(pos)];

Element desugar(f: flow(ID name, ID src, Exp exp, ID tgt, Pos pos))
   = e_edge (t_flow(), name, src, exp, tgt)[@position = delAnnotations(pos)]; //[@location = f@location];

Element desugar(f: state(ID name, ID src, Exp exp, ID tgt, Pos pos))
   = e_edge(t_state(), name, src, exp, tgt)[@position = delAnnotations(pos)]; //[@location = f@location];

Element desugar(Element e)
   = e;