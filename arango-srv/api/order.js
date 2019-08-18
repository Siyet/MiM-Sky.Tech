const createRouter = require('@arangodb/foxx/router');
const { db, query } = require("@arangodb");
const request = require("@arangodb/request");

const order_router = createRouter();
const collectionName = 'order'
const collection = db._collection(collectionName)
module.exports = order_router


order_router.get('/order/:id', function (req, res) {
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
.response(['application/json'], 'Order')
.summary('get order by id')
.description('Get order by id')
.tag('Order')