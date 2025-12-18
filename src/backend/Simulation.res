// Orchestration (un pas de simulation)
open Types


/* Crée une simulation initiale */
let create = (size: int): Types.simulation => {
  let initialGrid = Grid.create(size)
  let initialRobot = Robot.create({x: 0, y: 0})
  {
    grid: initialGrid,
    robot: initialRobot,
  }
}

/* Effectue un pas de simulation : nettoyer puis agir selon l'algorithme */
let step = (sim: Types.simulation): Types.simulation => {
  /* Nettoyer la cellule actuelle */
  Grid.cleanCell(sim.grid, sim.robot.position)

  /* Décider de la prochaine action */
  let action = Algorithm.simpleStep(sim)

  /* Appliquer l’action */
  let updatedRobot =
    switch action {
    | Algorithm.MoveForward => Robot.moveForward(sim.robot)
    | Algorithm.TurnLeft => Robot.turnLeft(sim.robot)
    | Algorithm.TurnRight => Robot.turnRight(sim.robot)
    }

  {
    grid: sim.grid,
    robot: updatedRobot,
  }
}
