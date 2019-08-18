'use strict';
const helipad_router = require('./api/helipad')
const helicopter_router = require('./api/helicopter')
const order_router = require('./api/order')
const fz_router = require('./api/forbidden_zone')
module.context.use(helipad_router)
module.context.use(helicopter_router)
module.context.use(order_router)
module.context.use(fz_router)