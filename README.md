# 🤖 Robot Nettoyeur - Simulation Interactive

Une simulation de robot nettoyeur autonome développée en ReScript avec React. Le robot explore intelligemment une grille avec obstacles et nettoie toutes les cellules sales de manière systématique.

## ✨ Fonctionnalités

- **Exploration intelligente** : Algorithme qui privilégie les zones non visitées
- **Anti-blocage** : Comportement aléatoire pour sortir des zones piège
- **Génération procédurale** : Obstacles placés aléatoirement (15% de densité)
- **Mémoire de visites** : Le robot garde la trace de toutes les cellules explorées
- **Visualisation en temps réel** : Interface React avec Tailwind CSS
- **Statistiques complètes** : Batterie, score, pas effectués, cellules restantes

## 🛠️ Technologies

- [ReScript](https://rescript-lang.org) 12.0 avec @rescript/react et JSX v4
- React 19 avec hooks (useReducer, useEffect)
- Vite 7 (build tool et dev server)
- Tailwind CSS 4 (styling)
- Architecture fonctionnelle pure avec pattern matching

## 🚀 Installation et Démarrage

### Installation des dépendances
```sh
npm install
```

### Lancer le projet

**Option 1 : Deux terminaux (recommandé)**

Terminal 1 - Compiler ReScript en mode watch :
```sh
npm run res:dev
```

Terminal 2 - Lancer le serveur Vite :
```sh
npm run dev
```

**Option 2 : Si problèmes PowerShell**

Compiler ReScript :
```sh
cmd /c npm run res:build
```

Lancer Vite :
```sh
node node_modules/vite/bin/vite.js
```

Puis ouvrez [http://localhost:5173](http://localhost:5173)

## 🎮 Utilisation

- **➡️ Un Pas** : Exécuter un seul tick de simulation
- **▶️ Auto** : Lancer la simulation automatique (1 tick toutes les 100ms)
- **⏸️ Pause** : Mettre en pause la simulation automatique
- **🔄 Reset** : Réinitialiser la grille avec nouveaux obstacles aléatoires

## 🏗️ Architecture

```
src/
├── backend/          # Logique métier (pur ReScript)
│   ├── Types.res
│   ├── Grid.res
│   ├── Robot.res
│   ├── Algorithm.res
│   └── Simulation.res
├── frontend/         # Composants React
│   ├── CellView.res
│   └── GridView.res
├── state/            # Gestion d'état React
│   └── SimulationState.res
├── App.res           # Composant principal
└── Main.res          # Point d'entrée
```

### 📁 Description Détaillée des Fichiers

#### Backend (Logique Métier)

**`Types.res`** - Définitions des types de domaine
- `position` : Structure `{x: int, y: int}` pour les coordonnées
- `cellState` : Variant `Empty | Dirty | Clean | Wall` pour l'état d'une cellule
- `direction` : Variant `North | South | East | West` pour l'orientation du robot
- `grid` : Type alias pour `array<array<cellState>>` (matrice 2D)
- `robot` : Structure `{position, direction}` représentant le robot
- `simulation` : Structure complète `{grid, robot, battery, score, steps, visited}` contenant tout l'état de la simulation
- Rôle : Fondation type-safe pour tout le projet, garantit la cohérence des données

**`Grid.res`** - Manipulation de la grille
- `create(width, height)` : Crée une grille vide remplie de cellules `Dirty`
- `createWithObstacles(width, height, density)` : Génère une grille avec des obstacles aléatoires, garantit que (0,0) est libre pour le départ du robot
- `getCell(grid, pos)` : Récupère l'état d'une cellule à une position donnée (retourne `option<cellState>`)
- `isInside(grid, pos)` : Vérifie si une position est dans les limites de la grille
- `cleanCell(grid, pos)` : Nettoie une cellule `Dirty` → `Clean`, retourne `bool` (true si nettoyée)
- `countDirtyCells(grid)` : Compte le nombre de cellules sales restantes pour détecter la fin
- Rôle : Toutes les opérations de lecture/modification de la grille

**`Robot.res`** - Mouvements du robot
- `create(pos)` : Crée un nouveau robot à une position donnée, orienté vers le Nord
- `turnLeft(robot)` : Fait tourner le robot de 90° à gauche (North→West, West→South, etc.)
- `turnRight(robot)` : Fait tourner le robot de 90° à droite (North→East, East→South, etc.)
- `nextPosition(robot)` : Calcule la position devant le robot selon sa direction actuelle
- `moveForward(robot)` : Déplace le robot d'une case vers l'avant dans sa direction
- Rôle : Gère tous les déplacements et rotations du robot de façon pure (sans effets de bord)

**`Algorithm.res`** - Stratégies de décision
- Type `action` : Variant `MoveForward | TurnLeft | TurnRight` représentant les actions possibles
- `isValidPosition(sim, pos)` : Vérifie qu'une position est accessible (pas un mur, dans les limites)
- `getVisitCount(sim, pos)` : Récupère le nombre de fois qu'une cellule a été visitée
- `simpleStep(sim)` : Algorithme basique (avancer si libre, sinon tourner à droite)
- `smartStep(sim)` : Algorithme intelligent qui préfère tourner à gauche si bloqué
- `explorerStep(sim)` : **Algorithme principal** - Exploration exhaustive avec :
  - Priorité absolue aux cellules jamais visitées (0 visites)
  - Détection de blocage (>10 visites sur position actuelle)
  - Comportement aléatoire anti-blocage utilisant `mod(steps, 3)`
  - Choix de la direction la moins visitée parmi devant/gauche/droite
- Rôle : Cerveau du robot, décide quelle action prendre à chaque tick

**`Simulation.res`** - Orchestration de la simulation
- `defaultBattery = 5000` : Configuration de la batterie de départ
- `defaultWidth = 8`, `defaultHeight = 8` : Dimensions par défaut de la grille
- `defaultObstacleDensity = 0.15` : 15% de la grille sera des obstacles
- `create(width, height, density)` : Crée une nouvelle simulation complète avec grille, robot, et initialise la matrice `visited` à zéro partout
- `createDefault()` : Crée une simulation avec les paramètres par défaut
- `step(sim)` : **Fonction principale** - Exécute un tick de simulation :
  1. Incrémente le compteur de visites pour la position actuelle
  2. Nettoie la cellule actuelle si sale (+10 score)
  3. Appelle `Algorithm.explorerStep` pour décider l'action
  4. Applique l'action (mouvement coûte 1 batterie, rotation gratuite)
  5. Retourne la nouvelle simulation (immutable)
- `isFinished(sim)` : Vérifie si la simulation est terminée (batterie épuisée ou plus de saleté)
- Rôle : Coordonne toutes les étapes d'un cycle de simulation

#### Frontend (Interface React)

**`CellView.res`** - Composant d'affichage d'une cellule
- Props : `cellState`, `isRobot`, `direction`
- Utilise pattern matching sur `(cellState, isRobot)` pour décider :
  - Couleur de fond (vert si propre, beige si sale, gris si mur)
  - Icône à afficher :
    - Robot : ⬆️⬇️➡️⬅️ selon direction
    - Cellule propre : ✓
    - Cellule sale : ◼
    - Mur : 🧱
- Styling avec Tailwind : bordures, tailles, animations hover
- Rôle : Rendu visuel d'une seule cellule de la grille

**`GridView.res`** - Composant d'affichage de la grille complète
- Props : `grid` (matrice de cellules), `robot` (position et direction)
- Calcule dynamiquement la taille des cellules en fonction des dimensions
- Utilise CSS Grid avec `gridTemplateColumns` pour layout responsive
- Parcourt la grille avec `Array.mapWithIndex` pour générer tous les `CellView`
- Détermine si chaque cellule contient le robot avec `pos.x == robot.position.x && pos.y == robot.position.y`
- Rôle : Assemble toutes les cellules en une grille visuelle complète

#### State (Gestion d'État)

**`SimulationState.res`** - Hook personnalisé avec useReducer
- Type `config` : Structure `{width, height, obstacleDensity}` pour les paramètres
- Type `state` : Structure `{simulation, config, isRunning, intervalId}` pour l'état global
- Type `action` : Variant avec 6 actions possibles :
  - `Tick` : Avancer d'un pas (appelle `Simulation.step`)
  - `Reset` : Recréer une nouvelle grille avec mêmes paramètres
  - `SetSize(w, h)` : Changer dimensions et recréer
  - `SetObstacleDensity(density)` : Changer densité obstacles et recréer
  - `Start` : Lancer simulation automatique (timer 100ms)
  - `Pause` : Arrêter simulation automatique
- `reducer(state, action)` : Pattern matching exhaustif sur les actions, retourne nouvel état
- `useSimulationState()` : Hook qui :
  - Initialise l'état avec `useReducer`
  - Configure timer avec `useEffect` pour mode auto
  - Nettoie `intervalId` au démontage
  - Retourne `(state, dispatch)`
- Rôle : Centralise toute la logique d'état et les transitions

#### Application

**`App.res`** - Composant racine de l'application
- Appelle `useSimulationState()` pour obtenir `(state, dispatch)`
- Structure de l'interface en 3 sections :
  1. **Statistiques** : Affiche batterie, score, nombre de pas, cellules restantes
  2. **Grille** : Rend `<GridView>` avec la simulation actuelle
  3. **Contrôles** : 4 boutons (Un Pas, Auto/Pause, Reset)
- Gère la désactivation des boutons selon l'état (`isRunning`, `isFinished`)
- Styling avec Tailwind : gradients, ombres, hover effects, responsive
- Rôle : Interface utilisateur complète et interactions

**`Main.res`** - Point d'entrée de l'application
- Importe `index.css` (Tailwind)
- Sélectionne `#root` dans le DOM
- Crée racine React avec `Client.createRoot`
- Rend `<App />` avec `<React.StrictMode>`
- Rôle : Bootstrap de l'application React dans le navigateur

## 🧠 Algorithme d'Exploration

L'algorithme `explorerStep` garantit une exploration exhaustive :

1. **Priorité cellules neuves** : Va toujours vers les cellules jamais visitées (0 visites)
2. **Détection de blocage** : Si position visitée >10 fois → robot coincé
3. **Anti-blocage aléatoire** : Comportement pseudo-aléatoire pour sortir des pièges
4. **Choix optimal** : Compare 3 directions et choisit la moins visitée
5. **Batterie large** : 5000 de batterie pour explorer exhaustivement

## 📊 Configuration

Dans [Simulation.res](src/backend/Simulation.res) :

```rescript
let defaultBattery = 5000           // Batterie initiale
let defaultWidth = 8                // Largeur de la grille
let defaultHeight = 8               // Hauteur de la grille
let defaultObstacleDensity = 0.15   // 15% d'obstacles
```

## 🎨 Légende des Cellules

- **⬆️⬇️➡️⬅️** : Robot (avec direction)
- **◼** : Cellule sale (à nettoyer)
- **✓** : Cellule propre (nettoyée)
- **🧱** : Obstacle (mur)

## 📚 Documentation Supplémentaire

- [IMPLEMENTATION_GUIDE.md](IMPLEMENTATION_GUIDE.md) : Guide détaillé d'implémentation
- [ALGORITHME_EXPLIQUE.md](ALGORITHME_EXPLIQUE.md) : Explication en français avec pseudocode
- [QUICKSTART.md](QUICKSTART.md) : Guide de démarrage rapide

## 📝 Notes Techniques

### Pattern Matching et Variants

Le projet utilise intensivement les variants ReScript pour la sûreté de type :

```rescript
type cellState = Empty | Dirty | Clean | Wall
type action = MoveForward | TurnLeft | TurnRight
```

### useReducer Pattern

La gestion d'état utilise le pattern reducer pour un état complexe :

```rescript
type action = Tick | Reset | Start | Pause | SetSize(int, int)
let (state, dispatch) = useSimulationState()
```

### Mémoire des Visites

Une matrice `visited: array<array<int>>` garde le nombre de visites par cellule pour guider l'exploration.

## 🐛 Dépannage

**Erreur PowerShell** : Utiliser `cmd /c` devant les commandes npm

**Page blanche** : Vérifier que les deux processus tournent (ReScript + Vite)

**Robot ne termine pas** : Certaines configurations d'obstacles peuvent créer des zones inaccessibles

## 📄 Licence

MIT
