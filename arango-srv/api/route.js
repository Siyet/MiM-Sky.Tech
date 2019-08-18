const createRouter = require('@arangodb/foxx/router');
const { db, query } = require("@arangodb");
const PF = require('../scripts/PathFinding/PathFinding');

const route_router = createRouter();
const collectionName = 'route'
const collection = db._collection(collectionName)
const forbidden_zone = db._collection('forbidden_zone')
module.exports = route_router


route_router.get('/route/:id', function (req, res) {
    try {
        const data = collection.document(req.pathParams.id);
        res.send(data)
    } catch (e) {
        if (!e.isArangoError || e.errorNum !== DOC_NOT_FOUND) {
            throw e;
        }
        res.throw(404, 'The entry does not exist', e);
    }
})
.response(['application/json'], 'Route')
.summary('get route by id')
.description('Get reoute by id')
.tag('Route')


route_router.post('/route/find', function(req,res){
    let data = req.body

    function getWeight(lat, lon){
        let result = query`for i in ${forbidden_zone} 
              filter GEO_CONTAINS(i.path,[${lat}, ${lon}])
              return i`
        
        if(result.length > 0) {console.log(lat, lon);return 1}
        else return 0
    }
    
    let fst = data.start
    let lst = data.end
    
    let delta_w = (fst[0]-lst[0])/100
    let delta_h = (fst[1]-lst[1])/100
    let x = delta_w >= 0? false:true
    let y = delta_h >= 0? false:true

    let current_w = fst[0]
    let current_h = fst[1]
    
    let matrix = []
    for (let i = 0; i < 100; i++) {
        let sub = []
        for (let j = 0; j < 100; j++) {
            let data = getWeight(current_w, current_h)
            if(y) current_h -= delta_h
            else current_h += delta_h
            
            sub.push(data)
        }
        if(x) current_w -= delta_w
        else current_w += delta_w
        
        matrix.push(sub)
    }
    
    let grid = new PF.Grid(matrix);
    let finder = new PF.AStarFinder({
        // allowDiagonal: true,
        dontCrossCorners: true
    });
    
    let path = finder.findPath(0, 0, 99, 99, grid)
    let path_w = fst[0]
    let path_h = fst[1]//37.539188888889,55.745916666667

    let current_x = 0
    let current_y = 0

    let result = [[path_w, path_h]]
    for (let i = 0; i < path.length; i++) {
        let curr_point = path[i]
        if(current_x < curr_point[0]){//
            path_w -= delta_w;
            current_x = curr_point[0]
        }
        else if(current_x > curr_point[0]){
            path_w += delta_w;
            
            current_x = curr_point[0]
        }

        if(current_y < curr_point[1]){//
            path_h -= delta_h
            
            current_y = curr_point[1]
        } else if(current_y > curr_point[1]){
            path_h += delta_h
            
            current_y = curr_point[1]
        }
        result.push([path_w, path_h])
    }

    let save_result = query`insert {
        from:${data.start},
        to:${data.end},
        geo:GEO_LINESTRING(${result})
    } into ${collection}`
    

    res.send(result)
})
.body(['application/json'], `{"start":[37.649883333333, 55.733136111111],"end":[37.593216666667, 55.728483333333]}`)
.response(['application/json'], 'start point, end point')
.summary('Find best route')
.description('Find best route')
.tag('Route')
