# 🤖 Robot Nettoyeur - Guide d'Implémentation ReScript

## 📚 Vue d'ensemble

Cette implémentation utilise la programmation fonctionnelle ReScript avec:
- **Types Variants** pour modéliser le domaine
- **Pattern Matching exhaustif** pour la logique
- **useReducer** pour la gestion d'état
- **Immutabilité** pour la fiabilité

---

## 🏗️ Architecture des Modules

### 1. **Types.res** - Modélisation du Domaine

```rescript
// Types de base
type cellState = Empty | Dirty | Clean | Wall
type direction = North | South | East | West
type position = { x: int, y: int }

// État global
type simulation = {
  grid: array<array<cellState>>,
  robot: robot,
  battery: int,    // Énergie (décrémente à chaque mouvement)
  score: int,      // Points (10 par cellule nettoyée)
  steps: int,      // Nombre de pas
}
```

**Avantages des Variants:**
- Type-safe : impossible d'avoir une valeur invalide
- Exhaustivité : le compilateur force à gérer tous les cas
- Lisible : `Wall` est plus clair que `3`

---

### 2. **Grid.res** - Gestion de la Grille

#### Génération avec obstacles aléatoires

```rescript
let createWithObstacles = (width: int, height: int, obstacleDensity: float): grid => {
  Array.make(~length=height, ())
    ->Array.mapWithIndex((_, y) => 
      Array.make(~length=width, ())
        ->Array.mapWithIndex((_, x) => {
          if x == 0 && y == 0 {
            Dirty  // Position de départ garantie libre
          } else {
            Math.random() < obstacleDensity ? Wall : Dirty
          }
        })
    )
}
```

**Exemple:**
```rescript
// Grille 8×8 avec 20% d'obstacles
let grid = Grid.createWithObstacles(8, 8, 0.2)
```

#### Fonctions utiles

```rescript
// Vérifier les limites
Grid.isInside(grid, {x: 5, y: 3})  // => true/false

// Lire une cellule (safe)
Grid.getCell(grid, {x: 2, y: 1})  // => Some(Dirty) | None

// Nettoyer (retourne true si nettoyée)
Grid.cleanCell(grid, robot.position)  // => bool

// Compter cellules sales
Grid.countDirtyCells(grid)  // => int
```

---

### 3. **Algorithm.res** - Logique de Mouvement

#### Stratégie Simple

```rescript
let simpleStep = (sim: simulation): action => {
  let nextPos = Robot.nextPosition(sim.robot)
  
  switch (Grid.isInside(sim.grid, nextPos), Grid.getCell(sim.grid, nextPos)) {
  | (true, Some(Wall)) => TurnRight    // Mur devant
  | (true, Some(_))    => MoveForward  // Cellule libre
  | (false, _)         => TurnRight    // Bordure
  | (_, None)          => TurnRight    // Cas impossible
  }
}
```

#### Stratégie Intelligente

```rescript
let smartStep = (sim: simulation): action => {
  let nextPos = Robot.nextPosition(sim.robot)
  let leftPos = Robot.nextPosition(Robot.turnLeft(sim.robot))
  
  switch (isValidPosition(sim, nextPos), isValidPosition(sim, leftPos)) {
  | (true, _)      => MoveForward  // Devant libre
  | (false, true)  => TurnLeft     // Gauche libre (explore mieux)
  | (false, false) => TurnRight    // Tout bloqué
  }
}
```

**Pattern Matching exhaustif** = pas d'oubli possible !

---

### 4. **Simulation.res** - Orchestration

#### Création

```rescript
// Avec paramètres personnalisés
let sim = Simulation.create(width, height, obstacleDensity)

// Avec valeurs par défaut (8×8, 20% obstacles)
let sim = Simulation.createDefault()
```

#### Tick (un pas de simulation)

```rescript
let step = (sim: simulation): simulation => {
  if sim.battery <= 0 {
    sim  // Batterie vide
  } else {
    // 1. Nettoyer cellule actuelle
    let wasCleaned = Grid.cleanCell(sim.grid, sim.robot.position)
    
    // 2. Décider action (algorithme)
    let action = Algorithm.smartStep(sim)
    
    // 3. Appliquer action
    let (updatedRobot, batteryCost) = switch action {
    | MoveForward => (Robot.moveForward(sim.robot), 1)
    | TurnLeft    => (Robot.turnLeft(sim.robot), 0)
    | TurnRight   => (Robot.turnRight(sim.robot), 0)
    }
    
    // 4. Nouveau score
    let newScore = wasCleaned ? sim.score + 10 : sim.score
    
    // 5. Retourner nouvel état (immutable)
    {
      ...sim,
      robot: updatedRobot,
      battery: sim.battery - batteryCost,
      score: newScore,
      steps: sim.steps + 1,
    }
  }
}
```

**Points clés:**
- Immutabilité: `{...sim, field: newValue}`
- Pattern Matching: gérer tous les types d'action
- Coût batterie: avancer = 1, tourner = 0

---

### 5. **SimulationState.res** - Gestion d'État avec useReducer

#### Actions disponibles

```rescript
type action =
  | Tick                          // Avancer d'un pas
  | Reset                         // Recommencer
  | SetSize(int, int)             // Changer dimensions
  | SetObstacleDensity(float)     // Changer densité obstacles
  | Start                         // Mode automatique
  | Pause                         // Pause
```

#### Reducer (Pure Function)

```rescript
let reducer = (state: state, action: action): state => {
  switch action {
  | Tick => 
      if Simulation.isFinished(state.simulation) {
        {...state, isRunning: false}
      } else {
        {...state, simulation: Simulation.step(state.simulation)}
      }
  
  | Reset => 
      {...state, simulation: Simulation.create(...), isRunning: false}
  
  | SetSize(w, h) =>
      // Recrée grille avec nouvelles dimensions
      {...state, simulation: Simulation.create(w, h, ...)}
  
  // ... autres cas
  }
}
```

#### Hook Custom

```rescript
let useSimulationState = () => {
  let (state, dispatch) = React.useReducer(reducer, initialState)
  
  // Timer automatique
  React.useEffect(() => {
    if state.isRunning {
      let id = setInterval(() => dispatch(Tick), 500)
      Some(() => clearInterval(id))
    } else {
      None
    }
  }, [state.isRunning])
  
  (state, dispatch)
}
```

**Pourquoi useReducer ?**
- État complexe avec plusieurs champs interdépendants
- Actions explicites et testables
- Reducer = pure function (prévisible)
- Meilleure organisation que useState multiple

---

### 6. **CellView.res** - Affichage d'une Cellule

```rescript
let cellStyle = switch (cellState, isRobot) {
| (_, true)        => "bg-blue-500 border-2 border-blue-700"    // Robot
| (Clean, false)   => "bg-green-200 hover:bg-green-300"         // Propre
| (Dirty, false)   => "bg-red-400 hover:bg-red-500"             // Sale
| (Wall, false)    => "bg-gray-800 border-2 border-gray-900"    // Mur
| (Empty, false)   => "bg-gray-100 hover:bg-gray-200"           // Vide
}

let robotIcon = switch robotDirection {
| Some(North) => "⬆️"
| Some(South) => "⬇️"
| Some(East)  => "➡️"
| Some(West)  => "⬅️"
| None        => "🤖"
}
```

---

### 7. **GridView.res** - Affichage de la Grille

```rescript
@react.component
let make = (~grid: Types.grid, ~robot: Types.robot) => {
  let gridHeight = grid->Array.length
  let gridWidth = grid[0]->Array.length
  
  let cells = Array.make(~length=gridHeight * gridWidth, React.null)
  
  for y in 0 to gridHeight - 1 {
    for x in 0 to gridWidth - 1 {
      let isRobot = robot.position.x == x && robot.position.y == y
      let cellState = Grid.getCell(grid, {x, y})->Option.getOr(Dirty)
      
      cells[y * gridWidth + x] = (
        <CellView 
          key={...}
          cellState
          isRobot
          robotDirection={isRobot ? Some(robot.direction) : None}
        />
      )
    }
  }
  
  <div className="inline-grid gap-1" style={...}>
    {cells->React.array}
  </div>
}
```

**Pattern:**
- Itération avec `for` (plus efficace que map pour grilles)
- `React.array` pour convertir array → React elements
- CSS Grid avec `gridTemplateColumns`

---

## 💻 Utilisation dans un Composant

```rescript
@react.component
let make = () => {
  // Hook custom avec useReducer
  let (state, dispatch) = SimulationState.useSimulationState()
  
  let sim = state.simulation
  
  <div>
    {/* Stats */}
    <div>
      <p>{`Batterie: ${sim.battery->Int.toString}`->React.string}</p>
      <p>{`Score: ${sim.score->Int.toString}`->React.string}</p>
      <p>{`Pas: ${sim.steps->Int.toString}`->React.string}</p>
    </div>
    
    {/* Grille */}
    <GridView grid={sim.grid} robot={sim.robot} />
    
    {/* Contrôles */}
    <button onClick={_ => dispatch(Tick)}>
      {"Un Pas"->React.string}
    </button>
    <button onClick={_ => dispatch(Start)}>
      {"Auto"->React.string}
    </button>
    <button onClick={_ => dispatch(Pause)}>
      {"Pause"->React.string}
    </button>
    <button onClick={_ => dispatch(Reset)}>
      {"Reset"->React.string}
    </button>
    
    {/* Slider densité */}
    <input
      type_="range"
      min="0"
      max="0.5"
      step="0.05"
      value={state.config.obstacleDensity->Float.toString}
      onChange={evt => {
        let density = evt->ReactEvent.Form.target["value"]
          ->Float.fromString
          ->Option.getOr(0.2)
        dispatch(SetObstacleDensity(density))
      }}
    />
  </div>
}
```

---

## 🎯 Points Clés ReScript

### 1. Pattern Matching Exhaustif
```rescript
// Le compilateur force à gérer TOUS les cas
let cellColor = switch cellState {
| Empty => "gray"
| Dirty => "red"
| Clean => "green"
| Wall  => "black"  // Oublier ce cas = erreur de compilation !
}
```

### 2. Immutabilité
```rescript
// ❌ Mutation (sauf grid pour performance)
sim.battery = sim.battery - 1

// ✅ Copie avec modification
{...sim, battery: sim.battery - 1}
```

### 3. Option<'a> (pas de null)
```rescript
// Forcer à gérer None
switch Grid.getCell(grid, pos) {
| Some(cell) => // Utiliser cell
| None => // Gérer absence
}
```

### 4. Pipe Operator
```rescript
// Plus lisible
grid->Array.length

// Au lieu de
Array.length(grid)
```

### 5. Type Inference
```rescript
// Pas besoin d'annoter partout
let x = 5  // int inféré
let sum = (a, b) => a + b  // (int, int) => int inféré
```

---

## 🚀 Avantages de cette Architecture

1. **Type Safety**: Impossible d'avoir un état invalide
2. **Testabilité**: Reducer = pure function facile à tester
3. **Maintenabilité**: Actions explicites, logique centralisée
4. **Performance**: Immutabilité + optimisations compilateur
5. **Lisibilité**: Pattern Matching > if/else imbriqués

---

## 📦 Fichiers Modifiés/Créés

- ✅ `Types.res` - Ajout Wall, battery, score
- ✅ `Grid.res` - Génération avec obstacles aléatoires
- ✅ `Algorithm.res` - Stratégies simple et intelligente
- ✅ `Simulation.res` - Orchestration complète
- ✅ `SimulationState.res` - useReducer avec actions
- ✅ `CellView.res` - Rendu Wall
- ✅ `GridView.res` - Support grilles rectangulaires
- ✅ `Logic.res` - Documentation architecture

---

## 🎓 Pour Aller Plus Loin

### Ajouter d'autres stratégies

```rescript
// Dans Algorithm.res
let randomStep = (sim: simulation): action => {
  let random = Math.random()
  if random < 0.7 {
    MoveForward
  } else if random < 0.85 {
    TurnLeft
  } else {
    TurnRight
  }
}
```

### Ajouter animation

```rescript
// Dans reducer
| Tick =>
    // Ajouter délai visuel
    setTimeout(() => {...}, 100)
```

### Sauvegarder historique

```rescript
type state = {
  simulation: simulation,
  history: array<simulation>,  // Historique des états
  ...
}
```

---

**🎉 Félicitations ! Vous avez maintenant une simulation complète en ReScript avec une architecture fonctionnelle robuste.**
