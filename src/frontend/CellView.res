// Affichage d'une cellule individuelle de la grille

open Types

@react.component
let make = (~cellState: Types.cellState, ~isRobot: bool, ~robotDirection: option<Types.direction>=?) => {
  /* Détermine les classes Tailwind basées sur l'état */
  let isRobot = isRobot
  
  let cellStyle =
    switch (cellState, isRobot) {
    | (_, true) =>
      /* Robot : couleur bleue avec bordure */
      "bg-blue-500 border-2 border-blue-700 flex items-center justify-center"
    | (Clean, false) =>
      /* Cellule nettoyée : couleur verte claire */
      "bg-green-200 hover:bg-green-300"
    | (Dirty, false) =>
      /* Cellule sale : couleur rouge */
      "bg-red-400 hover:bg-red-500"
    | (Wall, false) =>
      /* Mur/Obstacle : couleur gris foncé */
      "bg-gray-800 border-2 border-gray-900"
    | (Empty, false) =>
      /* Cellule vide : couleur gris clair */
      "bg-gray-100 hover:bg-gray-200"
    }

  /* Récupère l'icône directionnelle du robot */
  let robotIcon =
    switch robotDirection {
    | Some(North) => "⬆️"
    | Some(South) => "⬇️"
    | Some(East) => "➡️"
    | Some(West) => "⬅️"
    | None => "🤖"
    }

  /* Contenu de la cellule */
  let content =
    if isRobot {
      React.string(robotIcon)
    } else {
      switch cellState {
      | Clean => React.string("✓")
      | Dirty => React.string("◼")
      | Wall => React.string("🧱")
      | Empty => React.string("")
      }
    }

  <div
    className={`w-12 h-12 border border-gray-300 flex items-center justify-center text-lg font-bold cursor-pointer transition-all duration-200 ${cellStyle}`}>
    {content}
  </div>
}
