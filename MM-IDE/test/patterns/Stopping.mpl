pattern Stopping (CostExp, BenefitExp)
  intent  "Stopping: Makes activating converter <Acquire>
  increasingly expensive because flow rate <CostExp>
  on resource edge <Cost> increases
  with the resource amount in pool <Property>."
  useWhen "To prevent a player from abusing <Acquire>,
  the mechanisms effectiveness is reduced every time it is used."
{
  pool Energy is "$"                      //currency spent
  user converter Acquire                  //user acquisition
  pool Property is "+"                    //resource gained
  Cost: Energy -CostExp-> Acquire         //cost
  Benefit: Acquire -BenefitExp-> Property //yield (benefit)
    
  //expression E1 contains B, (B) =>E
  //expression E1 grows monotonic  
  exp (Property) => CostExp: monotonic +
}

