@license{
  Copyright (c) 2009-2015 CWI / HvA
  All rights reserved. This program and the accompanying materials
  are made available under the terms of the Eclipse Public License v1.0
  which accompanies this distribution, and is available at
  http://www.eclipse.org/legal/epl-v10.html
}
/*****************************************************************************/
/*!
* Generates Diagrams given a Matching
* @package      lang::mm
* @file         Generate.rsc
* @brief        Generates Diagrams given a Matching
* @contributor  Riemer van Rozen - rozen@cwi.nl - HvA, CREATE-IT / CWI
* @date         February 5th 2015
* @note         Language: Rascal
*/
/*****************************************************************************/
module lang::mm::Generate

import lang::mm::AST;
import lang::mpl::AST;
import lang::mm::Match;
import IO;
import Relation;
import Set;

//alias MatchID  = map[str roleName, ID id];
//alias MatchExp = map[str varName, Exp exp];
//alias Match    = set[tuple[MatchID names, MatchExp exps]];
//alias MatchNot = tuple[set[Element] elements, set[Constraint] constraints, set[ID] parameters];
//alias Matching = tuple[Match found, MatchNot notFound];

public set[tuple[Diagram result, MatchID found, MatchID added, MatchID replaced, MatchExp exps]] generate (Pattern p, Diagram d, Matching m)
{
  set[tuple[Diagram result,  MatchID found, MatchID added, MatchID replaced, MatchExp exps]] result = {};
  MatchID addedNodesMatch = ();
  set[Element] addedNodes = {};
  
  println("Not found elements <size(m.notFound.elements)>");
  //generate unbound nodes (same for all matchings)
  for(Element e: e_node(NodeType t, When when, Act act, How how, ID name /*role*/, Category cat) <- m.notFound.elements)
  {
    //bind the role name to a generated id name
    //add it to the matching <role name, generated id name>
    //collect generated element for adding to the diagram    
    ID generated_id = id("_n_<name.name>"); //can be renamed later by the user
    addedNodesMatch += (name.name: generated_id);
    addedNodes += {e_node(t,when,act,how,generated_id,cat)};
  }
  
  if(m.found == {})
  {
    MatchID addedEdgesMatch = ();
    set[Element] addedEdges = {};
    set[Element] replacedEdges = {};
    MatchID replacedMatch = ();
    
    for(Element e: e_edge(EdgeType edgeType, ID name, ID src, Exp exp, ID tgt) <- m.notFound.elements)
    {  
      ID resolved_src = resolve(src.name, (), addedNodesMatch);
      ID resolved_tgt = resolve(tgt.name, (), addedNodesMatch);
      ID edge_id = id("_e_<name.name>"); //can be renamed later by the user
      addedEdgesMatch += (name.name: edge_id);
      addedEdges += {e_edge(edgeType, edge_id, resolved_src, exp, resolved_tgt)};      
    }
    
    MatchID addedMatch = addedNodesMatch + addedEdgesMatch;
    Diagram newDiagram = diagram(d.elements + addedNodes + addedEdges);
  
    //add a new diagram to the result
    result += {<newDiagram, (), addedMatch, (), ()>};
  }
  
  //generate unbound edges (may differ per matching) 
  for(tuple[MatchID names, MatchExp exps] match <- m.found)
  {
    MatchID addedEdgesMatch = ();
    set[Element] addedEdges = {};
    set[Element] replacedEdges = {};
    MatchID replacedMatch = ();
    
    for(Element e: e_edge(EdgeType edgeType, ID name, ID src, Exp exp, ID tgt) <- m.notFound.elements)
    {  
      ID resolved_src = resolve(src.name, match.names, addedNodesMatch);
      ID resolved_tgt = resolve(tgt.name, match.names, addedNodesMatch);
      ID edge_id = id("_e_<name.name>"); //can be renamed later by the user

      bool found = false;
      /*for(Element e_replace: e_edge(edgeType, ID actualName, resolved_src, Exp exp2, resolved_tgt) <- d.elements)
      {
        //TODO: only replace it if there is a contraint on its expression
        //      and it does not meet the requirements      
        //edge_id = actualName;
        //replacedMatch += (name.name:actualName);
        //replacedEdges += {e_replace};
        found = true; break;
      }*/
      
      //TODO: add it if there is no edge there yet
      //      or if it replaces another edge
      if(!found)
      {
        addedEdgesMatch += (name.name: edge_id);      
        addedEdges += {e_edge(edgeType, edge_id, resolved_src, exp, resolved_tgt)};
      }
    }
    
    MatchID foundMatch = match.names;
    MatchExp foundExps = match.exps;
    MatchID addedMatch = addedNodesMatch + addedEdgesMatch;
    
    Diagram newDiagram = diagram(d.elements + addedNodes + addedEdges - replacedEdges);
  
    //add a new diagram to the result
    result += {<newDiagram, foundMatch, addedMatch, replacedMatch, foundExps>};
  }
    
  return result;
}


ID resolve(str name, MatchID found, MatchID added)
{
  ID resolvedId;
  if(name in found)
  {
    resolvedId = found[name];
  }
  else
  {
    println("<added>");
    resolvedId = added[name];
  }
  return resolvedId;
}

//remove matches that have supermatches from the result
public set[tuple[Diagram result, MatchID found, MatchID added, MatchID replaced, MatchExp exps]] filterDuplicates
   (set[tuple[Diagram result, MatchID found, MatchID added, MatchID replaced, MatchExp exps]] decisions)
{
  set[tuple[Diagram result, MatchID found, MatchID added, MatchID replaced, MatchExp exps]] result = {};

  for(tuple[Diagram result, MatchID found, MatchID added, MatchID replaced, MatchExp exps] decision <- decisions)
  {
    bool store = true;
    MatchID decisionFoundNodes = foundNodes(decision.result, decision.found);
      
    //if there is a decision other where found contains all found nodes then remove this decision
    for(tuple[Diagram result, MatchID found, MatchID added, MatchID replaced, MatchExp exps] other <- decisions)
    {
      MatchID otherFoundNodes = foundNodes(other.result, other.found);
      if(decisionFoundNodes == otherFoundNodes && decision.found < other.found)
      {
        //if it's a subset, don't store it and present it to the user, it's a duplicate
        store = false;
        println("Removed subdecision <decisionFoundNodes> due to <otherFoundNodes>");
        break;        
      }
    }
    
    if(store)
    {
      println("Added decison <decision>");
      result += {decision};
    }
  }
  
  return result;
}

private MatchID foundNodes(Diagram diagram, MatchID found)
{
  //println("FIND NODES <found>\nin <diagram>");
  MatchID foundNodes = ();
  for(str role <- found)
  {
    ID name = found[role];    
    for(e_node(_, _, _, _, name, _) <- diagram.elements)
    {
      foundNodes += (role: name);
    }
  }
  //println("RESULT <foundNodes>");
  return foundNodes;
}