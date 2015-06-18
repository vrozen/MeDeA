@license{
  Copyright (c) 2009-2015 CWI / HvA
  All rights reserved. This program and the accompanying materials
  are made available under the terms of the Eclipse Public License v1.0
  which accompanies this distribution, and is available at
  http://www.eclipse.org/legal/epl-v10.html
}
/*****************************************************************************/
/*!
* Matches Patterns against Diagrams
* @package      lang::mm
* @file         Match.rsc
* @brief        Matches Patterns against Diagrams
* @contributor  Riemer van Rozen - rozen@cwi.nl - HvA, CREATE-IT / CWI
* @date         Febrary 5th 2015
* @note         Language: Rascal
*/
/*****************************************************************************/
module lang::mm::Match

import IO;
import Node;
import Set;
import List;
import String;
import util::Eval;
import lang::mm::Util;
//import lang::mm::Syntax;
import lang::mm::AST;
//import lang::mmp::Syntax;
import lang::mpl::AST;
import lang::mm::Checker;

alias MatchID  = map[str roleName, ID id];
alias MatchExp = map[str varName, Exp exp];
alias Match    = set[tuple[MatchID names, MatchExp exps]];
alias MatchNot = tuple[set[Element] elements, set[Constraint] constraints, set[ID] parameters];
alias Matching = tuple[Match found, MatchNot notFound];

private str toRascalString(ID id)
  = id.name;

private str toRascalString(e_var(str name))
  = name;
  
private str toRascalString(Exp e)
  = Node::toString(e);
  
private str toRascalString(t_var())
  = "_";

private str toRascalString(NodeType t)
  = Node::toString(t);
  
private str toRascalString(EdgeType t)
  = Node::toString(t);

private str toRascalString(when_var())
  = "_";

private str toRascalString(When when)
  = Node::toString(when);

private str toRascalString(act_var())
  = "_";

private str toRascalString(Act act)
  = Node::toString(act);
  
private str toRascalString(how_var())
  = "_";
 
private str toRascalString(How how)
  = Node::toString(how);
  
private str toRascalString(cat_var())
  = "_";

private str toRascalString(Category c)
  = Node::toString(c);
  
private str toRascalString(e_node(nodeType, when, act, how, name, cat))
  ="e_node(<toRascalString(nodeType)>,<toRascalString(when)>,<toRascalString(act)>,<toRascalString(how)>,<toRascalString(name)>,<toRascalString(cat)>)";
  
private str toRascalString(e_edge(edgeType, name, src, exp, tgt))
  = "e_edge(<toRascalString(edgeType)>,<toRascalString(name)>,<toRascalString(src)>,<toRascalString(exp)>,<toRascalString(tgt)>)";

private str toRascalString(Element e)
{
   throw "incorrect <e>";
}

public str toRascalString(Pattern p)
  = toRascalString(p, p.elements, p.constraints, p.parameters);

set[Matching]  match(Diagram d, Pattern p, MatchID preMatch)
{
  set[Matching] r = {};
  str program = toRascalString(p, p.elements, p.constraints, p.parameters);
  program += "<p.name.name>(<delAllAnnotations(delAllAnnotations(d,"comments"),"position")>,<preMatch>);";
  println();
  println(program);
  println();
  if(result(Matching m) := eval(program))
  {
    r += m;
  }
  return r;
}

set[Matching] powerMatch(Diagram d, Pattern p, MatchID preMatch, int minMatchedElements)
{
  set[set[Element]] powerElements =
    {es | es <- power(p.elements), hasConnectedEdges(es) == true, size(es) >= minMatchedElements};

  set[tuple[set[Element],set[ID]]] powerElementsParams =
    {<es,usedParameters(p,es)> | es <- powerElements};

  set[set[Constraint]] constraints = power(p.constraints);
  if(constraints != {{}}){ constraints -= {{}}; }

  set[tuple[set[Element],set[Constraint],set[ID]]] powerElementsConstraintsParams =
    {<es,cs,ps> | <es,ps> <- powerElementsParams, cs <- constraints, hasPosableConstraints(es,ps,cs) == true};

  set[Matching] matchings = {};
  for(<es,cs, ps> <- powerElementsConstraintsParams)
  {
    str program = toRascalString(p, es, cs, ps);
    
    int es_size = size(es);
    int ps_size = size(ps);
    int cs_size = size(cs);
    if(es_size != 0)
    {
      program += "\n<p.name.name>(<delAllAnnotations(delAllAnnotations(d,"comments"),"position")>,<delAllAnnotations(delAllAnnotations(preMatch,"comments"),"position")>);";
      
      println(program);
      println("Matching pattern with <es_size> elements <es>
              '  and <ps_size> parameters <ps>
              '  and <cs_size> constraints <cs> ...");
      
      if(result(Matching r) := eval(program))
      {
        println("  has <size(r.found)> results missing <size(r.notFound.elements)> elements, <size(r.notFound.parameters)> parameters and <size(r.notFound.constraints)> constraint");        
        //iprintln(r);
        if(size(r.found)>0)
        {
          matchings += r;
        }
      }
    }
  }
  
  return matchings;
}

public str toRascalString
(
  pattern(ID name, str intent, str useWhen, set[ID] params, set[Element] elements, set[Constraint] constraints),
  set[Element] includeElements,        /*elements used in matching*/
  set[Constraint] includeConstraints,  /*constraints posed on results*/
  set[ID] includeParams                /*parameters bound by the pattern part*/
)
  = "//module lang::mm::<name.name>
    'import lang::mm::AST;
    'import lang::mpl::AST;
    'import lang::mm::Match;
    'import lang::mm::Checker;
    '/******************************************************************************* 
    ' * Parameterized Micro-Mechanic Pattern
    ' * name:     <name.name>
    ' * intent:   <intent>
    ' * use when: <useWhen>
    ' *******************************************************************************/
    'public Matching (Diagram d, MatchID preMatch) <name.name> =
    'Matching (Diagram d, MatchID preMatch)
    '{<for(e_node(NodeType t, When when, Act act, How how, ID name, Category cat) <- includeElements){>
    '   ID <name.name>;<}>
    '<for(e_node(NodeType t, When when, Act act, How how, ID name, Category cat) <- includeElements){>
    '   if(\"<name.name>\" in preMatch) { <name.name> = preMatch[\"<name.name>\"]; }<}>
    '
    '   //unmapped elements, constraints and parameters
    '   //used for generating missing parts (design decisions)
    '   tuple[set[Element] elements, set[Constraint] constraints, set[ID] parameters] notFound =
    '     \<<{delAllAnnotations(e, "comments") | e <- elements - includeElements}>,
    '      <{delAllAnnotations(c, "comments") | c <- constraints - includeConstraints}>,
    '      <{delAllAnnotations(p, "comments") | p <- params - includeParams}>\>;
    '
    '   Match found = {};
    '   for
    '   ( //generate a diagram with unbound variables for pattern matching
    '     diagram
    '     (
    '       {<for(Element e <- includeElements){>
    '         <toRascalString(delAllAnnotations(e))>,<}>
    '         *Rest
    '       }
    '     ) := d
    '   )
    '   {
    '     bool ok = true;
    '     <for(constraint(ID var, ID exp, Monotonic mon) <- includeConstraints, exp in includeParams){>
    '     ok = ok && /e_name(<var.name>) := <toRascalString(exp)> && monotonic(<mon>,<toRascalString(exp)>,<toRascalString(var)>);<}>
    '     if(ok) //collect binding
    '     {
    '       //binding of participants (nodes and edges)
    '       MatchID idMap = (<while(includeElements!={}){ Element e; <e,includeElements> = takeOneFrom(includeElements);>
    '          \"<toRascalString(e.name)>\":<toRascalString(e.name)><if(includeElements!={}){>,<}><}>
    '       );
    '       //binding of variable expressions (parameters)
    '       MatchExp expMap = (<while(includeParams!={}){ ID id; <id,includeParams> = takeOneFrom(includeParams);>
    '          \"<id.name>\":<id.name><if(includeParams!={}){>,<}><}>
    '       );
    '       found += {\<idMap,expMap\>};
    '     }
    '   };
    '
    '   return \<found, notFound\>;
    '};\n";


