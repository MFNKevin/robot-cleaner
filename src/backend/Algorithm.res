// Stratégies de nettoyage (v1 simple)
open Types


/* Type d’action que le robot peut faire */
type action =
  | MoveForward
  | TurnLeft
  | TurnRight

/* Stratégie très simple : avancer si possible, sinon tourner à droite */
let simpleStep = (sim: simulation): action => {
  let nextPos = Robot.nextPosition(sim.robot)
  if Grid.isInside(sim.grid, nextPos) {
    MoveForward
  } else {
    TurnRight
  }
}
