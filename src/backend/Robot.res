// État et mouvements du robot
open Types

/* Crée un robot à une position donnée, orienté vers le Nord */
let create = (startPos: position): robot => {
  position: startPos,
  direction: North,
}

/* Tourne le robot à gauche */
let turnLeft = (robot: robot): robot => {
  let newDirection =
    switch robot.direction {
    | North => West
    | West => South
    | South => East
    | East => North
    }

  {
    ...robot,
    direction: newDirection,
  }
}

/* Tourne le robot à droite */
let turnRight = (robot: robot): robot => {
  let newDirection =
    switch robot.direction {
    | North => East
    | East => South
    | South => West
    | West => North
    }

  {
    ...robot,
    direction: newDirection,
  }
}

/* Calcule la prochaine position sans la modifier */
let nextPosition = (robot: robot): position =>
  switch robot.direction {
  | North => {x: robot.position.x, y: robot.position.y - 1}
  | South => {x: robot.position.x, y: robot.position.y + 1}
  | East => {x: robot.position.x + 1, y: robot.position.y}
  | West => {x: robot.position.x - 1, y: robot.position.y}
  }

/* Avance le robot (sans vérifier les limites) */
let moveForward = (robot: robot): robot => {
  let newPos = nextPosition(robot)

  {
    ...robot,
    position: newPos,
  }
}
