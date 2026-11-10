const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, PutCommand } = require("@aws-sdk/lib-dynamodb");
const { SNSClient, SubscribeCommand } = require("@aws-sdk/client-sns");

const dynamoClient = new DynamoDBClient({});
const dynamo = DynamoDBDocumentClient.from(dynamoClient);
const sns = new SNSClient({});

exports.handler = async (event) => {
    try {
        const body = JSON.parse(event.body);
        const email = body.email;

        if (!email) {
            return { statusCode: 400, body: JSON.stringify({ error: "Email is required" }) };
        }

        // 1. Save subscriber into DynamoDB table
        await dynamo.send(new PutCommand({
            TableName: process.env.SUBSCRIBERS_TABLE,
            Item: {
                email: email,
                status: "PENDING",
                subscribedAt: new Date().toISOString()
            }
        }));

        // 2. Trigger AWS SNS confirmation email
        const command = new SubscribeCommand({
            TopicArn: process.env.SNS_TOPIC_ARN,
            Protocol: "email",
            Endpoint: email,
        });

        await sns.send(command);

        return {
            statusCode: 200,
            body: JSON.stringify({ message: "Subscription pending. Check your email to confirm." }),
        };
    } catch (err) {
        console.error(err);
        return { statusCode: 500, body: JSON.stringify({ error: err.message }) };
    }
};