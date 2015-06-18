@license{
  Copyright (c) 2009-2015 CWI / HvA
  All rights reserved. This program and the accompanying materials
  are made available under the terms of the Eclipse Public License v1.0
  which accompanies this distribution, and is available at
  http://www.eclipse.org/legal/epl-v10.html
}
/*****************************************************************************/
/*!
* Micro-Machinations Visualization
* @package      lang::mm
* @file         Vizualize.rsc
* @brief        Defines the Micro-Machinations Tool
* @contributor  Riemer van Rozen - rozen@cwi.nl - HvA, CREATE-IT / CWI
* @date         February 5th 2015
* @note         Language: Rascal
*/
/*****************************************************************************/
module lang::mm::Visualize

import lang::mm::Syntax;
import lang::mpl::Syntax;
import lang::mm::AST;
import lang::mpl::AST;
import lang::mm::Desugar;
import lang::mm::Match;
import lang::mm::Generate;
import lang::mm::Serialize;

import vis::Figure;
import vis::Render;
import IO;
import ParseTree;
import util::Math;
import List;
import Set;
import Map;
import String;

//------------------------------------------------------------------------------
//Visual Constants
//------------------------------------------------------------------------------
private int NODE_HSIZE = 50;
private int NODE_VSIZE = 50;
private int ARROW_HSIZE = 10;
private int ARROW_VSIZE = 10;
private int NAME_FONTSIZE = 14;
private int MODIFIER_FONTSIZE = 20;
private int AMOUNT_FONTSIZE = 20;
private int LINE_WIDTH = 2;

private int MAX_DEPTH = 200;
private int MAX_DELAY = 10000;
private int MAX_ZOOM = 200;
private int MAX_GAP_SIZE = 100;

private int MIN_DEPTH = 0;
private int MIN_DELAY = 500;
private int MIN_ZOOM = 50;
private int MIN_GAP_SIZE = 20;

private int DEFAULT_MAX_DEPTH = 40;
private int DEFAULT_DELAY = 500;
private int DEFAULT_ZOOM = 100;
private int DEFAULT_GAP_SIZE = 40;

private bool DEFAULT_SHOW_NAMES = true;

private str DEFAULT_COLOR  = "black";
private str FOUND_COLOR    = "blue";
private str ADDED_COLOR    = "green";
private str REPLACED_COLOR = "red";

private str SELECT_MODUS = "select";
private str APPLY_MODUS = "apply";

loc PATTERNS_DIR = |project://MM-IDE/test/patterns|;

//reads patterns from the pattern directory
public list[Pattern] readPatterns()
{
  list[str] entries = listEntries(PATTERNS_DIR);
  list[Pattern] patterns = []; 
  for(str entry <- entries)
  {
    loc f = PATTERNS_DIR +"/<entry>"; 
    Tree t = mpl_parse(f);    
    MPL pattern_ast = mpl_implode(t);  
    Pattern p = desugar(pattern_ast);
    patterns += [p];
  }
  return patterns;
}

//analyzes a diagram against a pattern with respect to a minimum of matched elements
private set[tuple[Diagram new, MatchID found, MatchID added, MatchID replaced, MatchExp exps]] analyze
(
  Diagram d, Pattern p, map[str,ID] preMatch, int minMatchedElements
)
{
  set[tuple[Diagram new, MatchID found, MatchID added, MatchID replaced, MatchExp exps]] result = {};

  if(minMatchedElements == 0)
  {
    Matching emptyMatch = <{}, <p.elements, p.constraints, p.parameters>>;
    set[tuple[Diagram new, MatchID found, MatchID added, MatchID replaced, MatchExp exps]] part2 = generate (p, d, emptyMatch);
    result += part2;
    minMatchedElements = 1;
  }
 
  set[Matching] matchings = powerMatch(d, p, preMatch, minMatchedElements);
  for(Matching m <- matchings)
  {
    set[tuple[Diagram new, MatchID found, MatchID added, MatchID replaced, MatchExp exps]] part = generate (p, d, m);     
    result += part;
  }

  result = filterDuplicates(result);
  
  return result;
}

private list[tuple[Diagram new, MatchID found, MatchID added, MatchID replaced, MatchExp exps]] filterDecisions
(
  set[tuple[Diagram new, MatchID found, MatchID added, MatchID replaced, MatchExp exps]] decisions,
  MatchID choice
)
{
  list[tuple[Diagram new, MatchID found, MatchID added, MatchID replaced, MatchExp exps]] filteredDecisions = [];
  for(tuple[Diagram new, MatchID found, MatchID added, MatchID replaced, MatchExp exps] decision <- decisions)
  { 
    if(choice <= decision.found + decision.added)
    {
      filteredDecisions += [decision];
    }   
  }
  return filteredDecisions;
}

public void mm_visualize
(
  loc mmt_loc,
  Diagram diagram
)
{
 //----------------------------------------------------------------------------
  //Locals used in the visualization.
  //----------------------------------------------------------------------------  
  int zoom = DEFAULT_ZOOM;
  int gapSize = DEFAULT_GAP_SIZE;
  str modus = SELECT_MODUS;
  bool showNames = true; 
  bool showDiagram = true;
  bool newModus = true;
  bool newGraph = true;

  list[Pattern] patterns = readPatterns();
  Pattern pattern = patterns[0];
  
  MatchID choice = ();
  
  //current map of edits
  //used to (re)construct the current diagram
  //together with the current decision
  map[str role, Element element] edits =  ();
  
  str explanation = "";
  
  int decisionPos = 0;  
  int minMatchedElements = size(pattern.elements);
  
  set[tuple[Diagram new, MatchID found, MatchID added, MatchID replaced, MatchExp exps]]
     calculated = {};  
  
  list[tuple[Diagram new, MatchID found, MatchID added, MatchID replaced, MatchExp exps]]
     filtered = [];
  
  tuple[Diagram new, MatchID found, MatchID added, MatchID replaced, MatchExp exps]
     decision = <diagram, (), (), (), ()>;


 //-----------------------------------------------------------------------------
  //Edit Model Transformations
  //---------------------------------------------------------------------------- 
  private void setWhen(str role, "passive")
  {
    edits[role].when = when_pasive();
    edit();
  }

  private void setWhen(str role, "user")
  {
    edits[role].when = when_user();
    edit();
  }

  private void setWhen(str role, "auto")
  {
    edits[role].when = when_auto();
    edit();    
  }
  
  private void setWhen(str role, "start")
  {
    edits[role].when = when_start();
    edit();    
  }  
  
  private void setAct(str role, "pull")
  {
    edits[role].act = act_pull();
    edit();    
  }
  
  private void setAct(str role, "push")
  {
    edits[role].act = act_push();
    edit();    
  }

  private void setHow(str role, "any")
  {
    edits[role].how = how_any();
    edit();    
  }
  
  private void setHow(str role, "all")
  {
    edits[role].how = how_all();
    edit();    
  }
    
  private void setNodeName(str role, str name)
  {
    ID oldName = edits[role].name;
    ID newName = lang::mm::AST::id(name);
    //collect edges pointing to the node
    set[Element] replace =
      {e | e: e_edge (_, _, oldName, _, _) <- decision.new.elements} +
      {e | e: e_edge (_, _, _, _, oldName) <- decision.new.elements};      
      
    for(Element ex: e_edge (EdgeType edgeType, ID edgeName, ID src, Exp exp, oldName) <- replace)
    {
      for(str role <- edits)
      {
        if(edits[role] == ex)
        {
          edits[role] = e_edge (edgeType, edgeName, src, exp, newName);
        }
      }
    }
    
    for(Element ex: e_edge (EdgeType edgeType, ID edgeName, oldName, Exp exp, ID tgt) <- replace)
    {
      for(str role <- edits)
      {
        if(edits[role] == ex)
        {
          edits[role] = e_edge (edgeType, edgeName, newName, exp, tgt);
        }
      }
    }
    
    //FIXME expression references!
  
    decision.new.elements -= replace;
  
    decision.new.elements +=
      {e_edge (edgeType, edgeName, newName, exp, tgt) | e_edge (EdgeType edgeType, ID edgeName, oldName, Exp exp, ID tgt) <- replace} +
      {e_edge (edgeType, edgeName, src, exp, newName) | e_edge (EdgeType edgeType, ID edgeName, ID src, Exp exp, oldName) <- replace};
  
    //find the parameter name inside the elements of the pattern
           
    edits[role].name = newName;
    edit();
  }
  
  //retrieve the role of an expression name...
  //assumes it only appears once
  private ID getRole(Pattern p, ID expName)
  {
    lang::mm::AST::ID r = lang::mm::AST::id("null");  
    for(e_edge (EdgeType edgeType, ID edgeName, oldName, Exp exp, ID tgt) <- p.elements)
    {
      if(e_var(expName.name) == exp)
      {
        r = edgeName;
        break;
      }
    }
    return r;
  }
  
  private void setNodeType(str role, "pool")
  {
    edits[role].nodeType = t_pool();
    edit();    
  }

  private void setNodeType(str role, "gate")
  {
    edits[role].nodeType = t_gate();
    edit();    
  }

  private void setNodeType(str role, "source")
  {
    edits[role].nodeType = t_source();
    edit();    
  }

  private void setNodeType(str role, "drain")
  {
    edits[role].nodeType = t_drain();
    edit();    
  }

  private void setNodeType(str role, "converter")
  {
    edits[role].nodeType = t_converter();
    edit();    
  }
  
  private void setEdgeName(str role, str name)
  {
    edits[role].name = lang::mm::AST::id(name);
    edit();
  }
  
  private void setEdgeExp(str role, str exp)
  {
    Exp e = e_one();
    try
      e = mm_implode_exp(mm_parse_exp(exp));   
    catch E:
      println("cannot parse <exp>");
        
    edits[role].exp = e;
    decision.exps =  ("<param.name>": edits[getRole(pattern, param).name].exp | param <- pattern.parameters);
    edit();
  }
  
  private Element getDiagramElement(str name)
  {
    for(Element e <- decision.new.elements)
    {
      if(e.name.name == name)
      {
        return e;
      }
    }
  }
  
  private Element getPatternElement(str role)
  {
    for(Element e <- pattern.elements)
    {
      if(e.name.name == role)
      {
        return e;
      }
    }
  }
 
  //----------------------------------------------------------------------------
  //Declare Model Transformations
  //----------------------------------------------------------------------------  
  private void setDecision(tuple[Diagram new, MatchID found, MatchID added, MatchID replaced, MatchExp exps] newDecision)
  {
    decision = newDecision;
    
    edits = 
      (role : getDiagramElement(decision.added[role].name) | role <- decision.added) +
      (role : getDiagramElement(decision.found[role].name) | role <- decision.found);
      
    calculateExplanation();
    newGraph = true;
  }
  
  private void edit()
  {
    set[ID] replace = {decision.found[role] | role <- decision.found }
                    + {decision.added[role] | role <- decision.added }
                    + {decision.replaced[role] | role <- decision.replaced};
       
    decision.new.elements = {e |  e <- decision.new.elements, e.name notin replace}
                          + {edits[role] | role <- edits };
                          
    decision.found    = (role : edits[role].name | role <- decision.found);
    decision.added    = (role : edits[role].name | role <- decision.added);
    decision.replaced = (role : edits[role].name | role <- decision.replaced);
    
    calculateExplanation();
    newGraph = true; 
  }
  
  private void selectChoice(str role, str select)
  {
    if(select == "_")
    {
      if(role in choice)
      {
        println("removing <role> from choice <choice>");
        choice = choice - (role : choice[role]);
      }
    }
    else
    {
      for(Element e <- diagram.elements)
      {
        if(e.name.name == select)
        {
          choice[role] = e.name;
          break;
        }
      }
    }
    filtered = filterDecisions(calculated, choice);
    decisionPos = 0;
    if(size(filtered) != 0)
    {
      setDecision(filtered[0]);
    }    
  }
   
  private void analyze()
  {
    calculated = analyze(diagram, pattern, choice, minMatchedElements);
    filtered = filterDecisions(calculated, ());
    if(size(filtered) != 0)
    {
      setDecision(filtered[0]);
    }
  }
    
  private void reset()
  {
    choice = ();
    calculated = {};
    filtered = [];
    setDecision(<diagram, (), (), (), ()>);
  }
 
  private void previous()
  {
    if(decisionPos > 0)
    {
      decisionPos -=1;
      setDecision(filtered[decisionPos]);
    }
  }

  private void next()
  {
    if(decisionPos < size(filtered)-1)
    {
      decisionPos +=1;
      setDecision(filtered[decisionPos]);
    }
  }
  
  private void apply()
  {
     diagram = decision.new;
     modus = APPLY_MODUS;
     newModus = true;
     newGraph = true;
     //reset();
  }
  
  private void finalize()
  {
    diagram = decision.new;
    
    writeFile(mmt_loc, toString(diagram));
    println(toString(diagram));
    modus = SELECT_MODUS;
    newModus = true;
    reset();
  }
  
  private void calculateExplanation()
  {
    explanation =
      "intent: <pattern.intent>\nuse when: <pattern.useWhen>";
    explanation = replaceAll(explanation, "\"", "");    

    MatchID matching = decision.found + decision.added;  
  
    for(str role <- matching)
    {
      explanation = replaceAll(explanation, "\<<role>\>", "<matching[role].name>");
    }
    
    for(str exp <- decision.exps)
    {
      explanation = replaceAll(explanation, "\<<exp>\>", "<toString(decision.exps[exp])>");
    }    
  }
  
  //calculateExplanation();
    
    
  //----------------------------------------------------------------------------
  //Declare Generative Controls
  //Note: top controls are regenerated to avoid rendering artifacts.
  //---------------------------------------------------------------------------- 
  private Figure controls()
  {
    Figure topControls = generalControls(patterns);
    Figure btmControls = box();
    
    switch(modus)
    {
      case SELECT_MODUS:
      {
        btmControls = vcat([patternControls(), decisionControls()]);
      }
      case APPLY_MODUS:
      {
        btmControls = applyControls();
      }
    }
       
    return vcat
    (
      [
        topControls,
        btmControls
      ],
      top(),
      halign(0.5),
      hshrink(0.96)
    );
  }
  
  //----------------------------------------------------------------------------
  //Declare Apply and Value Controls
  //----------------------------------------------------------------------------     
  private list[Figure] valueControls
  (
    Element role: e_edge(EdgeType p_edgeType, ID p_name, ID p_src, Exp p_exp, ID p_tgt),
    Element dval: e_edge(EdgeType d_edgeType, ID d_name, ID d_src, Exp d_exp, ID d_tgt)
  )
  =   [
        text
        (
          "<role.name.name>",
          fontBold(true),
          left(),
          top()
        ),
        space(),
        space(),
        textfield
        (
          toString(d_exp),
          void(str exp){ setEdgeExp(role.name.name, exp); },
          bool(str exp){ setEdgeExp(role.name.name, exp); return true; }
        ),
        space(),
        textfield
        (
          d_name.name,
          void(str name){ setEdgeName(role.name.name, name);},
          bool(str name){ setEdgeName(role.name.name, name); return true; }
        )
      ];

  private Figure valueControls(str role, t_var(), NodeType d_nodeType)
  = combo
    (
      ["pool", "gate", "source", "drain", "converter"],
      void(str nodeType)
      {
        setNodeType(role, nodeType);
      }
    );
    
  private Figure valueControls(str role, when_var(), When d_when)
  = combo
    (
      ["passive", "user", "auto", "start"],
      void(str when)
      {
        setWhen(role, when);
      }
    );
      
  private Figure valueControls(str role, act_var(), Act d_act)
  = combo
    (
      ["pull", "push"],
      void(str act)
      {
        setAct(role, act);
      }
    );
    
  private Figure valueControls(str role, how_var(), How d_how)
  = combo
    (
      ["any", "all"],
      void(str how)
      { 
        setHow(role, how);
      }
    );
   
  private Figure valueControls(str role, NodeType p_nodeType, NodeType d_nodeType)
  = text
    (
      toString(p_nodeType),
      top(),
      left()     
    );
    
  private Figure valueControls(str role, When p_when, When d_when)
  = text
    (
      toString(p_when),
      top(),
      left()   
    );
  
  private Figure valueControls(str role, Act p_act, Act d_act)
  = text
    (
      toString(p_act),
      top(),
      left()
    );
  
  private Figure valueControls(str role, How p_how, How d_how)
  = text
    (
      toString(p_how),
      top(),
      left()
    );

  private list[Figure] valueControls
  (
    Element role: e_node(NodeType p_nodeType, When p_when, Act p_act, How p_how, ID p_name, Category p_cat),
    Element dval: e_node(NodeType d_nodeType, When d_when, Act d_act, How d_how, ID d_name, Category d_cat)
  )
  =   [
         text
         (
           "<role.name.name>",
           fontBold(true),
           top(),
           left()
         ),
         valueControls(role.name.name, p_when, d_when),
         valueControls(role.name.name, p_act, d_act),
         valueControls(role.name.name, p_how, d_how),     
         valueControls(role.name.name, p_nodeType, d_nodeType),
         textfield
         (
           dval.name.name, //default or current value
           void(str name)
           {
             setNodeName(role.name.name, name);
           }//,
           //bool(str name)
           //{
             //setNodeName(role.name.name, name);
             //return true;
           //}
         )
     ];
 
  private Figure applyControls()
  = vcat
    (
      [
        text
        (
          "Apply Controls",
          fontBold(true)
        ),
        grid
        (
          [
            valueControls(getPatternElement(name), getDiagramElement(decision.added[name].name)) | name <- decision.added 
          ]
          +
          [
            valueControls(getPatternElement(name), getDiagramElement(decision.found[name].name)) | name <- decision.found 
          ]
          +
          [
            [
              button
              (
                "Finalize",
                void() { finalize(); }
              )
            ]
          ]
        )
      ]
    );

  //----------------------------------------------------------------------------
  //Declare General Controls
  //---------------------------------------------------------------------------- 
  private Figure generalControls(list[Pattern] patterns)
  = vcat
    (
      [
        text
        (
          "MeDeA",
          fontSize(14),
          fontBold(true)
        ),
        text
        (
          "Mechanics Design Assistant",
          fontSize(12),
          fontBold(true)
        ),
        text
        (
          "Graph Options",
          fontBold(true)
          //,height(25)
        ),
        grid
        (
          [
            [
              text
              (
                str () { return "Zoom:  <zoom>"; },
                left()
              ),
              scaleSlider
              (
                int () { return MIN_ZOOM; },
                int () { return MAX_ZOOM; },
                int () { return zoom; },
                void (int curZoom) { zoom = curZoom; newGraph = true;},
                left()           
              )
            ],
            [
              text
              (
                str () { return "Gap Size:  <gapSize>"; },
                left()
              ),
              scaleSlider
              (
                int () { return MIN_GAP_SIZE; },
                int () { return MAX_GAP_SIZE; },
                int () { return gapSize; },
                void (int curGapSize) { gapSize = curGapSize; newGraph = true;},
                left()              
              )
            ],
            [           
              checkbox
              (
                "Hide Names",
                void(bool showNamesState){ showNames = !showNamesState; newGraph = true; }
              ),
              checkbox
              (
                "Show Pattern",
                void(bool showDiagramState){ showDiagram = !showDiagramState; newGraph = true; }
              )
            ],
            [
              text
              (
                "Select Pattern:",
                left()
              ),
              combo
              (
                ["<p.name.name>" | Pattern p <- patterns],
                void(str s)
                {
                  for(Pattern p <- patterns)
                  {
                    if(p.name.name == s)
                    {                  
                      pattern = p;
                      decisionPos = 0;
                      minMatchedElements = size(pattern.elements);
                      newModus = true;
                      setDecision(<diagram, (), (), (), ()>);
                      break;
                    }
                  }
                }
              )           
            ]
          ]          
        )
      ],
      top(),     
      vshrink(0.3)
    );


  private list[Figure] roleControls(Element role: e_node (_,_,_,_,_,_))
  = [
      text
      (
        "<role.name.name>",
        left(),
        top()
      ),
      combo
      (
        ["_"] + ["<e.name.name>" | Element e: e_node (_,_,_,_,_,_) <- diagram.elements],
        void(str select)
        {
          selectChoice(role.name.name, select);
        },
        top()
      )
    ];
    
  private list[Figure] roleControls(Element role: e_edge(_,_,_,_,_))
  = [
      text
      (
        "<role.name.name>",
        left(),
        top()
      ),
      combo
      (
        ["_"] + ["<e.name.name>" | Element e: e_edge(_,_,_,_,_) <- diagram.elements],
        void(str select)
        {
          selectChoice(role.name.name, select);
        },
        top()        
      )
    ]; 
    

  //----------------------------------------------------------------------------
  //Declare Pattern Controls
  //----------------------------------------------------------------------------   
  private Figure patternControls()
  = vcat
    (
      [
        text
        (
          "<pattern.name.name> Controls",
          fontBold(true)
          //,height(25)
        ),
        grid
        (
          [
            [
              text
              (
                str () { return "Minimum Match Size: <minMatchedElements>"; },
                left(),
                height(10)
              ),
              scaleSlider
              (
                int () { return 0; },
                int () { return size(pattern.elements); },
                int () { return minMatchedElements; },
                void (int matchedElements) { minMatchedElements = matchedElements; },
                left()
              )
            ],
            [
              button
              (
                "Reset",
                void(){ reset(); }
              ),
              button
              (
                "Analyze",
                void() { analyze(); }
              ) 
            ]               
          ]
        )
      ],
      top(),     
      vshrink(0.2)      
    );
      
  private Figure decisionControls()
  = vcat
    (
      [     
        text
        (
          "Restrict Decisions",
          fontBold(true)
          //,height(25)
        ),        
        grid
        (
          [
            [
              text
              (
                "Decisions: ",
                left()
                //,height(20)
              ),
              text
              (
                str () { return "<size(filtered)> of <size(calculated)>"; },
                left()
              )
            ],
            [
              text
              (
                "Displayed: ",
                left()
                //,height(20)
              ),
              text
              (
                str () { return "<decisionPos+1> of <size(filtered)>"; },
                left()
              )
            ]        
          ]
          +
          [roleControls(e) | Element e <- pattern.elements]
          +
          [       
            [
              button
              (
                "Previous",
                void() { previous(); }
              ),
              button
              (
                "Next",
                void() { next(); }
              )
            ],
            [
              button
              (
                "Apply",
                void() { apply(); }
              )
            ]                        
          ]
        )
      ],
      top()     
      //,vshrink(0.50)      
    );    

  //----------------------------------------------------------------------------
  //Render Controls
  //----------------------------------------------------------------------------
  render
  (
    hcat
    (
      [
        vcat
        (
          [
            scrollable
            (
              computeFigure
              (
                bool(){ if(newGraph == true){ newGraph = false; return true; } else { return false; } },
                Figure ()
                {
                  if(showDiagram)
                  {
                    return toGraph(decision, toReal(zoom)/100.0, gapSize, showNames);
                  }
                  else
                  {
                    lang::mm::AST::Diagram patternDiagram = lang::mm::AST::diagram(pattern.elements);
                    
                    return toGraph(<patternDiagram,(),(),(),()>, toReal(zoom)/100.0, gapSize, showNames);
                  }
                },
                top()
              ),
              vshrink(real(){ return 0.75; })
            ),
            scrollable
            (
              text
              (
                str(){ return explanation; }, //return getExplanation(pattern, decision); },
                fontSize(16),
                fontColor(color("black")),
                left()
              ),
              vshrink(0.25)
            )
          ],
          hshrink(0.6)    
        ),
        box
        (
          computeFigure
          (
            bool(){ if(newModus == true){ newModus = false; return true; } else { return false; } },
            Figure(){ return controls(); },
            top()
          ),
          hshrink(0.4)
        )
      ]
    )
  );  
}





private str color(ID name, MatchID found, MatchID added, MatchID replaced)
{
  str color = DEFAULT_COLOR;
  if(name in range(found))
  {
    color = FOUND_COLOR;
  }
  if(name in range(added))
  {
    color = ADDED_COLOR;
  }
  if(name in range(replaced))
  {
    color = REPLACED_COLOR;
  }
  return color;
}

private str role(ID name, MatchID found, MatchID added, MatchID replaced)
{
  str ret = "";
  
  MatchID roles = found + added;
  
  for(str role <- roles)
  {
    if(roles[role] == name)
    {
      ret = role;
      break;
    }
  }
  
  return ret;
}

public Figure toGraph
(
  tuple[Diagram new, MatchID found, MatchID added, MatchID replaced, MatchExp exps] decision,
  real zoom, int gapSize, bool showNames
)
{
  Figures ns = []; //nodes
  Edges es = []; //edges
  
  Diagram d = decision.new;
  
  for(Element e <- d.elements)
  {  
    if(e_node(NodeType nodeType, When when, Act act, How how, ID name, Category cat) := e)
    {    
      ns += nodeToFigure(e, role(name, decision.found, decision.added, decision.replaced),
                         zoom, showNames, color(name, decision.found, decision.added, decision.replaced));
    }
    if(e_edge(EdgeType edgeType, ID name, ID src, Exp exp, ID tgt) := e)
    {
      es += edgeToFigure(e, role(name, decision.found, decision.added, decision.replaced),
                         zoom, showNames, color(name, decision.found, decision.added, decision.replaced));
    }
  }
  
  return graph (ns, es, hint("layered"), gap(toInt(gapSize * zoom)), vshrink(0.8));
}

//------------------------------------------------------------------------------
//Edge Figures
//------------------------------------------------------------------------------
Figure edgeNameFigure(Element e: e_edge (EdgeType edegeType, ID name, ID src, Exp exp, ID tgt),
  str role, real zoom, bool showNames, str color)
{
  Figure nameFigure = space();
  if(showNames == true)
  {
    nameFigure =
      text
      (
        "<if(role!=""){><role> = <}><e.name.name>: <toString(exp)>",
        fontSize(toInt(NAME_FONTSIZE * zoom)),
        fontColor(color)       
      );
  }
  return nameFigure;
}

private Edge edgeToFigure(Element e: e_edge (t_flow(), ID name, ID src, Exp exp, ID tgt),
  str role, real zoom, bool showNames, str color)
= edge
  (
    src.name,
    tgt.name,
    toArrow(arrowHead(color)),
    label(edgeNameFigure(e, role, zoom, showNames, color)),
    lineWidth(LINE_WIDTH),
    lineColor(color)
    //,mouseOver(text(toString(exp)))
  );

private Edge edgeToFigure(Element e: e_edge (t_state(), ID name, ID src, Exp exp, ID tgt),
  str role, real zoom, bool showNames, str color)
= edge
  (
    src.name,
    tgt.name,
    toArrow
    (
      arrowHead(color)
    ),
    label(edgeNameFigure(e, role, zoom, showNames, color)),
    lineWidth(LINE_WIDTH),
    lineColor(color),
    lineStyle("dash")
    //,mouseOver(text(toString(exp)))
  );

//------------------------------------------------------------------------------
//Node Figures
//------------------------------------------------------------------------------
private Figure nodeToFigure(Element e, str role, real zoom, bool showNames, str color)
{
  Figure nameFigure = space();
  
  if(showNames == true)
  {
    nameFigure =
    text
    (
      "<if(role!=""){><role> = <}><e.name.name>",
      fontSize(toInt(NAME_FONTSIZE * zoom)),
      fontColor(color),
      valign(1.75)
    );
  }
  
  return overlay
  (
    [
      overlay
      (
        [
          nodeToSubFigure(zoom,color,e),
          text
          (
            //Hack: adequate alignment
            "               <toVisualString(e.when)><toVisualString(e.act)><toVisualString(e.how)>",
            fontSize(toInt(MODIFIER_FONTSIZE * zoom)),
            fontBold(true),
            fontColor(color),
            align(1.0,0.0),
            mouseOver
            (
              text
              (
                e.name.name,
                fontColor(color),
                fontSize(toInt(NAME_FONTSIZE * zoom)),
                valign(1.0)
              )
            )
          )
        ]
      ),
      nameFigure
    ],
    vis::Figure::id(e.name.name),
    top(), //Hack: center the node vertically
    left() //Hack: center the node horizontally
  );
}
 
//------------------------------------------------------------------------------
//Node Sub-Figures
//------------------------------------------------------------------------------
private Figure nodeToSubFigure(real zoom, str color,  
  e_node  (t_pool(), When when, Act act, How how, ID name, Category cat))
{  
  Figures fs = [pool(1.0 * zoom, color)];

  if(when == when_user())
  {
    fs += [pool(0.8 * zoom, color)];
  }
  
  cat_str = "";
  if(cat(str s) := cat)
  {
    cat_str = s[1..-1];;
  }
  
  fs +=
  [
    text
    (
      cat_str,
      fontBold(true),
      fontSize(toInt(AMOUNT_FONTSIZE * zoom)),
      fontColor(color)
    )
  ];
  
  return overlay(fs);
}

private Figure nodeToSubFigure(real zoom, str color,  
  e_node  (t_var(), when_user(), Act act, How how, ID name, Category cat))
= overlay
  (
    [
      star(1.0 * zoom, color),
      star(0.7 * zoom, color)
    ]
  );
  
private Figure nodeToSubFigure(real zoom, str color,  
  e_node  (t_var(), When when, Act act, How how, ID name, Category cat))
= star(1.0 * zoom, color);

private Figure nodeToSubFigure(real zoom, str color,  
  e_node  (t_gate(), when_user(), Act act, How how, ID name, Category cat))
= overlay
  (
    [
      gate(1.0 * zoom, color),
      gate(0.7 * zoom, color)
    ]
  );
  
private Figure nodeToSubFigure(real zoom, str color,  
  e_node  (t_gate(), When when, Act act, How how, ID name, Category cat))
= gate(1.0 * zoom, color);

private Figure nodeToSubFigure(real zoom, str color,  
  e_node  (t_source(), when_user(), Act act, How how, ID name, Category cat))
= overlay
  (
    [
      source(1.0 * zoom, color),
      source(0.7 * zoom, color)
    ]
  );

private Figure nodeToSubFigure(real zoom, str color,  
  e_node  (t_source(), When when, Act act, How how, ID name, Category cat))
= source(1.0 * zoom, color);

private Figure nodeToSubFigure(real zoom, str color,  
  e_node  (t_drain(), when_user(), Act act, How how, ID name, Category cat))
= overlay
  (
    [
      drain(1.0 * zoom, color),
      drain(0.7 * zoom, color)
    ]   
  );

private Figure nodeToSubFigure(real zoom, str color,  
  e_node  (t_drain(), When when, Act act, How how, ID name, Category cat))
= drain(1.0 * zoom, color);


private Figure nodeToSubFigure(real zoom, str color,  
  e_node  (t_converter(), when_user(), Act act, How how, ID name, Category cat))
= overlay
  (
    [
      converter(1.0 * zoom, color),
      converter(0.7 * zoom, color),
      overlay
      (
        [point(x,y) | <x,y> <- [<0.4,0.0>,<0.4,1.0>]],           
        shapeConnected(true),
        //shapeClosed(true),
        size(NODE_HSIZE, NODE_VSIZE),
        lineWidth(LINE_WIDTH),
        lineColor(color)
      )
    ]
  );

private Figure nodeToSubFigure(real zoom, str color,  
  e_node  (t_converter(), When when, Act act, How how, ID name, Category cat))
= overlay
  (
    [
      converter(1.0 * zoom, color),
      overlay
      (
        [point(x,y) | <x,y> <- [<0.4,0.0>,<0.4,1.0>]],           
        shapeConnected(true),
        //shapeClosed(true),
        size(NODE_HSIZE, NODE_VSIZE),
        lineWidth(LINE_WIDTH),
        lineColor(color)
      )
    ]
  );

private Figure nodeToSubFigure(real zoom, str color, Element e)
{
  throw "cannot make <e> into figure";
}

//------------------------------------------------------------------------------
//Basic Visual Elements
//------------------------------------------------------------------------------
private Figure point(real x, real y)
= ellipse
  (
    align(x,y)
  );

private Figure star(real scale, str color)
= overlay
  (
    [point(x,y) | <x,y> <-
      [<0.0, 0.425>, <0.375, 0.375>,
       <0.5, 0.050>, <0.625, 0.375>,
       <1.0, 0.425>, <0.750, 0.625>,
       <0.8, 0.950>, <0.500, 0.750>,
       <0.2, 0.950>, <0.250, 0.625>, <0.0, 0.425>]],         
    shapeConnected(true),
    shapeClosed(true),
    size(NODE_HSIZE * scale, NODE_VSIZE * scale),
    lineWidth(LINE_WIDTH),
    lineColor(color)
  );
  
private Figure pool(real scale, str color)
= ellipse
  (
    size(NODE_HSIZE * scale, NODE_VSIZE * scale),
    lineWidth(LINE_WIDTH),
    lineColor(color) 
  );


private Figure converter(real scale, str color)
= overlay
  (
    [   
      overlay
      (      
        [point(x,y) | <x,y> <- [<0.0,0.0>,<0.0,1.0>,<1.0,0.5>]],     
        shapeConnected(true),
        shapeClosed(true),
        size(NODE_HSIZE * scale, NODE_VSIZE * scale),
        lineWidth(LINE_WIDTH),
        lineColor(color)
      )      
    ] 
  );

private Figure gate(real scale, str color)
= overlay
  (
    [point(x,y) | <x,y> <- [<0.5,0.0>,<1.0,0.5>,<0.5,1.0>,<0.0,0.5>,<0.5,0.0>]],           
    shapeConnected(true),
    shapeClosed(true),
    size(NODE_HSIZE * scale, NODE_VSIZE * scale),
    lineWidth(LINE_WIDTH),
    lineColor(color)
  );

private Figure source(real scale, str color)
= overlay
  (
    [point(x,y) | <x,y> <- [<0.5,0.0>,<1.0,1.0>,<0.0,1.0>]],           
    shapeConnected(true),
    shapeClosed(true),
    size(NODE_HSIZE * scale, NODE_VSIZE * scale * 0.8),
    lineWidth(LINE_WIDTH),
    lineColor(color) 
  );

private Figure drain(real scale, str color)
= overlay
  (
    [point(x,y) | <x,y> <- [<0.0,0.0>,<1.0,0.0>,<0.5,1.0>]],           
    shapeConnected(true),
    shapeClosed(true),
    size(NODE_HSIZE * scale, NODE_VSIZE * scale * 0.8),
    lineWidth(LINE_WIDTH),
    lineColor(color)   
  );

private Figure arrowHead(str color)
= headNormal
  (
    size(ARROW_HSIZE, ARROW_VSIZE),
    lineWidth(LINE_WIDTH),
    lineColor(color)
  );
       
//------------------------------------------------------------------------------
//Basic Textual Elements
//------------------------------------------------------------------------------
public str toVisualString(when_var())     = "";
public str toVisualString(when_passive()) = "";
public str toVisualString(when_user())    = "";
public str toVisualString(when_auto())    = "*";
public str toVisualString(when_start())   = "s";
public str toVisualString(act_var())      = "";
public str toVisualString(act_pull())     = "";
public str toVisualString(act_push())     = "p";
public str toVisualString(how_var())      = "";
public str toVisualString(how_any())      = "";
public str toVisualString(how_all())      = "&";