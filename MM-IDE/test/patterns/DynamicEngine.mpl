pattern DynamicEngine (IncomeExp, CostExp, BenefitExp, SpendExp) //extends Acquisition
  intent "Dynamic Engine: Source <Producer> produces an adjustable
  flow <Income> of <IncomeExp> resources. Players can invest using
  converter <Invest> to improve the flow."  
  useWhen "Apply Dynamic Engine for introducing a trade-off between
  spending currency <Energy> on long term investment <Invest>
  and short term gains <Act>."
{
  source Producer //is activatable //activatable: otherwise no income  (user or triggered)
  
  pool Energy is "$"
  pool Upgrades is "+"  
  user converter Invest
  user node Act
  
  Income:  Producer -IncomeExp-> Energy
  Cost:    Energy -CostExp-> Invest
  Benefit: Invest -BenefitExp-> Upgrades
  Spend:   Energy -SpendExp-> Act
    
  exp (Upgrades) => IncomeExp: monotonic +
}