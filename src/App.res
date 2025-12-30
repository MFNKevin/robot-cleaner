@react.component
let make = () => {
  // Hook avec useReducer
  let (state, dispatch) = SimulationState.useSimulationState()
  let sim = state.simulation
  
  <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 p-8">
    <div className="max-w-4xl mx-auto">
      <h1 className="text-4xl font-bold text-center text-gray-800 mb-8">
        {"🤖 Robot Nettoyeur"->React.string}
      </h1>
      
      // Statistiques
      <div className="bg-white rounded-lg shadow-lg p-6 mb-6">
        <h2 className="text-2xl font-semibold mb-4">{"Statistiques"->React.string}</h2>
        <div className="grid grid-cols-2 gap-4">
          <div>
            <span className="text-gray-600">{"🔋 Batterie: "->React.string}</span>
            <span className="font-bold text-xl text-green-600">
              {`${sim.battery->Int.toString}%`->React.string}
            </span>
          </div>
          <div>
            <span className="text-gray-600">{"⭐ Score: "->React.string}</span>
            <span className="font-bold text-xl text-indigo-600">
              {sim.score->Int.toString->React.string}
            </span>
          </div>
          <div>
            <span className="text-gray-600">{"👣 Pas: "->React.string}</span>
            <span className="font-bold text-xl">
              {sim.steps->Int.toString->React.string}
            </span>
          </div>
          <div>
            <span className="text-gray-600">{"🧹 Restant: "->React.string}</span>
            <span className="font-bold text-xl text-red-600">
              {Grid.countDirtyCells(sim.grid)->Int.toString->React.string}
            </span>
          </div>
        </div>
      </div>
      
      // Grille
      <div className="flex justify-center mb-6">
        <GridView grid={sim.grid} robot={sim.robot} />
      </div>
      
      // Contrôles
      <div className="bg-white rounded-lg shadow-lg p-6">
        <h2 className="text-2xl font-semibold mb-4">{"Contrôles"->React.string}</h2>
        <div className="flex flex-wrap gap-3">
          <button 
            onClick={_ => dispatch(SimulationState.Tick)}
            disabled={Simulation.isFinished(sim) || state.isRunning}
            className="px-6 py-3 bg-blue-500 hover:bg-blue-600 text-white rounded-lg font-semibold disabled:bg-gray-300 disabled:cursor-not-allowed">
            {"➡️ Un Pas"->React.string}
          </button>
          
          {state.isRunning
            ? <button 
                onClick={_ => dispatch(SimulationState.Pause)}
                className="px-6 py-3 bg-orange-500 hover:bg-orange-600 text-white rounded-lg font-semibold">
                {"⏸️ Pause"->React.string}
              </button>
            : <button 
                onClick={_ => dispatch(SimulationState.Start)}
                disabled={Simulation.isFinished(sim)}
                className="px-6 py-3 bg-green-500 hover:bg-green-600 text-white rounded-lg font-semibold disabled:bg-gray-300 disabled:cursor-not-allowed">
                {"▶️ Auto"->React.string}
              </button>
          }
          
          <button 
            onClick={_ => dispatch(SimulationState.Reset)}
            className="px-6 py-3 bg-red-500 hover:bg-red-600 text-white rounded-lg font-semibold">
            {"🔄 Reset"->React.string}
          </button>
        </div>
      </div>
    </div>
  </div>
}
