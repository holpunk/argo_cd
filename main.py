from flask import Flask, jsonify, request

app = Flask(__name__)
items = [
    {"name": "Laptop", "price": 1000},
    {"name": "Mouse", "price": 20},
    {"name": "Keyboard", "price": 50},
    {"name": "test", "price": 100}
]

@app.route('/items', methods=['GET'])
def get_items():
    return jsonify({'items': items})

@app.route('/items', methods=['POST'])
def add_item():
    data = request.get_json()
    items.append(data)
    return jsonify({'message': 'Item added', 'item': data}), 201

if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True)
