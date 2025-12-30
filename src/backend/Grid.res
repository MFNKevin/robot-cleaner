// Grille (création, lecture, nettoyage)

open Types

/* Crée une grille carrée de taille donnée, initialement sale */
let create = (size: int): grid => {
  Array.make(~length=size, Array.make(~length=size, Dirty))
}

/* Génération aléatoire avec obstacles 
 * @param width - Largeur de la grille
 * @param height - Hauteur de la grille  
 * @param obstacleDensity - Densité d'obstacles (0.0 à 1.0, ex: 0.2 = 20%)
 * @returns Une grille avec obstacles aléatoires, position (0,0) garantie libre
 */
let createWithObstacles = (width: int, height: int, obstacleDensity: float): grid => {
  /* Crée une grille vide */
  let grid = Array.make(~length=height, ())
    ->Array.mapWithIndex((_, y) => 
      Array.make(~length=width, ())
        ->Array.mapWithIndex((_, x) => {
          /* Garantit que la case de départ (0,0) reste libre */
          if x == 0 && y == 0 {
            Dirty
          } else {
            /* Génère un nombre aléatoire entre 0 et 1 */
            let random = Math.random()
            if random < obstacleDensity {
              Wall
            } else {
              Dirty
            }
          }
        })
    )
  grid
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

/* Nettoie une cellule si elle existe et si ce n'est pas un mur */
let cleanCell = (grid: grid, pos: position): bool =>
  switch Array.get(grid, pos.y) {
  | Some(row) =>
    switch Array.get(row, pos.x) {
    | Some(Dirty) => 
      row[pos.x] = Clean
      true  // Retourne true si nettoyage effectué
    | Some(_) => false  // Déjà clean, wall, ou empty
    | None => false
    }
  | None => false
  }

/* Compte le nombre de cellules sales restantes */
let countDirtyCells = (grid: grid): int => {
  grid
    ->Array.reduce(0, (acc, row) => {
      acc + row->Array.reduce(0, (rowAcc, cell) => {
        switch cell {
        | Dirty => rowAcc + 1
        | _ => rowAcc
        }
      })
    })
}
