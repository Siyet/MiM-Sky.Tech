const createRouter = require('@arangodb/foxx/router');
const { db, query } = require("@arangodb");
const request = require("@arangodb/request");

const helipad_router = createRouter();
const collectionName = 'helicopter'
const collection = db._collection(collectionName)
module.exports = helipad_router

helipad_router.get('/helicopter/:id', function (req, res){
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