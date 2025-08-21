#!/usr/bin/env node

/**
 * Health check script for the Djinn application
 * This script performs basic health checks and exits with appropriate codes
 */

const http = require('http');

const PORT = process.env.PORT || 8080;
const HEALTH_PATH = '/health';
const TIMEOUT = 3000;

function healthCheck() {
  return new Promise((resolve, reject) => {
    const req = http.request({
      hostname: 'localhost',
      port: PORT,
      path: HEALTH_PATH,
      method: 'GET',
      timeout: TIMEOUT
    }, (res) => {
      if (res.statusCode === 200) {
        resolve('Health check passed');
      } else {
        reject(new Error(`Health check failed with status: ${res.statusCode}`));
      }
    });

    req.on('error', (err) => {
      reject(new Error(`Health check request failed: ${err.message}`));
    });

    req.on('timeout', () => {
      req.destroy();
      reject(new Error('Health check timed out'));
    });

    req.end();
  });
}

// Perform the health check
healthCheck()
  .then((message) => {
    console.log(message);
    process.exit(0);
  })
  .catch((error) => {
    console.error(error.message);
    process.exit(1);
  });