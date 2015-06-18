pattern StaticFriction (LossExp)
  intent  "Static Friction: Drain <Lose> causes a loss
  by pulling flow rate <LossExp>
  via resource edge <Loss> from pool <Energy>"
  useWhen "Counter positive effects... TODO"
{
  pool Energy
  auto drain Lose
  Loss: Energy -LossExp-> Lose
}