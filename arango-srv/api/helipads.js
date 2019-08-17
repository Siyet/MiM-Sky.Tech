const createRouter = require('@arangodb/foxx/router');
const { db, query } = require("@arangodb");

const helipad_router = createRouter();
const collectionName = 'helipads'
const collection = db._collection(collectionName)
module.exports = helipad_router

helipad_router.get('/helipads', function (req, res) {
    let helipads = query`for i in ${collection} return i`
    res.send(helipads);
  })
  .response(['application/json'], 'helipads')
  .summary('get all helipads')
  .description('Get all helipads');

  
helipad_router.get('/helipads/:id', function (req, res) {
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
.response(['application/json'], 'helipad')
.summary('get helipad by id')
.description('Get helipad by id');

helipad_router.get('/helipads/min', function(req, res){
    let helipads = query`for i in ${collection} return {id:i._key, geopoint:i.position}`
    res.send(helipads);
})
.response(['application/json'], 'helipads')
.summary('get all helipads in minimalist style')
.description('Get all helipads in minimalist style');