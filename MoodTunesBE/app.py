import os
import boto3
import uuid
import csv
import base64
from flask import Flask, redirect, request, jsonify
import requests
from requests import post
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


spotify_client_id = os.getenv('SPOTIFY_CLIENT_ID')
spotify_client_secret = os.getenv('SPOTIFY_CLIENT_SECRET')
redirect_uri_1 = "http://192.168.0.84:5001/callback"  

@app.route('/spotify_login')
def spotify_login():
    auth_url = (
        f"https://accounts.spotify.com/authorize"
        f"?client_id={spotify_client_id}&response_type=code"
        f"&redirect_uri={redirect_uri_1}&scope=user-read-email"
    )
    print(auth_url)
    return redirect(auth_url)

redirect_uri_2 = redirect_uri_1

@app.route('/callback')
def callback():
    code = request.args.get('code')
    if not code:
        return jsonify({"error": "No code received from Spotify"}), 400

    # Exchange authorization code for access token
    token_url = "https://accounts.spotify.com/api/token"
    auth_header = base64.b64encode(f"{spotify_client_id}:{spotify_client_secret}".encode()).decode('utf-8')
    headers = {
        "Authorization": f"Basic {auth_header}",
        "Content-Type": "application/x-www-form-urlencoded"
    }
    data = {
        "grant_type": "authorization_code",
        "code": code,
        "redirect_uri": redirect_uri_2
    }

    # Request access token from Spotify
    response = requests.post(token_url, headers=headers, data=data)
    if response.status_code != 200:
        return jsonify({"error": "Failed to retrieve access token"}), 500

    token_info = response.json()
    access_token = token_info.get("access_token")
    print("-----")
    print(access_token)
    # Redirect back to the iOS app with the access token
    return redirect(f"moodtunesfe://callback?token={access_token}")

@app.route('/generate_playlist', methods=['POST'])
def generate_playlist():
    data = request.json
    artists = data['artists']
    emotions = data['emotions']
    access_token = data['accessToken'] 

    # Emotion to genre mapping logic
    top_emotions = sorted(emotions, key=lambda x: -x['Confidence'])[:4] 
    genres = map_emotions_to_genres([emotion['Type'] for emotion in top_emotions])

    # Query Spotify for top songs of the given artists and genres
    songs = []
    for artist_id in artists:
        for genre in genres:
            response = query_spotify_for_songs(artist_id, genre, access_token)
            songs.extend(response.get('tracks', []))

    # Return 12-15 songs
    selected_songs = songs[:15]
    return jsonify({
        'tracks': [
            {'id': song['id'], 'name': song['name'], 'artist': song['artists'][0]['name']}
            for song in selected_songs
        ]
    })

def query_spotify_for_songs(artist_id, genre, access_token):
    url = f"https://api.spotify.com/v1/recommendations"
    
    # Spotify recommendations endpoint allows filtering based on seed artists, genres, etc.
    params = {
        'seed_artists': artist_id,  # Seed the recommendation with the given artist
        'seed_genres': genre,       # Filter by genre
        'limit': 10                 # Number of tracks to return (adjustable)
    }
    
    headers = {
        'Authorization': f'Bearer {access_token}'
    }
    response = requests.get(url, headers=headers, params=params)
    if response.status_code == 200:
        return response.json()
    else:
        print(f"Error querying Spotify API: {response.status_code}, {response.text}")
        return {}

def map_emotions_to_genres(emotions):
    emotion_genre_map = {
        "HAPPY": ["pop", "dance"],
        "SAD": ["acoustic", "blues"],
        "ANGRY": ["rock", "metal"],
        "CALM": ["ambient", "classical"],
    }
    genres = []
    for emotion in emotions:
        genres.extend(emotion_genre_map.get(emotion.upper(), []))
    return genres

if __name__ == '__main__':
    if not os.path.exists('uploads'):
        os.makedirs('uploads')
    app.run(host="0.0.0.0", port=5001)
    
