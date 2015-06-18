@license{
  Copyright (c) 2009-2015 CWI / HvA
  All rights reserved. This program and the accompanying materials
  are made available under the terms of the Eclipse Public License v1.0
  which accompanies this distribution, and is available at
  http://www.eclipse.org/legal/epl-v10.html
}
/*****************************************************************************/
/*!
* Micro-Machinations IDE Contributions
* @package      lang::mm
* @file         IDE.rsc
* @brief        Defines Machinations IDE Contributions
* @contributor  Riemer van Rozen - rozen@cwi.nl - HvA, CREATE-IT / CWI
* @date         Febrary 5th 2015
* @note         Language: Rascal
*/
/*****************************************************************************/
module lang::mm::IDE

import lang::mm::Syntax;
import lang::mm::AST;
import lang::mpl::Syntax;
import lang::mpl::AST;
import lang::mm::Desugar;
import lang::mm::Match;
import lang::mm::Generate;
import lang::mm::Serialize;
import lang::mm::Visualize;

import vis::Figure;
import vis::Render;
import util::Math;

import ParseTree;
import util::IDE;
import vis::Figure;
import IO;
import Message;
import Ambiguity;

//debugging:
import Set;
import Map;

public str MM_NAME = "Micro-Machinations";                   //language name
public str MM_EXT  = "mm" ;                                  //file extension
public str MPL_NAME = "Micro-Machinations Pattern Language"; //language name
public str MPL_EXT  = "mpl" ;                                //file extension

private node mm_ide_outline (Tree t)
  = mm_implode(t);

private node mpl_ide_outline (Tree t)
  = mpl_implode(t);
  
private void mm_ide_visualize (Tree t, loc mmt_loc)
{
  println("Diagnose diagram: <diagnose(t)==[]>");

  println("Implode diagram");
  MM diagram_ast = mm_implode(t);
  
  println("Desugar diagram");
  Diagram d = desugar(diagram_ast);
    
  println("Visualize diagram");
  mm_visualize(mmt_loc, d);
}

public void mm_register()
{
  Contribution mm_style =
    categories
    (
      (
        "Name" : {foregroundColor(color("royalblue"))},
        "TypeName" : {foregroundColor(color("darkblue")),bold()},
        "UnitName" : {foregroundColor(color("mediumblue")),bold()},
        "Comment": {foregroundColor(color("dimgray"))},
        "Value": {foregroundColor(color("firebrick"))},
        "String": {foregroundColor(color("teal"))}
        //,"MetaKeyword": {foregroundColor(color("blueviolet")), bold()}
      )
    );

  mm_contributions =
  {
    mm_style,
    popup
    (
      menu
      (
        "Micro-Machinations",
        [
          action("Run MeDeA", mm_ide_visualize)
        ]
      )
    )
  };
  
  set[Contribution] mpl_contributions =
  {
    mm_style
  };


  registerLanguage(MM_NAME, MM_EXT, lang::mm::Syntax::mm_parse);
  registerOutliner(MM_NAME, mm_ide_outline);
  registerContributions(MM_NAME, mm_contributions);

  registerLanguage(MPL_NAME, MPL_EXT, lang::mpl::Syntax::mpl_parse);
  registerOutliner(MPL_NAME, mpl_ide_outline);
  registerContributions(MPL_NAME, mpl_contributions);
}


public void paper()
{
  loc diagram_file = |project://MM-IDE/test/diagrams/paper2/step1.mm|;
 
  Tree diagram_tree = mm_parse(diagram_file);
  MM diagram_ast = mm_implode(diagram_tree);
  Diagram d = desugar(diagram_ast);  
  
  mm_visualize(d);
  
}

//--------------------------------------------------------------------------------
//for quick testing purposes
//--------------------------------------------------------------------------------
public tuple[Diagram d, Pattern p, set[Matching] m] probeer()
{
  loc diagram_file = |project://MM-IDE/test/diagrams/player.mm|;
  loc pattern_file = |project://MM-IDE/test/patterns/Acquisition.mpl|; 
    
  Tree diagram_tree = mm_parse(diagram_file);
  Tree pattern_tree = mpl_parse(pattern_file);

  println("Diagnose diagram: <diagnose(diagram_tree)==[]>");

  println("Diagnose pattern: <diagnose(pattern_tree)==[]>");

  println("Implode diagram");
  MM diagram_ast = mm_implode(diagram_tree);
  
  println("Implode pattern");
  MPL pattern_ast = mpl_implode(pattern_tree);

  println("Desugar diagram");
  Diagram d = desugar(diagram_ast);
  
  println("Desugar pattern");
  Pattern p = desugar(pattern_ast);

  str program = toRascalString(p);
  println(program);

  //println("Match pattern");
  //Matching m = match(d, p, ());  
  println("PowerMatch");
  set[Matching] matchings = powerMatch(d, p, ());
  return <d, p, matchings>;
}


private str statistics(Matching m)
{
  int notFoundParameters = size(m.notFound.parameters);
  int notFoundConstraints = size(m.notFound.constraints);
  int notFoundNodes = size({e | Element e <- m.notFound.elements, \e_node := e});
  int notFoundEdges = size({e | Element e <- m.notFound.elements, \e_edge := e});
  int foundMatches = size(m.found);

  return
    "Matching
    '  not found nodes       <notFoundNodes>
    '  not found edges       <notFoundEdges>
    '  not found parameters  <notFoundParameters>
    '  not found constraints <notFoundConstraints>
    '  found matches         <foundMatches><
      for(tuple[MatchID names, MatchExp exps] match <- m.found){>
    '  match has <size(match.names)> matched names, <size(match.exps)> matched exps
    '    names <for(str n <- match.names){><n>:<match.names[n].name>,<}>
    '    exps  <for(str e <- match.exps){><e>:<toString(match.exps[e])>,<}><}>\n";
}




