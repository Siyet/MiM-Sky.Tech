'use strict';
const helipad_router = require('./api/helipads')
const helicopter_router = require('./api/helicopter')
module.context.use(helipad_router)
module.context.use(helicopter_router)