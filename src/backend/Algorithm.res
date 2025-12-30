// Stratégies de nettoyage (version améliorée avec détection de murs)
open Types


/* Type d'action que le robot peut faire */
type action =
  | MoveForward
  | TurnLeft
  | TurnRight

/* Vérifie si une position est valide (dans la grille et pas un mur) */
let isValidPosition = (sim: simulation, pos: position): bool => {
  switch Grid.getCell(sim.grid, pos) {
  | Some(Wall) => false  // Mur détecté
  | Some(_) => Grid.isInside(sim.grid, pos)  // Position valide
  | None => false  // Hors limites
  }
}

/* Stratégie améliorée : avancer si libre, sinon tourner à droite
 * Pattern Matching pour gérer tous les cas de figure
 */
let simpleStep = (sim: simulation): action => {
  let nextPos = Robot.nextPosition(sim.robot)
  
  switch (Grid.isInside(sim.grid, nextPos), Grid.getCell(sim.grid, nextPos)) {
  | (true, Some(Wall)) => TurnRight  // Mur devant -> tourner
  | (true, Some(_)) => MoveForward   // Cellule libre -> avancer
  | (false, _) => TurnRight          // Bordure -> tourner
  | (_, None) => TurnRight           // Cas impossible mais exhaustif
  }
}

/* Stratégie intelligente : essaie de tourner à gauche si bloqué
 * Permet d'explorer plus efficacement
 */
let smartStep = (sim: simulation): action => {
  let nextPos = Robot.nextPosition(sim.robot)
  let leftRobot = Robot.turnLeft(sim.robot)
  let leftPos = Robot.nextPosition(leftRobot)
  
  switch (isValidPosition(sim, nextPos), isValidPosition(sim, leftPos)) {
  | (true, _) => MoveForward      // Devant libre -> avancer
  | (false, true) => TurnLeft     // Devant bloqué, gauche libre -> tourner gauche
  | (false, false) => TurnRight   // Les deux bloqués -> tourner droite
  }
}

/* Compte le nombre de visites d'une position */
let getVisitCount = (sim: simulation, pos: position): int => {
  if pos.y >= 0 && pos.y < Array.length(sim.visited) {
    let row = Belt.Array.getExn(sim.visited, pos.y)
    if pos.x >= 0 && pos.x < Array.length(row) {
      Belt.Array.getExn(row, pos.x)
    } else {
      999  // Hors limites = déjà très visité
    }
  } else {
    999
  }
}

/* Stratégie d'exploration complète avec comportement aléatoire anti-blocage
 * Visite TOUTES les cellules accessibles
 */
let explorerStep = (sim: simulation): action => {
  let nextPos = Robot.nextPosition(sim.robot)
  let leftRobot = Robot.turnLeft(sim.robot)
  let leftPos = Robot.nextPosition(leftRobot)
  let rightRobot = Robot.turnRight(sim.robot)
  let rightPos = Robot.nextPosition(rightRobot)
  
  // Vérifier validité et compter visites
  let frontValid = isValidPosition(sim, nextPos)
  let leftValid = isValidPosition(sim, leftPos)
  let rightValid = isValidPosition(sim, rightPos)
  
  let frontVisits = frontValid ? getVisitCount(sim, nextPos) : 999
  let leftVisits = leftValid ? getVisitCount(sim, leftPos) : 999
  let rightVisits = rightValid ? getVisitCount(sim, rightPos) : 999
  let currentVisits = getVisitCount(sim, sim.robot.position)
  
  // Détecter si coincé (position actuelle très visitée)
  let isStuck = currentVisits > 10
  
  // PRIORITÉ 1 : Aller vers cellule JAMAIS visitée (0 visites)
  if frontVisits == 0 {
    MoveForward
  } else if leftVisits == 0 {
    TurnLeft
  } else if rightVisits == 0 {
    TurnRight
  }
  // Si coincé : comportement aléatoire pour sortir
  else if isStuck {
    // Utiliser le nombre de pas comme "seed" pour varier
    let random = mod(sim.steps, 3)
    if random == 0 && frontValid {
      MoveForward
    } else if random == 1 && leftValid {
      TurnLeft
    } else if rightValid {
      TurnRight
    } else {
      TurnLeft
    }
  }
  // PRIORITÉ 2 : Aller vers cellule MOINS visitée
  else if frontVisits < leftVisits && frontVisits < rightVisits && frontValid {
    MoveForward
  } else if leftVisits <= rightVisits && leftValid {
    TurnLeft
  } else if rightValid {
    TurnRight
  }
  // PRIORITÉ 3 : Si toutes bloquées, tourner pour chercher
  else {
    TurnRight
  }
}

