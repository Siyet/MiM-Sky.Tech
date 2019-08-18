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
    query`for i in forbidden_zone filter IS_IN_POLYGON(i.path, ${lat}, ${lon}) return i`
})
.response(['application/json'], 'FZ')
.summary('get forbidden zone by lat,lon')
.description('Get forbidden zone by id')
.tag('Forbidden zone')
/**
for i in forbidden_zone
filter IS_IN_POLYGON(i.path, 55.720729, 37.540788)
return i
 */