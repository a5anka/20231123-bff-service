import ballerina/log;
import ballerina/http;

configurable string loyaltyEndpointUrl = ?;
configurable string vendorEndpointUrl = ?;

configurable string tokenUrl = ?;
configurable string clientId = ?;
configurable string clientSecret = ?;

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    isolated resource function post pick(RewardSelection rewardSelection) returns string|error {

        log:printInfo("Reward Selection", selection = rewardSelection);

        User user = check loyaltyEndpoint->/user/[rewardSelection.userId];

        log:printInfo("User", user = user);

        VendorRequest vendorRequest = transform(user, rewardSelection);

        log:printInfo("Vendor Request", vendorRequest = vendorRequest);

        http:Response _ = check vendorEndpoint->/rewards.post(vendorRequest);

        return "Success";
    }
}

type User record {
    string email;
    string firstName;
    string lastName;
    string userId;
};

type VendorRequest record {
    string rewardId;
    string userId;
    string firstName;
    string lastName;
    string email;
};

type RewardSelection record {
    string userId;
    string rewardId;
};

final http:Client loyaltyEndpoint = check new (url = loyaltyEndpointUrl, config = {
    auth: {
        tokenUrl: tokenUrl,
        clientId: clientId,
        clientSecret: clientSecret
    }
});

final http:Client vendorEndpoint = check new (url = vendorEndpointUrl, config = {
    auth: {
        tokenUrl: tokenUrl,
        clientId: clientId,
        clientSecret: clientSecret
    }
});

isolated function transform(User user, RewardSelection rewardSelection) returns VendorRequest => {
    email: user.email,
    firstName: user.firstName,
    lastName: user.lastName,
    userId: rewardSelection.userId,
    rewardId: rewardSelection.rewardId
};
