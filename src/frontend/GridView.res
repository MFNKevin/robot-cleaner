//Affichage de la grille

open Types

@react.component
let make = (~grid: Types.grid, ~robot: Types.robot) => {
  let gridSize = grid->Array.length

  /* Génère une cellule pour chaque position */
  let cells = Array.make(~length=gridSize * gridSize, React.null)

  for y in 0 to gridSize - 1 {
    for x in 0 to gridSize - 1 {
      let pos = {x, y}
      let isRobot = robot.position.x === x && robot.position.y === y

      let cellState =
        switch Grid.getCell(grid, pos) {
        | Some(state) => state
        | None => Dirty
        }

      let index = y * gridSize + x
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
      "gridTemplateColumns": `repeat(${gridSize->Int.toString}, minmax(0, 1fr))`,
    })}>
    {cells->React.array}
  </div>
}
