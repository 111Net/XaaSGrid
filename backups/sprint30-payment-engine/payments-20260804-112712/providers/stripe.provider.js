
const PaymentProvider =
require("../payment.interface");


class StripeProvider
extends PaymentProvider {


async initializePayment(){

throw new Error(
"stripe integration scheduled for Sprint 30"
);

}


async verifyPayment(){

throw new Error(
"stripe integration scheduled for Sprint 30"
);

}


}


module.exports =
new StripeProvider();

