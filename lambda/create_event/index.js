const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, PutCommand } = require("@aws-sdk/lib-dynamodb");
const { SNSClient, PublishCommand } = require("@aws-sdk/client-sns");

const dynamoClient = new DynamoDBClient({});
const dynamo = DynamoDBDocumentClient.from(dynamoClient);
const sns = new SNSClient({});

exports.handler = async (event) => {
    try {
        const body = JSON.parse(event.body);
        const { title, description } = body;

        if (!title || !description) {
            return { statusCode: 400, body: JSON.stringify({ error: "Title and description required" }) };
        }

        const eventId = Date.now().toString();
        const timestamp = new Date().toISOString();

        // 1. Save event to DynamoDB for history tracking (Step 4)
        await dynamo.send(new PutCommand({
            TableName: process.env.TABLE_NAME,
            Item: {
                eventId: eventId,
                title: title,
                description: description,
                createdAt: timestamp
            }
        }));

        // 2. Broadcast event via SNS to subscribers
        const message = `New Event Announced: ${title}\n\nDescription:\n${description}`;
        const command = new PublishCommand({
            TopicArn: process.env.SNS_TOPIC_ARN,
            Subject: `Event Alert: ${title}`,
            Message: message,
        });

        await sns.send(command);

        return {
            statusCode: 200,
            body: JSON.stringify({ message: "Event published, saved to history, and notifications sent successfully!" }),
        };
    } catch (err) {
        console.error(err);
        return { statusCode: 500, body: JSON.stringify({ error: err.message }) };
    }
};