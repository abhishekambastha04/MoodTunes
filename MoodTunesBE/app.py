import os
import boto3
from flask import Flask, request, jsonify
from flask_cors import CORS
from dotenv import load_dotenv

app = Flask(__name__)
CORS(app)

cognito_client = boto3.client('cognito-idp', region_name='us-east-1')
load_dotenv()

COGNITO_USER_POOL_ID = os.getenv('COGNITO_USER_POOL_ID')
COGNITO_APP_CLIENT_ID = os.getenv('COGNITO_APP_CLIENT_ID')

@app.route('/')
def hello():
    return "Hello, World!"

@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    
    email = data['email']
    password = data['password']
    
    try:
        response = cognito_client.initiate_auth(
            ClientId=COGNITO_APP_CLIENT_ID,
            AuthFlow='USER_PASSWORD_AUTH',
            AuthParameters={
                'USERNAME': email,
                'PASSWORD': password
            }
        )
        return jsonify({
            "message": "Login successful",
            "tokens": response['AuthenticationResult']
        }), 200
    except Exception as e:
        return jsonify({"message": "Login not successful", "error": str(e)}), 400


@app.route('/signup', methods=['POST'])
def signup():
    data = request.get_json()
    email = data['email']
    password = data['password']
    
    try:
        response = cognito_client.sign_up(
            ClientId=COGNITO_APP_CLIENT_ID,
            Username=email,
            Password=password,
            UserAttributes=[
                {
                    'Name': 'email',
                    'Value': email
                },
            ]
        )
        return jsonify({"message": "User signed up successfully, check your email for verification."}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 400
    
@app.route('/confirm-signup', methods=['POST'])
def confirm_signup():
    data = request.get_json()
    email = data['email']
    confirmation_code = data['confirmation_code']
    
    try:
        response = cognito_client.confirm_sign_up(
            ClientId=COGNITO_APP_CLIENT_ID,
            Username=email,
            ConfirmationCode=confirmation_code
        )
        return jsonify({"message": "User email confirmed successfully."}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 400

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5001)
    
