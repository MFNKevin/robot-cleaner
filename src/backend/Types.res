// Types globaux (Position, Cell, Direction)

/* Position dans la grille */
type position = {
  x: int,
  y: int,
}

/* État d’une cellule */
type cellState =
  | Empty      // Cellule vide (non encore visitée)
  | Dirty      // Cellule sale (à nettoyer)
  | Clean      // Cellule nettoyée
  | Wall       // Obstacle (mur)

/* Direction du robot */
type direction =
  | North
  | South
  | East
  | West

/* Grille de nettoyage */
type grid = array<array<cellState>>

/* Robot */
type robot = {
  position: position,
  direction: direction,
}

/* État global de la simulation */
type simulation = {
  grid: grid,
  robot: robot,
  battery: int,        // Batterie restante (en nombre de pas)
  score: int,          // Score (nombre de cellules nettoyées)
  steps: int,          // Nombre total de pas effectués
  visited: array<array<int>>, // Nombre de fois qu'une cellule a été visitée
}
