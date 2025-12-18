//État global côté frontend
open React

/* Taille par défaut de la grille */
let defaultSize = 5

/* Hook personnalisé pour gérer l'état de la simulation */
let useSimulationState = () => {
  /* État principal de la simulation */
  let (sim, setSim) = React.useState(() => Simulation.create(defaultSize))

  /* Fonction pour avancer d’un pas */
  let step = () => setSim(prev => Simulation.step(prev))

  /* Réinitialiser la simulation */
  let reset = () => setSim(_ => Simulation.create(defaultSize))

  /* Timer pour le mode automatique */
  let timerRef = React.useRef(None)

  let start = () => {
    if Option.isNone(timerRef.current) {
      let id = setInterval(() => step(), 500)
      timerRef.current = Some(id)
    }
  }

  let pause = () => {
    switch timerRef.current {
    | Some(id) =>
      clearInterval(id)
      timerRef.current = None
    | None => ()
    }
  }

  /* Retourne l’état et les actions */
  (sim, step, reset, start, pause)
}
