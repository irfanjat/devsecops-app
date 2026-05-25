from flask import Flask, jsonify, request
import os
import hashlib

app = Flask(__name__)

APP_VERSION = os.getenv("APP_VERSION", "2.0.0")

@app.route('/')
def home():
    return jsonify({
        "message": "Hello from DevSecOps pipeline!",
        "version": APP_VERSION,
        "status": "running"
    })

@app.route('/health')
def health():
    return jsonify({"status": "healthy"}), 200

@app.route('/secure')
def secure():
    auth = request.headers.get("Authorization", "")
    if not auth.startswith("Bearer "):
        return jsonify({"error": "unauthorized"}), 401
    return jsonify({"message": "secure endpoint", "version": APP_VERSION})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
