const { db } = require("@arangodb");

if (!db._collection('helipads')) {
    db._createDocumentCollection('helipads');
}

if (!db._collection('helicopter')) {
    db._createDocumentCollection('helicopter');
}