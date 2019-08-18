const { db } = require("@arangodb");

if (!db._collection('helipads')) {
    db._createDocumentCollection('helipads');
}

if (!db._collection('helicopter')) {
    db._createDocumentCollection('helicopter');
}

if (!db._collection('forbidden_zone')) {
    db._createDocumentCollection('forbidden_zone');
}

if (!db._collection('order')) {
    db._createDocumentCollection('order');
}

if (!db._collection('route')) {
    db._createDocumentCollection('route');
}