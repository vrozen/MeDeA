pattern Acquisition (CostExp, BenefitExp)
  intent  "Acquisition: Converter <Acquire> costs
  <CostExp> resources from <Energy> as specifed by <Cost>
  and yields <BenefitExp> resources in <Property> as specifed by <Benefit>."
  useWhen "Apply Acquisition for introducing a way to spend
  currency <Energy> on proprerty <Property>."
{
  pool Energy is "$"                      //currency spent
  user converter Acquire                  //user acquisition
  pool Property is "+"                    //resource gained
  Cost: Energy -CostExp-> Acquire         //cost
  Benefit: Acquire -BenefitExp-> Property //yield (benefit)
}