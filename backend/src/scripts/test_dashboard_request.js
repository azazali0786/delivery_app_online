const http = require('http');

const options = {
    hostname: 'localhost',
    port: 3000,
    path: '/api/debug/delivery-boy/1/dashboard',
    method: 'GET',
};

const req = http.request(options, (res) => {
    let data = '';
    res.on('data', chunk => data += chunk);
    res.on('end', () => {
        console.log('Status:', res.statusCode);
        console.log('Body:', data);
    });
});

req.on('error', (err) => {
    console.error('Request error:', err.message);
});

req.end();