
const PaymentProvider =
require("../payment.interface");


class Mobile-moneyProvider
extends PaymentProvider {


async initializePayment(){

throw new Error(
"mobile-money integration scheduled for Sprint 30"
);

}


async verifyPayment(){

throw new Error(
"mobile-money integration scheduled for Sprint 30"
);

}


}


module.exports =
new Mobile-moneyProvider();

