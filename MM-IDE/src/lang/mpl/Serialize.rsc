@license{
  Copyright (c) 2009-2015 CWI / HvA
  All rights reserved. This program and the accompanying materials
  are made available under the terms of the Eclipse Public License v1.0
  which accompanies this distribution, and is available at
  http://www.eclipse.org/legal/epl-v10.html
}
/*****************************************************************************/
/*!
* Micro-Machinations Patterns Serialization (note: different defaults!)
* @package      lang::mmp
* @file         Serialize.rsc
* @brief        Defines the Micro-Machinations Patterns serialization.
* @contributor  Riemer van Rozen - rozen@cwi.nl - HvA, CREATE-IT / CWI
* @date         February 5th 2015
* @note         Language: Rascal
*/
/*****************************************************************************/
module lang::mpl::Serialize

//import List;
//import IO;
//import Node;
//import String;
//import util::Math;
import lang::mm::AST;
import lang::mpl::AST;

public str toString(diagram(set[Element] elements))
  = "<for(e <- elements){><toString(e)>\n<}>";

public str toString(pattern(ID name, str intent, str useWhen, set[ID] parameters, set[Element] elements, set[Constraint] constraints))
  = ""; //TODO

public str toString(constraint(ID var, ID expName, Monotonic mon))
  = ""; //TODO

public str toString(e_node(t_var(), When when, Act act, How how, ID name, Category cat))
  = "<toString(when,act,how)>node <toString(name)><if(toString(cat)!=""){><toString(cat)><}>";

public str toString(e_node(t_pool(), When when, Act act, How how, ID name, Category cat))
  = "<toString(when,act,how)>pool <toString(name)><if(toString(cat)!=""){><toString(cat)><}>";

public str toString(e_node(t_gate(), When when, Act act, How how, ID name, Category cat))
  = "<toString(when,act,how)>gate <toString(name)><if(toString(cat)!=""){><toString(cat)><}>";

public str toString(e_node(t_source(), When when, Act act, How how, ID name, Category cat))
  = "<toString(when,act,how)>source <toString(name)><if(toString(cat)!=""){><toString(cat)><}>";

public str toString(e_node(t_drain(), When when, Act act, How how, ID name, Category cat))
  = "<toString(when,act,how)>drain <toString(name)><if(toString(cat)!=""){><toString(cat)><}>";

public str toString(e_node(t_converter(), When when, Act act, How how, ID name, Category cat))
  = "<toString(when,act,how)>converter <toString(name)><if(toString(cat)!=""){><toString(cat)><}>";

public str toString(When when, Act act, How how)
  = "<if(toString(when) != ""){><toString(when)> <}><if(toString(act) != ""){><toString(act)> <}><if(toString(how) != ""){><toString(how)> <}>";

public str toString(e_edge  (t_flow(), ID name, ID src, Exp exp, ID tgt))
  = "<toString(name)> : <toString(src)> - <toString(exp)> -\> <toString(tgt)>";
  
public str toString(e_edge (t_state(), ID name, ID src, Exp exp, ID tgt))
  = "<toString(name)> : <toString(src)> . <toString(exp)> .\> <toString(tgt)>";

str toString(pos_none())
  = "";

str toString(pos(int x, int y))
  = "@(<x>,<y>)";

str toString(at_none())
  = "";
  
str toString(at_val(int v))
  = "at <v>";

str toString(add_none())
  = "";
  
str toString(add_exp(Exp exp))
  = "(<toString(exp)>)";
  
str toString(max_none())
  = "";
  
str toString(max_val(int v))
  = "max <v>";

str toString(when_var())
  = "";

str toString(when_passive())
  = "passive";

str toString(when_user())
  = "user";

str toString(when_auto())
  = "auto";

str toString(when_start())
  = "start";

str toString(act_var())
  = "";

str toString(act_pull())
  = "pull";

str toString(act_push())
  = "push";
  
str toString(how_var())
  = "";
  
str toString(how_any())
  = "any";

str toString(how_all())
  = "all"; 
  
str toString(cat_var())
  = "";

str toString(cat(str name))
  = "is <name>";

//-----------------------------

public str toString(e_trigger())
  = "*";
  
public str toString(e_ref())
  = "=";

public str toString(e_range(int low, int high))
  = "<low>..<high>";

public str toString(e_one())
  = "";
 
public str toString(e_percent(Exp e))
  = "<toString(e)> %";

public str toString(e_unm(Exp e))
  = "-<toString(e)>";

public str toString(e_val(real v, list[Unit] opt_u))
{
  if(endsWith("<v>","."))
  {
    return "<toInt(v)>";
  }
  else
  {
    return "<v>";
  }
}

public str toString(e_all())
  = "all";
 
public str toString(e_override(Exp e))
  = "( <toString(e)> )";

public str toString(e_name(list[ID] names))
  = toString(names);

public str toString(e_name(ID name))
  = toString(name);
  
public str toString(e_active(list[ID] names))
  = "active <toString(names)>";

public str toString(e_active(ID name))
  = "active <toString(name)>";

public str toString(e_true())
  = "true";

public str toString(e_false())
  = "false";

public str toString(e_lt(Exp e1, Exp e2))
  = "<toString(e1)> \< <toString(e2)>";
  
public str toString(e_gt(Exp e1, Exp e2))
  = "<toString(e1)> \> <toString(e2)>";
  
public str toString(e_le(Exp e1, Exp e2))
  = "<toString(e1)> \<= <toString(e2)>";
  
public str toString(e_ge(Exp e1, Exp e2))
  = "<toString(e1)> \>= <toString(e2)>";
  
public str toString(e_neq(Exp e1, Exp e2))
  = "<toString(e1)> != <toString(e2)>";

public str toString(e_eq(Exp e1, Exp e2))
  = "<toString(e1)> == <toString(e2)>";

public str toString(e_and(Exp e1, Exp e2))
  = "<toString(e1)> && <toString(e2)>";
  
public str toString(e_or(Exp e1, Exp e2))
  = "<toString(e1)> || <toString(e2)>";

public str toString(e_not(Exp e))
  = "! <toString(e)>";

public str toString(e_mul(Exp e1, Exp e2))
  = "<toString(e1)> * <toString(e2)>";

public str toString(e_div(Exp e1, Exp e2))
  = "<toString(e1)> / <toString(e2)>";

public str toString(e_add(Exp e1, Exp e2))
  = "<toString(e1)> + <toString(e2)>";

public str toString(e_sub(Exp e1, Exp e2))
  = "<toString(e1)> - <toString(e2)>";

public str toString(ID id)
  = id.name;

//------------------------------------------------------------
// Fall through cases...
//------------------------------------------------------------
public str toString(Diagram d)
{
  throw "Diagram <d> cannot be serialized."; 
}

public str toString(Element e)
{
  throw "Element <e> cannot be serialized."; 
}

public str toString(At at)
{
  throw "At <at> cannot be serialized.";
}

public str toString(Add add)
{
  throw "Add <add> cannot be serialized.";
}

public str toString(Min min)
{
  throw "Min <min> cannot be serialized.";
}

public str toString(Max max)
{
  throw "Max <max> cannot be serialized.";
}

public str toString (e_var(str name))
  = name;  


//fall through cases

public str toString(MM mm)
{
  throw "MM <mm> cannot be serialized";
}

public str toString(MPL mpl)
{
  throw "MPL <mpl> cannot be serialized";
}

public str toString(Diagram d)
{
  throw "Diagram <d> cannot be serialized";
}

public str toString(Pattern p)
{
  throw "Pattern <p> cannot be serialized";
}

public str toString(Constraint c)
{
  throw "Constraint <c> cannot be serialized";
}

public str toString(NodeType t)
{
  throw "NodeType <t> cannot be serialized";
}

public str toString(EdgeType t)
{
  throw "EdgeType <t> cannot be serialized";
}

public str toString(Element e)
{
  throw "Element <e> cannot be serialized";
}

public str toString(Pos pos)
{
  throw "Pos <pos> cannot be serialized";
}

public str toString(At at)
{
  throw "At <at> cannot be serialized";
}

public str toString(add add)
{
  throw "Add <add> cannot be serialized";
}

public str toString(Max max)
{
  throw "Max <max> cannot be serialized";
}

public str toString(When when)
{
  throw "When <when> cannot be serialized.";
}

public str toString(Act act)
{
  throw "Act <act> cannot be serialized.";
}

public str toString(How how)
{
  throw "How <how> cannot be serialized.";
}

public str toString(Category cat)
{
  throw "Category <cat> cannot be serialized.";
}

public str toString(Exp exp)
{
  throw "Exp <exp> cannot be serialized.";
}

public str toString(ID id)
{
  throw "ID <id> cannot be serialized.";
}
