
const PaymentProvider =
require("../payment.interface");


class PaystackProvider
extends PaymentProvider {


async initializePayment(){

throw new Error(
"paystack integration scheduled for Sprint 30"
);

}


async verifyPayment(){

throw new Error(
"paystack integration scheduled for Sprint 30"
);

}


}


module.exports =
new PaystackProvider();

