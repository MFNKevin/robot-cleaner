//Affichage de la grille (support rectangulaire)

open Types

@react.component
let make = (~grid: Types.grid, ~robot: Types.robot) => {
  /* Support des grilles rectangulaires (N×M) */
  let gridHeight = grid->Array.length
  let gridWidth = switch grid->Array.get(0) {
  | Some(row) => row->Array.length
  | None => 0
  }

  /* Génère une cellule pour chaque position */
  let cells = Array.make(~length=gridHeight * gridWidth, React.null)

  for y in 0 to gridHeight - 1 {
    for x in 0 to gridWidth - 1 {
      let pos = {x, y}
      let isRobot = robot.position.x === x && robot.position.y === y

      let cellState =
        switch Grid.getCell(grid, pos) {
        | Some(state) => state
        | None => Dirty
        }

      let index = y * gridWidth + x
      let robotDir = if isRobot {
        Some(robot.direction)
      } else {
        None
      }
      cells[index] = (
        <CellView
          key={index->Int.toString}
          cellState
          isRobot
          robotDirection=?robotDir
        />
      )
    }
  }

  <div
    className="inline-grid gap-1 p-6 bg-gray-100 rounded-lg shadow-md"
    style={Obj.magic({
      "gridTemplateColumns": `repeat(${gridWidth->Int.toString}, minmax(0, 1fr))`,
    })}>
    {cells->React.array}
  </div>
}
