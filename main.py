from flask import Flask, jsonify, request
from prometheus_flask_exporter import PrometheusMetrics
from prometheus_client import generate_latest, CONTENT_TYPE_LATEST

app = Flask(__name__)
metrics = PrometheusMetrics(app)

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



@app.route('/metrics')
def metrics_endpoint():
    data = generate_latest(metrics.registry)
    return data, 200, {'Content-Type': CONTENT_TYPE_LATEST}

if __name__ == '__main__':
    print(f"Registered Routes: {app.url_map}", flush=True)
    app.run(host='0.0.0.0', debug=True)
