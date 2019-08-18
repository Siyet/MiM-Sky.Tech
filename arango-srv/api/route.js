const createRouter = require('@arangodb/foxx/router');
const { db, query } = require("@arangodb");
const request = require("@arangodb/request");

const route_router = createRouter();
const collectionName = 'route'
const collection = db._collection(collectionName)
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