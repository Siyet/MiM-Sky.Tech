const PF = require('./PathFinding/PathFinding');

function getWeight(lat, lon){
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

let path = finder.findPath(0, 0, 99, 99, grid)

console.log(path)