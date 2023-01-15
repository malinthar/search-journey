import ballerina/http;
import ballerinax/mongodb;

configurable string password = ?;
configurable string database = ?;
configurable string username = ?;

mongodb:ConnectionConfig mongoConfig = {
    connection: {
        host: "localhost",
        auth: {
            username: username,
            password: password
        },
        options: {
            sslEnabled: false,
            serverSelectionTimeout: 15000
        }
    },
    databaseName: database
};

mongodb:Client mongo = check new (mongoConfig);

type Joureny record {
    string 'start;
    string end;
    decimal cost;
    int days;
    int numOfPeople;
};

service /journeys on new http:Listener(9090) {
    resource function get .() returns Joureny[]|error {
        stream<Joureny, error?> journeys = check mongo->find("journeys", database);
        return from Joureny j in journeys
            limit 1
            select j;
    }
}
