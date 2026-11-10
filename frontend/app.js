const API_URL = "https://0fpzmv9a4h.execute-api.us-east-1.amazonaws.com"; // Replace you api 
// run this cmd = terraform output api_gateway_url 
// this will show the url

// Handle Email Subscription (Called from index.html)
async function handleSubscribe() {
    const emailInput = document.getElementById('sub-email');
    const email = emailInput.value.trim();
    const statusDiv = document.getElementById('status-message');

    if (!email || !email.includes('@')) {
        alert('Please enter a valid email address.');
        return;
    }

    try {
        statusDiv.style.color = '#007bff';
        statusDiv.innerText = 'Subscribing...';

        const response = await fetch(`${API_URL}/subscribe`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ email: email })
        });

        const data = await response.json();

        if (response.ok) {
            statusDiv.style.color = '#28a745';
            statusDiv.innerText = 'Subscription pending! Check your email inbox to confirm.';
            emailInput.value = '';
        } else {
            throw new Error(data.message || 'Failed to subscribe.');
        }
    } catch (error) {
        console.error('Subscription error:', error);
        statusDiv.style.color = '#dc3545';
        statusDiv.innerText = `Error: ${error.message}`;
    }
}

// Handle Publish Event (Called from admin.html)
async function handlePublish() {
    const titleInput = document.getElementById('event-title');
    const descInput = document.getElementById('event-desc');
    const statusDiv = document.getElementById('status-message');

    const title = titleInput.value.trim();
    const description = descInput.value.trim();

    if (!title || !description) {
        alert('Please fill out both the event title and description.');
        return;
    }

    try {
        statusDiv.style.color = '#3498db';
        statusDiv.innerText = 'Broadcasting event to SNS...';

        const response = await fetch(`${API_URL}/events`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ title, description })
        });

        const data = await response.json();

        if (!response.ok) {
            throw new Error(data.message || 'Failed to publish event.');
        }

        statusDiv.style.color = '#27ae60';
        statusDiv.innerText = 'Event published successfully! Notification emails sent.';
        titleInput.value = '';
        descInput.value = '';
    } catch (error) {
        console.error('Publish error:', error);
        statusDiv.style.color = '#c0392b';
        statusDiv.innerText = `Error: ${error.message}`;
    }
}