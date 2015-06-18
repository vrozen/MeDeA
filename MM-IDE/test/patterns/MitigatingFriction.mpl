pattern MitigatingFriction (LossExp)
 intent  "Mitigating Friction: Mitigates a loss of resources caused by drain <Lose>,
 because the amount <LoseExp> specfied by resource edge <Lose>
 decreases with the amount of resources owned in pool <Mitigate>."
 useWhen "To enable a player to counter a loss, mitigating the effect."
{
  pool Energy
  pool Migitate is "+"
  auto drain Lose
  Loss: Energy -LossExp-> Lose
  
  exp (Mitigate) => LossExp: monotonic -
}