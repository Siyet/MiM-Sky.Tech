const createRouter = require('@arangodb/foxx/router');
const { db, query } = require("@arangodb");
const request = require("@arangodb/request");

const fz_router = createRouter();
const collectionName = 'forbidden_zone'
const collection = db._collection(collectionName)
module.exports = fz_router

fz_router.get('/fz/:lat/:lon', function(req,res){
    let lat = req.pathParams.lat
    let lon = req.pathParams.lon
    console.log(lat, lon)
    let result = query`for i in ${collection} filter GEO_CONTAINS(GEO_POLYGON(i.path),[${lat}, ${lon}]) return i`
    res.send(result);
})
.response(['application/json'], 'FZ')
.summary('get forbidden zone by lat,lon')
.description('Get forbidden zone by id')
.tag('Forbidden zone')