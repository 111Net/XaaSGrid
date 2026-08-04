
const PaymentProvider =
require("../payment.interface");


class Bank-transferProvider
extends PaymentProvider {


async initializePayment(){

throw new Error(
"bank-transfer integration scheduled for Sprint 30"
);

}


async verifyPayment(){

throw new Error(
"bank-transfer integration scheduled for Sprint 30"
);

}


}


module.exports =
new Bank-transferProvider();

