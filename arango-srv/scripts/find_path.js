const PF = require('pathfinding');
// var grid = new PF.Grid(100, 100); 
// grid.setWalkableAt(0, 1, false);

// let matrix = []
// for (let i = 0; i < 100; i++) {
//     let sub = []
//     for (let j = 0; j < 100; j++) {
//         sub.push(Math.floor((Math.random() * 1)))
//     }
//     matrix.push(sub)
    
// }


// const request = require('@arangodb/request')

function getWeight(lat, lon){
    // let response = request.get('')
    // return Math.floor((Math.random() * 1))
    return 0
}

let fst = [37.649883333333, 55.733136111111]
let lst = [37.593216666667, 55.728483333333]

let delta_w = (fst[0]-lst[0])/100
let delta_h = (fst[1]-lst[1])/100

let current_w = fst[0]
let current_h = fst[1]

let matrix = []
for (let i = 0; i < 100; i++) {
    let sub = []
    for (let j = 0; j < 100; j++) {
        let data = getWeight(current_w, current_h)
        current_h += delta_h
        sub.push(data)
    }
    current_w += delta_w
    matrix.push(sub)
}

let grid = new PF.Grid(matrix);
let finder = new PF.AStarFinder();

return finder.findPath(0, 0, 99, 99, grid)
