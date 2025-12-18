// Types globaux (Position, Cell, Direction)

/* Position dans la grille */
type position = {
  x: int,
  y: int,
}

/* État d’une cellule */
type cellState =
  | Dirty
  | Clean

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
}
