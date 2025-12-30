//État global côté frontend avec useReducer
open React

/* Taille par défaut de la grille */
let defaultWidth = 8
let defaultHeight = 8
let defaultObstacleDensity = 0.2

/* Type d'action pour le reducer (Pattern Matching) */
type action =
  | Tick                                    // Avancer d'un pas
  | Reset                                   // Réinitialiser
  | SetSize(int, int)                       // Changer la taille (width, height)
  | SetObstacleDensity(float)               // Changer la densité d'obstacles
  | Start                                   // Démarrer le mode auto
  | Pause                                   // Mettre en pause

/* État étendu incluant la config et le timer */
type state = {
  simulation: Types.simulation,
  isRunning: bool,
  config: {
    width: int,
    height: int,
    obstacleDensity: float,
  }
}

/* Reducer : Pure function qui gère tous les changements d'état
 * Pattern Matching exhaustif pour garantir la cohérence
 */
let reducer = (state: state, action: action): state => {
  switch action {
  | Tick => 
      /* Avance d'un pas si la simulation n'est pas finie */
      if Simulation.isFinished(state.simulation) {
        {...state, isRunning: false}
      } else {
        {
          ...state, 
          simulation: Simulation.step(state.simulation)
        }
      }
      
  | Reset => 
      /* Recrée une nouvelle simulation avec la config actuelle */
      {
        ...state,
        simulation: Simulation.create(
          state.config.width, 
          state.config.height, 
          state.config.obstacleDensity
        ),
        isRunning: false,
      }
      
  | SetSize(w, h) => 
      /* Change la taille et recrée la grille */
      let newConfig = {...state.config, width: w, height: h}
      {
        ...state,
        config: newConfig,
        simulation: Simulation.create(w, h, newConfig.obstacleDensity),
        isRunning: false,
      }
      
  | SetObstacleDensity(density) =>
      /* Change la densité d'obstacles et recrée */
      let newConfig = {...state.config, obstacleDensity: density}
      {
        ...state,
        config: newConfig,
        simulation: Simulation.create(
          newConfig.width, 
          newConfig.height, 
          density
        ),
        isRunning: false,
      }
      
  | Start =>
      {...state, isRunning: true}
      
  | Pause =>
      {...state, isRunning: false}
  }
}

/* Hook personnalisé pour gérer l'état de la simulation avec useReducer */
let useSimulationState = () => {
  /* État initial */
  let initialState = {
    simulation: Simulation.create(defaultWidth, defaultHeight, defaultObstacleDensity),
    isRunning: false,
    config: {
      width: defaultWidth,
      height: defaultHeight,
      obstacleDensity: defaultObstacleDensity,
    }
  }
  
  /* useReducer : meilleure approche pour état complexe */
  let (state, dispatch) = React.useReducer(reducer, initialState)
  
  /* Timer pour le mode automatique */
  let timerRef = React.useRef(None)
  
  /* Effect pour gérer le timer auto */
  React.useEffect(() => {
    if state.isRunning {
      let id = setInterval(() => dispatch(Tick), 500)
      timerRef.current = Some(id)
      
      /* Cleanup */
      Some(() => {
        clearInterval(id)
        timerRef.current = None
      })
    } else {
      /* Arrêter le timer si en pause */
      switch timerRef.current {
      | Some(id) => 
          clearInterval(id)
          timerRef.current = None
      | None => ()
      }
      None
    }
  }, [state.isRunning])
  
  /* Retourne l'état et le dispatcher */
  (state, dispatch)
}
