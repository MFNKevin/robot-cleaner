# 🚀 Guide de Démarrage Rapide - Robot Nettoyeur

## 📋 Prérequis

- Node.js (v14 ou supérieur)
- npm ou yarn
- VS Code (recommandé)

## 🔧 Installation

```bash
# Dans le dossier robot-cleaner
npm install

# Ou avec yarn
yarn install
```

## ▶️ Lancer le Projet

### Mode Développement

```bash
# Terminal 1 : Compiler ReScript en watch mode
npm run res:dev

# Terminal 2 : Lancer le serveur de développement
npm run dev
```

Puis ouvrir : http://localhost:5173

### Build Production

```bash
# Compiler ReScript
npm run res:build

# Build Vite
npm run build

# Preview
npm run preview
```

## 📂 Structure des Fichiers Importants

```
robot-cleaner/
├── src/
│   ├── backend/          # 🧠 Logique pure (algorithmes)
│   │   ├── Types.res     # Types de données
│   │   ├── Grid.res      # Gestion grille + obstacles
│   │   ├── Robot.res     # Mouvements robot
│   │   ├── Algorithm.res # Stratégies de nettoyage
│   │   ├── Simulation.res # Orchestration
│   │   ├── Logic.res     # 📚 Documentation architecture
│   │   └── Examples.res  # 💡 Exemples d'utilisation
│   │
│   ├── frontend/         # 🎨 Composants React
│   │   ├── CellView.res  # Affichage cellule
│   │   ├── GridView.res  # Affichage grille
│   │   └── SimulationView.res # Vue principale
│   │
│   ├── state/            # 🔄 Gestion d'état
│   │   └── SimulationState.res # useReducer + actions
│   │
│   ├── App.res           # Composant principal
│   └── Main.res          # Point d'entrée
│
├── IMPLEMENTATION_GUIDE.md  # 📚 Guide complet (ReScript)
├── ALGORITHME_EXPLIQUE.md   # 🇫🇷 Explication en français
└── RECAPITULATIF.md         # 📝 Liste des modifications
```

## 🎮 Utiliser les Composants

### Option 1 : Vue Principale (Déjà intégrée)

La vue principale est déjà dans `SimulationView.res`. Pour l'utiliser dans `App.res`:

```rescript
// App.res
@react.component
let make = () => {
  <SimulationView />
}
```

### Option 2 : Composant Personnalisé

Créez votre propre composant :

```rescript
// MaSimulation.res
@react.component
let make = () => {
  // Hook avec useReducer
  let (state, dispatch) = SimulationState.useSimulationState()
  let sim = state.simulation
  
  <div className="p-8">
    <h1 className="text-3xl font-bold mb-4">
      {"Mon Robot"->React.string}
    </h1>
    
    {/* Stats */}
    <div className="mb-4 flex gap-6">
      <div>
        <span className="font-semibold">{"Batterie: "->React.string}</span>
        <span>{sim.battery->Int.toString->React.string}</span>
      </div>
      <div>
        <span className="font-semibold">{"Score: "->React.string}</span>
        <span>{sim.score->Int.toString->React.string}</span>
      </div>
    </div>
    
    {/* Grille */}
    <GridView grid={sim.grid} robot={sim.robot} />
    
    {/* Contrôles */}
    <div className="mt-4 flex gap-2">
      <button 
        onClick={_ => dispatch(Tick)}
        className="px-4 py-2 bg-blue-500 text-white rounded">
        {"Un Pas"->React.string}
      </button>
      
      {state.isRunning
        ? <button onClick={_ => dispatch(Pause)}>{"Pause"->React.string}</button>
        : <button onClick={_ => dispatch(Start)}>{"Auto"->React.string}</button>
      }
      
      <button onClick={_ => dispatch(Reset)}>{"Reset"->React.string}</button>
    </div>
  </div>
}
```

## 🧪 Tester la Logique (Sans Interface)

Vous pouvez tester la logique pure dans la console Node :

```javascript
// test.mjs
import { create, step, isFinished } from './src/backend/Simulation.res.mjs'
import { countDirtyCells } from './src/backend/Grid.res.mjs'

// Créer simulation
let sim = create(8, 8, 0.2)
console.log("Position initiale:", sim.robot.position)
console.log("Batterie:", sim.battery)

// Simuler 10 pas
for (let i = 0; i < 10; i++) {
  sim = step(sim)
  console.log(`Pas ${i+1}: Score=${sim.score}, Batterie=${sim.battery}`)
}

console.log("Cellules sales restantes:", countDirtyCells(sim.grid))
console.log("Terminé?", isFinished(sim))
```

Exécuter :
```bash
node test.mjs
```

## ⚙️ Configuration

### Changer la Taille de la Grille

Dans `SimulationState.res` :
```rescript
let defaultWidth = 10   // Largeur
let defaultHeight = 10  // Hauteur
```

### Changer la Densité d'Obstacles

Dans `SimulationState.res` :
```rescript
let defaultObstacleDensity = 0.3  // 30% d'obstacles
```

### Changer la Batterie Initiale

Dans `Simulation.res` :
```rescript
let defaultBattery = 150  // Plus d'énergie
```

### Changer le Score par Cellule

Dans `Simulation.res`, fonction `step` :
```rescript
let newScore = wasCleaned ? sim.score + 20 : sim.score  // +20 au lieu de +10
```

## 🎨 Personnaliser les Couleurs

Dans `CellView.res` :
```rescript
let cellStyle = switch (cellState, isRobot) {
| (_, true)        => "bg-purple-500 border-2 border-purple-700"  // Robot violet
| (Clean, false)   => "bg-blue-200 hover:bg-blue-300"             // Propre bleu
| (Dirty, false)   => "bg-orange-400 hover:bg-orange-500"         // Sale orange
| (Wall, false)    => "bg-black"                                   // Mur noir
| (Empty, false)   => "bg-white"                                   // Vide blanc
}
```

## 🧠 Changer l'Algorithme

Dans `Simulation.res`, fonction `step` :
```rescript
// Utiliser stratégie simple au lieu d'intelligente
let action = Algorithm.simpleStep(sim)  // Au lieu de smartStep
```

## 📊 Ajouter des Statistiques

Dans votre composant :
```rescript
// Calculer progression
let totalCells = state.config.width * state.config.height
let dirtyCells = Grid.countDirtyCells(sim.grid)
let cleanedCells = totalCells - dirtyCells
let progress = Float.fromInt(cleanedCells) /. Float.fromInt(totalCells) *. 100.0

<p>{`Progression: ${progress->Float.toFixed(~digits=1)}%`->React.string}</p>
```

## 🐛 Debugging

### Afficher la Grille dans la Console

```rescript
// Utiliser le module Debug du fichier Examples.res
Debug.afficherGrilleConsole(sim)
```

### Voir les Actions en Temps Réel

Dans `Simulation.res`, ajouter des logs :
```rescript
let step = (sim: simulation): simulation => {
  // ... code existant ...
  
  // Log l'action
  let actionStr = switch action {
  | Algorithm.MoveForward => "Avancer"
  | Algorithm.TurnLeft => "Tourner Gauche"
  | Algorithm.TurnRight => "Tourner Droite"
  }
  Js.log(`Action: ${actionStr}`)
  
  // ... reste du code ...
}
```

## 📚 Documentation Complète

- **[IMPLEMENTATION_GUIDE.md](./IMPLEMENTATION_GUIDE.md)** - Architecture et code ReScript
- **[ALGORITHME_EXPLIQUE.md](./ALGORITHME_EXPLIQUE.md)** - Explication en français avec pseudo-code
- **[RECAPITULATIF.md](./RECAPITULATIF.md)** - Liste des modifications
- **[src/backend/Logic.res](./src/backend/Logic.res)** - Documentation technique
- **[src/backend/Examples.res](./src/backend/Examples.res)** - Exemples de code

## 🎯 Prochaines Étapes

1. ✅ Lancer le projet : `npm run res:dev` + `npm run dev`
2. 📖 Lire `ALGORITHME_EXPLIQUE.md` pour comprendre la logique
3. 🔍 Explorer `Examples.res` pour voir les cas d'usage
4. 🎨 Personnaliser l'interface dans `SimulationView.res`
5. 🧠 Modifier les algorithmes dans `Algorithm.res`

## ❓ Questions Fréquentes

### Le robot tourne en rond ?
Essayez la stratégie `smartStep` qui gère mieux les obstacles.

### La grille est trop petite/grande ?
Changez `defaultWidth` et `defaultHeight` dans `SimulationState.res`.

### Trop/pas assez d'obstacles ?
Ajustez `defaultObstacleDensity` (entre 0.0 et 1.0).

### Comment ajouter une nouvelle action ?
1. Ajouter un variant dans `SimulationState.action`
2. Gérer le cas dans le `reducer`
3. Créer un bouton qui dispatch cette action

### Le robot est trop lent/rapide ?
Changez l'intervalle du timer dans `SimulationState.res` :
```rescript
let id = setInterval(() => dispatch(Tick), 200)  // 200ms au lieu de 500ms
```

## 🎉 Félicitations !

Vous avez maintenant un robot nettoyeur fonctionnel en ReScript avec :
- ✅ Génération aléatoire d'obstacles
- ✅ Algorithmes intelligents
- ✅ Gestion de batterie et score
- ✅ Interface React moderne
- ✅ Architecture fonctionnelle robuste

**Bon codage ! 🚀**
