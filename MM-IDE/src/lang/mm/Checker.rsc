@license{
  Copyright (c) 2009-2015 CWI / HvA
  All rights reserved. This program and the accompanying materials
  are made available under the terms of the Eclipse Public License v1.0
  which accompanies this distribution, and is available at
  http://www.eclipse.org/legal/epl-v10.html
}
module lang::mm::Checker

import lang::mm::AST;
import lang::mpl::AST;
import Set;
import IO;

alias ContextCheck = tuple[bool connected, list[str] errors]; 

public bool hasConnectedEdges(set[Element] es)
  = check(es).connected;

public ContextCheck check(Diagram d)
  = check(d.elements);

public ContextCheck check(set[Element] es)
{
  bool connected = true;
  list[str] errors = [];
  visit(es)
  {
    case e_edge (_,name,src,_,tgt):
    {
      if(size({ n | n: e_node(_,_,_,_,src,_) <- es}) != 1)
      {
        errors += ["edge <name.name> is not connected on source end <src.name>"];
        connected = false;
      }
      if(size({ n | n: e_node(_,_,_,_,tgt,_) <- es}) != 1)
      {
        connected = false;
        errors += ["edge <name.name> is not connected on target end <tgt.name>"];
      }
    }
  }
  return <connected, errors>;
}


//quick and dirty check for monotonicity
//Note: ignores polynomials with multiple variables
public bool monotonic(mNone(), _, _)
  = true;

//if var is mentioned behind a minus then false
//Note: ignores minus minus
public bool monotonic(mInc(), Exp exp: e_sub(Exp e1, Exp e2), ID var)
 = !(e_name(var) := e2);

//if var is mentioned behind a minus then false
//Note: ignores minus minus  
public bool monotonic(mInc(), Exp exp: e_unm(Exp e1), ID var)
  = !(e_name(var) := e1);

//default case is true
public bool monotonic(mInc(), _, _ )
 = true;

//unary minus case -> trivially true
public bool monotonic(mDec(), Exp exp: e_unm(Exp e1), ID var)
  = e_name(var) := e1;

//subtraction case -> trivially true
public bool monotonic(mDec(), Exp exp: e_sub(Exp e1, Exp e2), ID var)
  = e_name(var) := e2;

//default case is false
public bool monotonic(mInc(), _, _)
  = false;

//public bool monotonic(mDec(), Exp exp, ID var)
//  = !monotonic(mInc(), exp, var);



public set[ID] usedParameters(Pattern p, set[Element] es)
{
  set[ID] used = {};
  //println("ping");
  for(ID id <- p.parameters)
  {
    str name = id.name;
    visit(es)
    {
      case e_var(name):
      {
        used += id;
      }
    }
  }
  return used;
}

public bool hasPosableConstraints(set[Element] es, set[ID] ps, set[Constraint] cs)
{
  bool posable = true;

  for(constraint(ID var, ID expName, str kind, Monotonic mon) <- cs)
  {
    if(expName notin ps)
    {
      posable = false;
    }
   
    if(size({e | e: e_node(_,_,_,_,var,_) <- es}) != 1)
    {
      posable = false;
    }
 
    /*str n = var.name;
    if(size({anEdge | anEdge: e_edge  (_, _, _, e_var(n), _) <- es }) != 1)
    {
      posable = false;
    }*/

    if(!posable)
    {
      break;
    }
  }
 
  return posable;
}