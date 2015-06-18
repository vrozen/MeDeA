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
* @package      lang::mmp
* @file         AST.rsc
* @brief        Defines Machinations Abstract Syntax
* @contributor  Riemer van Rozen - rozen@cwi.nl - HvA, CREATE-IT / CWI
* @date         February 5th 2015
* @note         Language: Rascal
*/
/*****************************************************************************/
module lang::mpl::AST

import lang::mm::AST;
import ParseTree;

/***************************************************************************** 
 * Public APIs
 *****************************************************************************/
public lang::mpl::AST::MPL mpl_implode(Tree tree)
  = implode(#lang::mpl::AST::MPL, tree);

/***************************************************************************** 
 * Source location annotations
 *****************************************************************************/
anno loc MPL@location;
anno loc Pattern@location;
anno loc Constraint@location;

/***************************************************************************** 
 * Micro Machinations AST
 *****************************************************************************/
data MPL
  = pttr(ID name, list[ID] params, str intent, str useWhen, list[Element] elements);

data Pattern
  = pattern(ID name, str intent, str useWhen, set[ID] parameters, set[Element] elements, set[Constraint] constraints);

data Constraint
  = constraint(ID var, ID expName, Monotonic mon);

data Monotonic
  = mNone()
  | mInc()
  | mDec();
