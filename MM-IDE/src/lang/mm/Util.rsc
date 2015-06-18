@license{
  Copyright (c) 2009-2015 CWI / HvA
  All rights reserved. This program and the accompanying materials
  are made available under the terms of the Eclipse Public License v1.0
  which accompanies this distribution, and is available at
  http://www.eclipse.org/legal/epl-v10.html
}
/*****************************************************************************/
/*!
* Utils
* @package      lang::mm
* @file         Util.rsc
* @brief        Defines Utils
* @contributor  Riemer van Rozen - rozen@cwi.nl - HvA, CREATE-IT / CWI
* @date         February 5th 2015
* @note         Language: Rascal
*/
/*****************************************************************************/
module lang::mm::Util

import Node;
import lang::mm::AST;
import lang::mpl::AST;

public &T delAllAnnotations(&T n, str annotation)
= visit(n)
  {
    case node e:
      insert delAnnotation(e, annotation);
  };

public &T delAllAnnotations(&T n)
= visit(n)
  {
    case node e:
      insert delAnnotations(e);
  };
  