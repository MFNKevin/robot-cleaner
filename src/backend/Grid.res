// Grille (création, lecture, nettoyage)

open Types

/* Crée une grille carrée de taille donnée, initialement sale */
let create = (size: int): grid => {
  Array.make(~length=size, Array.make(~length=size, Dirty))
}

/* Vérifie si une position est dans les limites de la grille */
let isInside = (grid: grid, pos: position): bool => {
  let size = grid->Array.length
  pos.x >= 0 && pos.y >= 0 && pos.x < size && pos.y < size
}

/* Récupère l’état d’une cellule (version totalement sûre) */
let getCell = (grid: grid, pos: position): option<cellState> =>
  switch Array.get(grid, pos.y) {
  | Some(row) =>
    switch Array.get(row, pos.x) {
    | Some(cell) => Some(cell)
    | None => None
    }
  | None => None
  }

/* Nettoie une cellule si elle existe */
let cleanCell = (grid: grid, pos: position): unit =>
  switch Array.get(grid, pos.y) {
  | Some(row) =>
    switch Array.get(row, pos.x) {
    | Some(_) => row[pos.x] = Clean
    | None => ()
    }
  | None => ()
  }
