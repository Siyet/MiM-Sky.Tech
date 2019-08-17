const { db } = require("@arangodb");
const collectionName = 'helipads'
if (!db._collection(collectionName)) {
    db._createDocumentCollection(collectionName);
}