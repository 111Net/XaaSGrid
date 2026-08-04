
const PaymentProvider =
require("../payment.interface");


class FlutterwaveProvider
extends PaymentProvider {


async initializePayment(){

throw new Error(
"flutterwave integration scheduled for Sprint 30"
);

}


async verifyPayment(){

throw new Error(
"flutterwave integration scheduled for Sprint 30"
);

}


}


module.exports =
new FlutterwaveProvider();

