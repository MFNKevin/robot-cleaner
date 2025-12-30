# 🤖 Robot Nettoyeur - Explication Algorithmique (Français)

## 📋 Contexte

Ce document explique la logique du robot nettoyeur en **pseudo-code** et **français**, sans Python.

---

## 1️⃣ MODÉLISATION DES DONNÉES

### Types de Base

```
TYPE CelluleÉtat = 
  | Vide       // Cellule non visitée
  | Sale       // Cellule à nettoyer
  | Propre     // Cellule nettoyée
  | Mur        // Obstacle

TYPE Direction = Nord | Sud | Est | Ouest

TYPE Position = {
  x: entier
  y: entier
}

TYPE Robot = {
  position: Position
  direction: Direction
}

TYPE Simulation = {
  grille: tableau 2D de CelluleÉtat
  robot: Robot
  batterie: entier      // Énergie restante
  score: entier         // Points (cellules nettoyées)
  nbPas: entier         // Nombre de pas effectués
}
```

---

## 2️⃣ GÉNÉRATION DU MONDE

### Algorithme : Créer Grille Avec Obstacles

```
FONCTION créerGrilleAvecObstacles(largeur, hauteur, densitéObstacles):
  
  // Initialiser grille vide
  grille ← tableau[hauteur][largeur]
  
  // Remplir chaque cellule
  POUR chaque ligne y de 0 à hauteur-1:
    POUR chaque colonne x de 0 à largeur-1:
      
      SI (x == 0 ET y == 0) ALORS:
        // Position de départ du robot : toujours libre
        grille[y][x] ← Sale
      
      SINON:
        // Générer nombre aléatoire entre 0 et 1
        aléa ← nombreAléatoire()
        
        SI aléa < densitéObstacles ALORS:
          grille[y][x] ← Mur
        SINON:
          grille[y][x] ← Sale
        FIN SI
      
      FIN SI
    
    FIN POUR
  FIN POUR
  
  RETOURNER grille

FIN FONCTION
```

**Exemple d'exécution:**
```
créerGrilleAvecObstacles(8, 8, 0.2)

Résultat (grille 8×8 avec ~20% de murs):
S = Sale, M = Mur, R = Robot

R  S  S  M  S  S  S  S
S  S  M  S  S  S  M  S
S  S  S  S  M  S  S  S
M  S  S  S  S  S  S  M
S  S  M  S  S  M  S  S
S  S  S  S  S  S  S  S
S  M  S  S  M  S  S  S
S  S  S  S  S  S  M  S
```

---

## 3️⃣ LOGIQUE DE MOUVEMENT

### A. Fonctions Auxiliaires

```
// Vérifie si position est dans les limites
FONCTION estDansLesLimites(grille, position):
  hauteur ← taille(grille)
  largeur ← taille(grille[0])
  
  RETOURNER (
    position.x >= 0 ET 
    position.x < largeur ET 
    position.y >= 0 ET 
    position.y < hauteur
  )
FIN FONCTION

// Calcule la prochaine position sans bouger
FONCTION prochainePosition(robot):
  SELON robot.direction:
    CAS Nord:  RETOURNER {x: robot.position.x, y: robot.position.y - 1}
    CAS Sud:   RETOURNER {x: robot.position.x, y: robot.position.y + 1}
    CAS Est:   RETOURNER {x: robot.position.x + 1, y: robot.position.y}
    CAS Ouest: RETOURNER {x: robot.position.x - 1, y: robot.position.y}
  FIN SELON
FIN FONCTION

// Vérifie si position est valide (pas mur, pas hors limites)
FONCTION positionValide(simulation, position):
  SI NON estDansLesLimites(simulation.grille, position) ALORS:
    RETOURNER Faux
  FIN SI
  
  cellule ← simulation.grille[position.y][position.x]
  
  SI cellule == Mur ALORS:
    RETOURNER Faux
  SINON:
    RETOURNER Vrai
  FIN SI
FIN FONCTION
```

### B. Tourner le Robot

```
FONCTION tournerGauche(robot):
  nouvelleDirection ← SELON robot.direction:
    CAS Nord:  Ouest
    CAS Ouest: Sud
    CAS Sud:   Est
    CAS Est:   Nord
  FIN SELON
  
  RETOURNER {
    position: robot.position,
    direction: nouvelleDirection
  }
FIN FONCTION

FONCTION tournerDroite(robot):
  nouvelleDirection ← SELON robot.direction:
    CAS Nord:  Est
    CAS Est:   Sud
    CAS Sud:   Ouest
    CAS Ouest: Nord
  FIN SELON
  
  RETOURNER {
    position: robot.position,
    direction: nouvelleDirection
  }
FIN FONCTION
```

### C. Algorithme Simple

```
FONCTION stratégieSimple(simulation):
  
  // Regarder devant
  prochPos ← prochainePosition(simulation.robot)
  
  // Décision avec Pattern Matching
  SI positionValide(simulation, prochPos) ALORS:
    RETOURNER Avancer
  SINON:
    RETOURNER TournerDroite
  FIN SI

FIN FONCTION
```

**Comportement:**
- Si libre devant → Avancer
- Si mur/bordure → Tourner à droite

**Visualisation:**
```
Étape 1: Robot face à un mur
┌─────┬─────┬─────┐
│  R→ │ ███ │     │
└─────┴─────┴─────┘
Action: TournerDroite

Étape 2: Robot tourné
┌─────┬─────┬─────┐
│  R↓ │ ███ │     │
└─────┴─────┴─────┘
Action: Avancer
```

### D. Algorithme Intelligent (Préférence Gauche)

```
FONCTION stratégieIntelligente(simulation):
  
  // Position devant
  posDevant ← prochainePosition(simulation.robot)
  
  // Position à gauche (simuler rotation)
  robotGauche ← tournerGauche(simulation.robot)
  posGauche ← prochainePosition(robotGauche)
  
  // Décision avec priorité à gauche
  SI positionValide(simulation, posDevant) ALORS:
    // Devant libre : avancer
    RETOURNER Avancer
  
  SINON SI positionValide(simulation, posGauche) ALORS:
    // Devant bloqué mais gauche libre : tourner gauche
    RETOURNER TournerGauche
  
  SINON:
    // Tout bloqué : tourner droite
    RETOURNER TournerDroite
  
  FIN SI

FIN FONCTION
```

**Avantage:** Explore mieux les coins et évite de tourner en rond.

**Visualisation:**
```
Situation : Robot dans un coin

┌─────┬─────┬─────┐
│ ███ │ ███ │     │
├─────┼─────┼─────┤
│ ███ │  R→ │     │
└─────┴─────┴─────┘

1. Devant → bloqué (mur)
2. Gauche → bloqué (mur)
3. Action → TournerDroite

Après rotation:
┌─────┬─────┬─────┐
│ ███ │ ███ │     │
├─────┼─────┼─────┤
│ ███ │  R↓ │     │ ← Peut maintenant avancer
└─────┴─────┴─────┘
```

---

## 4️⃣ CYCLE DE SIMULATION (TICK)

### Un Pas de Simulation

```
FONCTION unPas(simulation):
  
  // ─── Vérification batterie ───
  SI simulation.batterie <= 0 ALORS:
    RETOURNER simulation  // Ne rien faire
  FIN SI
  
  // ─── Phase 1: Nettoyage ───
  posActuelle ← simulation.robot.position
  celluleActuelle ← simulation.grille[posActuelle.y][posActuelle.x]
  
  aCetéNettoyé ← Faux
  SI celluleActuelle == Sale ALORS:
    simulation.grille[posActuelle.y][posActuelle.x] ← Propre
    aCetéNettoyé ← Vrai
  FIN SI
  
  // ─── Phase 2: Décision ───
  action ← stratégieIntelligente(simulation)
  
  // ─── Phase 3: Application de l'action ───
  nouveauRobot ← robot actuel
  coûtBatterie ← 0
  
  SELON action:
    CAS Avancer:
      nouvellePos ← prochainePosition(simulation.robot)
      nouveauRobot ← {
        position: nouvellePos,
        direction: simulation.robot.direction
      }
      coûtBatterie ← 1  // Avancer coûte 1 batterie
    
    CAS TournerGauche:
      nouveauRobot ← tournerGauche(simulation.robot)
      coûtBatterie ← 0  // Tourner est gratuit
    
    CAS TournerDroite:
      nouveauRobot ← tournerDroite(simulation.robot)
      coûtBatterie ← 0
  FIN SELON
  
  // ─── Phase 4: Mise à jour du score ───
  nouveauScore ← simulation.score
  SI aCetéNettoyé ALORS:
    nouveauScore ← nouveauScore + 10
  FIN SI
  
  // ─── Phase 5: Retourner nouvel état ───
  RETOURNER {
    grille: simulation.grille,
    robot: nouveauRobot,
    batterie: simulation.batterie - coûtBatterie,
    score: nouveauScore,
    nbPas: simulation.nbPas + 1
  }

FIN FONCTION
```

**Exemple complet:**

```
État Initial:
  Position: (0, 0)
  Direction: Nord
  Batterie: 100
  Score: 0
  Grille[0][0]: Sale

─────────────────────────────────────

Tick 1:
  1. Nettoyer (0,0) → Grille[0][0] = Propre, Score = 10
  2. Regarder Nord → Mur
  3. Tourner Droite → Direction = Est
  4. Batterie = 100 (tourner gratuit)
  5. Pas = 1

Tick 2:
  1. Grille[0][0] déjà Propre → Score reste 10
  2. Regarder Est → Libre
  3. Avancer → Position = (1, 0)
  4. Batterie = 99 (avancer coûte 1)
  5. Pas = 2

Tick 3:
  1. Nettoyer (1,0) → Grille[1][0] = Propre, Score = 20
  2. Regarder Est → Libre
  3. Avancer → Position = (2, 0)
  4. Batterie = 98
  5. Pas = 3

... et ainsi de suite ...
```

---

## 5️⃣ GESTION D'ÉTAT (REACT)

### Actions Possibles

```
TYPE Action =
  | Tick                              // Avancer d'un pas
  | Réinitialiser                     // Recommencer
  | ChangerTaille(largeur, hauteur)   // Nouvelle grille
  | ChangerDensité(densité)           // Nouvelle densité obstacles
  | Démarrer                          // Mode automatique
  | Pause                             // Mettre en pause
```

### Reducer (Machine à États)

```
FONCTION reducer(état, action):
  
  SELON action:
    
    CAS Tick:
      SI simulationTerminée(état.simulation) ALORS:
        RETOURNER {
          ...état,
          enCours: Faux
        }
      SINON:
        RETOURNER {
          ...état,
          simulation: unPas(état.simulation)
        }
      FIN SI
    
    CAS Réinitialiser:
      RETOURNER {
        ...état,
        simulation: créerSimulation(état.config),
        enCours: Faux
      }
    
    CAS ChangerTaille(largeur, hauteur):
      nouvelleConfig ← {
        largeur: largeur,
        hauteur: hauteur,
        densité: état.config.densité
      }
      RETOURNER {
        ...état,
        config: nouvelleConfig,
        simulation: créerSimulation(nouvelleConfig),
        enCours: Faux
      }
    
    CAS ChangerDensité(densité):
      nouvelleConfig ← {
        ...état.config,
        densité: densité
      }
      RETOURNER {
        ...état,
        config: nouvelleConfig,
        simulation: créerSimulation(nouvelleConfig),
        enCours: Faux
      }
    
    CAS Démarrer:
      RETOURNER {...état, enCours: Vrai}
    
    CAS Pause:
      RETOURNER {...état, enCours: Faux}
  
  FIN SELON

FIN FONCTION
```

### Utilisation avec Timer

```
FONCTION utiliserSimulation():
  
  // État initial
  étatInitial ← {
    simulation: créerSimulation(8, 8, 0.2),
    enCours: Faux,
    config: {largeur: 8, hauteur: 8, densité: 0.2}
  }
  
  // Reducer React
  (état, dispatch) ← useReducer(reducer, étatInitial)
  
  // Timer automatique
  EFFET (quand état.enCours change):
    SI état.enCours ALORS:
      // Démarrer timer (500ms)
      idTimer ← setInterval(() => {
        dispatch(Tick)
      }, 500)
      
      // Cleanup au démontage
      RETOURNER () => clearInterval(idTimer)
    FIN SI
  FIN EFFET
  
  RETOURNER (état, dispatch)

FIN FONCTION
```

---

## 6️⃣ RENDU DE LA GRILLE

### Algorithme de Rendu

```
FONCTION afficherGrille(simulation):
  
  grille ← simulation.grille
  robot ← simulation.robot
  
  hauteur ← taille(grille)
  largeur ← taille(grille[0])
  
  // Créer tableau de cellules
  cellules ← tableau vide
  
  POUR chaque ligne y de 0 à hauteur-1:
    POUR chaque colonne x de 0 à largeur-1:
      
      position ← {x: x, y: y}
      estRobot ← (robot.position == position)
      étatCellule ← grille[y][x]
      
      // Déterminer couleur
      couleur ← SELON (étatCellule, estRobot):
        CAS (_, Vrai):       "Bleu"       // Robot (priorité)
        CAS (Propre, Faux):  "Vert"       // Cellule nettoyée
        CAS (Sale, Faux):    "Rouge"      // Cellule sale
        CAS (Mur, Faux):     "Gris Foncé" // Obstacle
        CAS (Vide, Faux):    "Gris Clair" // Non visité
      FIN SELON
      
      // Déterminer icône
      icône ← SI estRobot ALORS:
        SELON robot.direction:
          CAS Nord:  "⬆️"
          CAS Sud:   "⬇️"
          CAS Est:   "➡️"
          CAS Ouest: "⬅️"
        FIN SELON
      SINON:
        SELON étatCellule:
          CAS Propre: "✓"
          CAS Sale:   "◼"
          CAS Mur:    "🧱"
          CAS Vide:   ""
        FIN SELON
      FIN SI
      
      // Créer cellule visuelle
      cellule ← créerCellule(couleur, icône)
      ajouter cellule à cellules
    
    FIN POUR
  FIN POUR
  
  // Afficher grille CSS
  afficher cellules en grille(largeur colonnes)

FIN FONCTION
```

---

## 7️⃣ CONDITIONS DE FIN

```
FONCTION simulationTerminée(simulation):
  
  // Fin si batterie vide
  SI simulation.batterie <= 0 ALORS:
    RETOURNER Vrai, "Batterie épuisée"
  FIN SI
  
  // Fin si toutes cellules nettoyées
  nbCellulesSales ← compterCellulesSales(simulation.grille)
  SI nbCellulesSales == 0 ALORS:
    RETOURNER Vrai, "Toutes les cellules nettoyées !"
  FIN SI
  
  // Sinon continuer
  RETOURNER Faux, Aucun

FIN FONCTION

FONCTION compterCellulesSales(grille):
  compteur ← 0
  
  POUR chaque ligne dans grille:
    POUR chaque cellule dans ligne:
      SI cellule == Sale ALORS:
        compteur ← compteur + 1
      FIN SI
    FIN POUR
  FIN POUR
  
  RETOURNER compteur
FIN FONCTION
```

---

## 🎯 RÉSUMÉ COMPLET

### Flux d'exécution

```
1. INITIALISATION
   ↓
   créerGrilleAvecObstacles(8, 8, 0.2)
   ↓
   créerRobot({x: 0, y: 0}, Nord)
   ↓
   état = {grille, robot, batterie: 100, score: 0, pas: 0}

2. BOUCLE PRINCIPALE (Tick)
   ↓
   ┌─────────────────────────────────┐
   │ A. Vérifier batterie            │
   │ B. Nettoyer cellule actuelle    │
   │ C. Décider action (algorithme)  │
   │ D. Appliquer action             │
   │ E. Mettre à jour score/batterie │
   │ F. Incrémenter pas              │
   └─────────────────────────────────┘
   ↓
   SI terminé ALORS arrêter
   SINON répéter Tick

3. RENDU
   ↓
   Pour chaque cellule : déterminer couleur + icône
   ↓
   Afficher grille avec CSS Grid
```

### Coûts

- **Avancer:** 1 batterie
- **Tourner:** 0 batterie
- **Nettoyer:** +10 score (automatique)

### Configuration

- Taille : N × M (ex: 8 × 8)
- Densité obstacles : 0.0 à 1.0 (ex: 0.2 = 20%)
- Batterie initiale : 100
- Position départ : (0, 0) toujours libre

---

## 🚀 OPTIMISATIONS POSSIBLES

### 1. Mémoire des cellules visitées

```
TYPE Robot = {
  position: Position
  direction: Direction
  cellulesVisitées: ensemble de Position
}

DANS unPas():
  ajouter posActuelle à robot.cellulesVisitées
```

### 2. Stratégie avec exploration

```
FONCTION stratégieExploration(simulation):
  posDevant ← prochainePosition(simulation.robot)
  
  SI posDevant NON visitée ET valide ALORS:
    RETOURNER Avancer  // Préférer cellules non visitées
  SINON SI posDevant valide ALORS:
    RETOURNER Avancer
  SINON:
    RETOURNER TournerGauche
  FIN SI
FIN FONCTION
```

### 3. Calcul du chemin optimal (A*)

```
// Plus complexe, nécessite algorithme de pathfinding
// Trouve le chemin le plus court vers toutes cellules sales
```

---

**✨ Voilà ! Vous avez maintenant toute la logique expliquée en français avec pseudo-code.**
