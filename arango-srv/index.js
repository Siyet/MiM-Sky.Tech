'use strict';
const helipad_router = require('./api/helipad')
const helicopter_router = require('./api/helicopter')
const order_router = require('./api/order')
module.context.use(helipad_router)
module.context.use(helicopter_router)
module.context.use(order_router)