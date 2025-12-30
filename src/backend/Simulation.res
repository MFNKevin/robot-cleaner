// Orchestration (un pas de simulation)
open Types

/* Configuration par défaut */
let defaultBattery = 5000  // Batterie très large pour exploration exhaustive
let defaultWidth = 8
let defaultHeight = 8
let defaultObstacleDensity = 0.15  // 15% d'obstacles (réduit pour plus d'accès)

/* Crée une simulation initiale avec obstacles */
let create = (width: int, height: int, obstacleDensity: float): Types.simulation => {
  let initialGrid = Grid.createWithObstacles(width, height, obstacleDensity)
  let initialRobot = Robot.create({x: 0, y: 0})
  
  // Initialiser la matrice des visites à 0
  let visited = Array.make(~length=height, [])
  for i in 0 to height - 1 {
    visited[i] = Array.make(~length=width, 0)
  }
  
  {
    grid: initialGrid,
    robot: initialRobot,
    battery: defaultBattery,
    score: 0,
    steps: 0,
    visited: visited,
  }
}

/* Crée une simulation avec paramètres par défaut */
let createDefault = (): Types.simulation => {
  create(defaultWidth, defaultHeight, defaultObstacleDensity)
}

/* Effectue un pas de simulation : nettoyer puis agir selon l'algorithme 
 * Utilise le Pattern Matching pour gérer tous les cas
 */
let step = (sim: Types.simulation): Types.simulation => {
  /* Si batterie épuisée, ne rien faire */
  if sim.battery <= 0 {
    sim
  } else {
    /* Marquer la cellule actuelle comme visitée */
    let {x, y} = sim.robot.position
    Belt.Array.getExn(sim.visited, y)->Belt.Array.setExn(
      x, 
      Belt.Array.getExn(Belt.Array.getExn(sim.visited, y), x) + 1
    )
    
    /* Nettoyer la cellule actuelle (retourne true si nettoyée) */
    let wasCleaned = Grid.cleanCell(sim.grid, sim.robot.position)
    
    /* Décider de la prochaine action avec l'algorithme intelligent */
    let action = Algorithm.explorerStep(sim)
    
    /* Appliquer l'action avec Pattern Matching */
    let (updatedRobot, batteryCost) = switch action {
    | Algorithm.MoveForward => (Robot.moveForward(sim.robot), 1)  // Avancer coûte 1
    | Algorithm.TurnLeft => (Robot.turnLeft(sim.robot), 0)        // Tourner gratuit
    | Algorithm.TurnRight => (Robot.turnRight(sim.robot), 0)
    }
    
    /* Mettre à jour le score si une cellule a été nettoyée */
    let newScore = wasCleaned ? sim.score + 10 : sim.score
    
    {
      ...sim,
      robot: updatedRobot,
      battery: sim.battery - batteryCost,
      score: newScore,
      steps: sim.steps + 1,
    }
  }
}

/* Vérifie si la simulation est terminée */
let isFinished = (sim: Types.simulation): bool => {
  sim.battery <= 0 || Grid.countDirtyCells(sim.grid) == 0
}
