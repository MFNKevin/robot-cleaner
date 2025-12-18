//Vue principale de la simulation

open Types

@react.component
let make = () => {
  /* Récupère l'état de la simulation */
  let (sim, step, reset, _start, _pause) = SimulationState.useSimulationState()

  /* Gère le mode de fonctionnement (automatique ou pas-à-pas) */
  let (isRunning, setIsRunning) = React.useState(() => false)

  /* Reference pour le timer */
  let timerRef = React.useRef(None)

  /* Démarre la simulation automatique */
  let handleStart = () => {
    setIsRunning(_ => true)
    let id = TimerBinding.setInterval(() => step(), 500)
    timerRef.current = Some(id)
  }

  /* Pause la simulation */
  let handlePause = () => {
    setIsRunning(_ => false)
    switch timerRef.current {
    | Some(id) =>
      TimerBinding.clearInterval(id)
      timerRef.current = None
    | None => ()
    }
  }

  /* Étape unique */
  let handleStep = () => {
    step()
  }

  /* Réinitialise */
  let handleReset = () => {
    handlePause()
    reset()
  }

  /* Nettoyage au démontage */
  React.useEffect(() => {
    Some(() => {
      switch timerRef.current {
      | Some(id) => TimerBinding.clearInterval(id)
      | None => ()
      }
    })
  }, [])

  <div className="flex flex-col items-center justify-center min-h-screen bg-gray-50">
    <h1 className="text-4xl font-bold text-blue-600 mb-8">
      {"🤖 Robot Cleaner"->React.string}
    </h1>

    <div className="mb-8">
      <GridView grid={sim.grid} robot={sim.robot} />
    </div>

    <ControlPanel
      onStart={handleStart}
      onPause={handlePause}
      onStep={handleStep}
      onReset={handleReset}
      isRunning
    />

    <div className="mt-8 p-6 bg-white rounded-lg shadow-md max-w-md">
      <p className="text-lg font-semibold mb-2">
        {"Statistiques:"->React.string}
      </p>
      <p className="text-gray-600">
        {"Position: ("->React.string}
        {sim.robot.position.x->Int.toString->React.string}
        {", "->React.string}
        {sim.robot.position.y->Int.toString->React.string}
        {")"->React.string}
      </p>
      <p className="text-gray-600">
        {"État: "->React.string}
        {(isRunning ? "En cours..." : "Arrêté")->React.string}
      </p>
    </div>
  </div>
}
