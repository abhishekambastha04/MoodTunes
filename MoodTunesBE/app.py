import os
import boto3
import uuid
import csv
from flask import Flask, request, jsonify
from flask_cors import CORS
from werkzeug.utils import secure_filename
from dotenv import load_dotenv

app = Flask(__name__)
CORS(app)

with open('rekognition_access_accessKeys.csv', 'r') as file:
    next(file)
    reader = csv.reader(file)
    for row in reader:
        access_key_id = row[0]
        secret_access_key = row[1]


rekognition_client = boto3.client('rekognition', region_name='us-west-2',
                        aws_access_key_id=access_key_id, aws_secret_access_key=secret_access_key)

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
    
@app.route('/upload', methods=['POST'])
def upload_image():
    if 'image' not in request.files:
        return jsonify({'error': 'No image found in the request'}), 400

    image = request.files['image']
    
    # Generate a unique filename to avoid overwriting
    unique_filename = f"{uuid.uuid4()}.{image.filename.rsplit('.', 1)[1].lower()}"
    unique_filename = secure_filename(unique_filename)
    print(unique_filename)
    image_path = os.path.join('uploads', unique_filename)
    image.save(image_path)
    emotions = analyze_emotions(image_path)
    print(emotions)

    return jsonify({'message': 'Image successfully uploaded', 'file_path': image_path, 'emotions': emotions}), 200

def analyze_emotions(image_path):
    with open(image_path, 'rb') as image_file:
        image_bytes = image_file.read()

    # Call AWS Rekognition to detect facial emotions
    response = rekognition_client.detect_faces(
        Image={'Bytes': image_bytes},
        Attributes=['ALL']  
    )
    emotions = []
    for faceDetail in response['FaceDetails']:
        for emotion in faceDetail['Emotions']:
            emotions.append({
                'Type': emotion['Type'],
                'Confidence': emotion['Confidence']
            })

    return emotions


if __name__ == '__main__':
    if not os.path.exists('uploads'):
        os.makedirs('uploads')
    app.run(host="0.0.0.0", port=5001)
    
