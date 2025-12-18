// Accès backend → frontend

/* Exportation des types pour que le frontend y accède */
type simulation = Types.simulation
type cellState = Types.cellState
type direction = Types.direction
type position = Types.position
type robot = Types.robot

/* Exportation des fonctions backend pour le frontend */
let createSimulation = Simulation.create
let stepSimulation = Simulation.step
let getCell = Grid.getCell
let isInside = Grid.isInside