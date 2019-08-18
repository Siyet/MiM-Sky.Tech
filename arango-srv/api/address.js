const createRouter = require('@arangodb/foxx/router');
const { db, query } = require("@arangodb");
const request = require("@arangodb/request");

const address_router = createRouter();
const collectionName = 'address'
const collection = db._collection(collectionName)
module.exports = address_router

address_router.get('/address/id/:id', function(req, res){
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
.response(['application/json'], 'find doc')
.summary('Get address by id')
.description('Get address by id')
.tag('Address')

address_router.get('/address/:text', function(req,res){
    let finded_string = decodeURIComponent(req.pathParams.text)
    let result = query`for doc in FULLTEXT(${collection}, "title", "Варшавское") return doc`
    res.send(result);
})
.response(['application/json'], 'finded ids')
.summary('Full test search')
.description('Full test search')
.tag('Address')