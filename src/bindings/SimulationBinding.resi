open Types

type simulation = Types.simulation
type cellState = Types.cellState
type direction = Types.direction
type position = Types.position
type robot = Types.robot

let createSimulation: int => simulation
let stepSimulation: simulation => simulation
let getCell: (grid, position) => option<cellState>
let isInside: (grid, position) => bool
