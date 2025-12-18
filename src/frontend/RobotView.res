// Robot (position, icône) - Affichage du robot avec sa direction

open Types

@react.component
let make = (~robot: Types.robot) => {
  /* Icône basée sur la direction */
  let icon =
    switch robot.direction {
    | North => "⬆️"
    | South => "⬇️"
    | East => "➡️"
    | West => "⬅️"
    }

  <div className="text-2xl font-bold">
    {React.string(icon)}
  </div>
}
