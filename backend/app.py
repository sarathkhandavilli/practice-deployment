from flask import Flask, jsonify, request
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# In-memory data storage
users = []
user_id = 1

@app.route('/users', methods=['GET'])
def get_users():
    return jsonify(users), 200

@app.route('/users', methods=['POST'])
def add_user():
    global user_id
    data = request.get_json()
    data['id'] = user_id
    users.append(data)
    user_id += 1
    return jsonify(data), 201

@app.route('/users/<int:id>', methods=['PUT'])
def update_user(id):
    data = request.get_json()
    for user in users:
        if user['id'] == id:
            user.update(data)
            return jsonify(user), 200
    return jsonify({'message': 'User not found'}), 404

@app.route('/users/<int:id>', methods=['DELETE'])
def delete_user(id):
    global users
    users = [user for user in users if user['id'] != id]
    return jsonify({'message': 'User deleted'}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
