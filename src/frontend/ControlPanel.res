// Boutons Start / Pause / Step

@react.component
let make = (~onStart, ~onPause, ~onStep, ~onReset, ~isRunning: bool) => {
  <div className="flex gap-4 justify-center my-6">
    <button
      onClick={_ => onStart()}
      disabled={isRunning}
      className="px-6 py-2 bg-green-500 text-white font-bold rounded hover:bg-green-600 disabled:bg-gray-400 disabled:cursor-not-allowed">
      {"Démarrer"->React.string}
    </button>
    <button
      onClick={_ => onPause()}
      disabled={!isRunning}
      className="px-6 py-2 bg-yellow-500 text-white font-bold rounded hover:bg-yellow-600 disabled:bg-gray-400 disabled:cursor-not-allowed">
      {"Pause"->React.string}
    </button>
    <button
      onClick={_ => onStep()}
      disabled={isRunning}
      className="px-6 py-2 bg-blue-500 text-white font-bold rounded hover:bg-blue-600 disabled:bg-gray-400 disabled:cursor-not-allowed">
      {"Pas suivant"->React.string}
    </button>
    <button
      onClick={_ => onReset()}
      className="px-6 py-2 bg-red-500 text-white font-bold rounded hover:bg-red-600">
      {"Réinitialiser"->React.string}
    </button>
  </div>
}
