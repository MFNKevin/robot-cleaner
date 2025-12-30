/* 
 * ===================================
 * DOCUMENTATION : ARCHITECTURE LOGIQUE
 * Robot Nettoyeur - ReScript
 * ===================================
 * 
 * Ce fichier documente l'architecture fonctionnelle du robot nettoyeur.
 * Il n'exporte pas de code exécutable, mais explique la structure.
 */

/*
 * 1. MODÉLISATION DE DOMAINE (Types.res)
 * ========================================
 * 
 * Types Variants utilisés :
 * 
 * type cellState = Empty | Dirty | Clean | Wall
 *   - Empty: Cellule non visitée
 *   - Dirty: Cellule sale à nettoyer
 *   - Clean: Cellule nettoyée
 *   - Wall: Obstacle (mur)
 * 
 * type direction = North | South | East | West
 *   - Représente l'orientation du robot
 * 
 * type position = { x: int, y: int }
 *   - Coordonnées dans la grille
 * 
 * type robot = { position, direction }
 *   - État du robot
 * 
 * type simulation = {
 *   grid: array<array<cellState>>,
 *   robot: robot,
 *   battery: int,    // Énergie restante
 *   score: int,      // Points (cellules nettoyées)
 *   steps: int       // Nombre de pas
 * }
 */

/*
 * 2. GÉNÉRATION DE MONDE (Grid.res)
 * ==================================
 * 
 * Fonction principale : createWithObstacles
 * 
 * let createWithObstacles = (width, height, obstacleDensity) => {
 *   // 1. Crée une grille vide
 *   // 2. Pour chaque cellule (sauf 0,0):
 *   //    - Génère random entre 0 et 1
 *   //    - Si < density => Wall
 *   //    - Sinon => Dirty
 *   // 3. Garantit que (0,0) est Dirty (position départ)
 * }
 * 
 * Exemple : createWithObstacles(8, 8, 0.2)
 * => Grille 8×8 avec ~20% de murs aléatoires
 * 
 * Autres fonctions utiles :
 * - isInside(grid, pos): Vérifie limites
 * - getCell(grid, pos): Lecture sûre (option)
 * - cleanCell(grid, pos): Nettoie (mutation)
 * - countDirtyCells(grid): Compte cellules sales
 */

/*
 * 3. ALGORITHME DE MOUVEMENT (Algorithm.res)
 * ============================================
 * 
 * Type d'action : MoveForward | TurnLeft | TurnRight
 * 
 * Stratégie Simple (simpleStep):
 * --------------------------------
 * switch (isInside, cellType) {
 * | (true, Wall) => TurnRight      // Mur devant
 * | (true, _)    => MoveForward    // Cellule libre
 * | (false, _)   => TurnRight      // Bordure
 * }
 * 
 * Stratégie Intelligente (smartStep):
 * ------------------------------------
 * let nextPos = Robot.nextPosition(robot)
 * let leftPos = Robot.nextPosition(Robot.turnLeft(robot))
 * 
 * switch (isValid(nextPos), isValid(leftPos)) {
 * | (true, _)     => MoveForward   // Devant libre
 * | (false, true) => TurnLeft      // Gauche libre
 * | (false, false) => TurnRight    // Tout bloqué
 * }
 * 
 * => Préfère tourner à gauche (explore mieux les coins)
 */

/*
 * 4. GESTION D'ÉTAT AVEC useReducer (SimulationState.res)
 * =========================================================
 * 
 * Actions disponibles :
 * ---------------------
 * type action =
 *   | Tick                          // Avance d'un pas
 *   | Reset                         // Recommence
 *   | SetSize(int, int)             // Change dimensions
 *   | SetObstacleDensity(float)     // Change densité
 *   | Start                         // Mode auto
 *   | Pause                         // Pause auto
 * 
 * Reducer (Pure Function) :
 * -------------------------
 * let reducer = (state, action) =>
 *   switch action {
 *   | Tick => 
 *       if isFinished(state.simulation) {
 *         {...state, isRunning: false}
 *       } else {
 *         {...state, simulation: Simulation.step(...)}
 *       }
 *   
 *   | Reset => 
 *       {...state, simulation: Simulation.create(...)}
 *   
 *   | SetSize(w, h) =>
 *       // Recrée grille avec nouvelles dimensions
 *   
 *   // ... autres cas
 *   }
 * 
 * Hook Custom :
 * -------------
 * let useSimulationState = () => {
 *   let (state, dispatch) = React.useReducer(reducer, initialState)
 *   
 *   // Timer automatique avec useEffect
 *   React.useEffect(() => {
 *     if state.isRunning {
 *       let id = setInterval(() => dispatch(Tick), 500)
 *       Some(() => clearInterval(id))
 *     } else {
 *       None
 *     }
 *   }, [state.isRunning])
 *   
 *   (state, dispatch)
 * }
 */

/*
 * 5. LOGIQUE DE TICK (Simulation.res)
 * =====================================
 * 
 * Un pas de simulation :
 * ----------------------
 * let step = (sim) => {
 *   if sim.battery <= 0 {
 *     sim  // Batterie vide, rien faire
 *   } else {
 *     // 1. Nettoyer cellule actuelle
 *     let wasCleaned = Grid.cleanCell(sim.grid, sim.robot.position)
 *     
 *     // 2. Décider action (algorithme)
 *     let action = Algorithm.smartStep(sim)
 *     
 *     // 3. Appliquer action avec Pattern Matching
 *     let (updatedRobot, batteryCost) = switch action {
 *     | MoveForward => (Robot.moveForward(...), 1)
 *     | TurnLeft => (Robot.turnLeft(...), 0)
 *     | TurnRight => (Robot.turnRight(...), 0)
 *     }
 *     
 *     // 4. Mettre à jour score
 *     let newScore = wasCleaned ? sim.score + 10 : sim.score
 *     
 *     // 5. Retourner nouvel état (immutable)
 *     {
 *       ...sim,
 *       robot: updatedRobot,
 *       battery: sim.battery - batteryCost,
 *       score: newScore,
 *       steps: sim.steps + 1
 *     }
 *   }
 * }
 */

/*
 * 6. RENDU DE LA GRILLE (GridView.res)
 * ======================================
 * 
 * Composant React pour afficher la grille :
 * 
 * @react.component
 * let make = (~simulation: Types.simulation) => {
 *   <div className="grid gap-1">
 *     {simulation.grid
 *       ->Array.mapWithIndex((row, y) =>
 *         <div key={Int.toString(y)} className="flex gap-1">
 *           {row->Array.mapWithIndex((cell, x) => {
 *             let isRobot = 
 *               simulation.robot.position.x == x && 
 *               simulation.robot.position.y == y
 *             
 *             <CellView 
 *               key={Int.toString(x)}
 *               cellState={cell}
 *               isRobot={isRobot}
 *               robotDirection={isRobot ? Some(simulation.robot.direction) : None}
 *             />
 *           })->React.array}
 *         </div>
 *       )
 *       ->React.array}
 *   </div>
 * }
 * 
 * Pattern :
 * - Array.mapWithIndex pour itérer avec index
 * - React.array pour convertir array en React elements
 * - key prop pour performance React
 */

/*
 * 7. AFFICHAGE CELLULE (CellView.res)
 * =====================================
 * 
 * Affiche une cellule individuelle avec style Tailwind :
 * 
 * let cellStyle = switch (cellState, isRobot) {
 * | (_, true)        => "bg-blue-500 ..."      // Robot
 * | (Clean, false)   => "bg-green-200 ..."     // Nettoyé
 * | (Dirty, false)   => "bg-red-400 ..."       // Sale
 * | (Wall, false)    => "bg-gray-800 ..."      // Mur
 * | (Empty, false)   => "bg-gray-100 ..."      // Vide
 * }
 * 
 * Icônes :
 * - Robot : ⬆️⬇️➡️⬅️ selon direction
 * - Clean : ✓
 * - Dirty : ◼
 * - Wall : 🧱
 */

/*
 * 8. UTILISATION DANS UN COMPOSANT
 * ==================================
 * 
 * @react.component
 * let make = () => {
 *   // Hook custom avec useReducer
 *   let (state, dispatch) = SimulationState.useSimulationState()
 *   
 *   <div>
 *     // Stats
 *     <div>
 *       <p>{`Batterie: ${Int.toString(state.simulation.battery)}`->React.string}</p>
 *       <p>{`Score: ${Int.toString(state.simulation.score)}`->React.string}</p>
 *       <p>{`Pas: ${Int.toString(state.simulation.steps)}`->React.string}</p>
 *     </div>
 *     
 *     // Grille
 *     <GridView simulation={state.simulation} />
 *     
 *     // Contrôles
 *     <button onClick={_ => dispatch(Tick)}>{"Pas"->React.string}</button>
 *     <button onClick={_ => dispatch(Start)}>{"Auto"->React.string}</button>
 *     <button onClick={_ => dispatch(Pause)}>{"Pause"->React.string}</button>
 *     <button onClick={_ => dispatch(Reset)}>{"Reset"->React.string}</button>
 *   </div>
 * }
 */

/*
 * POINTS CLÉS RESCRIPT :
 * =======================
 * 
 * 1. Pattern Matching Exhaustif
 *    - switch doit couvrir tous les cas
 *    - Garantit la sûreté à la compilation
 * 
 * 2. Immutabilité
 *    - {...state, field: newValue} pour copier
 *    - Pas de mutation sauf grid (performance)
 * 
 * 3. Option<'a>
 *    - Some(value) | None
 *    - Pas de null/undefined
 * 
 * 4. Pipe Operator
 *    - array->Array.map(fn)
 *    - Plus lisible que Array.map(array, fn)
 * 
 * 5. Type Inference
 *    - Pas besoin d'annoter tout
 *    - Mais utile pour clarté
 * 
 * 6. useReducer > useState
 *    - Pour état complexe
 *    - Actions explicites
 *    - Testable facilement
 */
