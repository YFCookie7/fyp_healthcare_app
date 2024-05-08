from flask import Flask, request, jsonify
import time
import json
import datetime
import requests


app = Flask(__name__)


def obtain_data():
    response_data = {"body temp": "99 degree"}
    return response_data


operating = False
app_address = "192.168.1.53"
start_time = None


# App GET sleep data
# @app.route("/get_data", methods=["GET"])
# def handle_request():
#     response_data = obtain_data()
#     return jsonify(response_data)


# App GET pi status
@app.route("/", methods=["GET"])
def handle_request():
    if operating:
        response_data = {"status": "running"}
    else:
        response_data = {"status": "stopped"}
    return jsonify(response_data)


# App POST start/stop signal
# @app.route("/start_stop_pi", methods=["POST"])
# def handle_request():
#     json_content = request.get_json(force=True, silent=True)

#     app_signal = json_content.get("command")
#     if app_signal == "start":
#         start_time = json_content.get("start_time")
#         operating = "running"
#     elif app_signal == "stop":
#         end_time = json_content.get("end_time")
#         operating = "stopped"

#     return f"POST Request received"


# # Pi POST start/stop signal
# def signal_start_end():
#     url = app_address

#     data = {"start_time": start_time, "end_time": datetime.now()}
#     json_data = json.dumps(data)
#     headers = {"Content-Type": "application/json"}
#     response = requests.post(url, data=json_data, headers=headers)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
