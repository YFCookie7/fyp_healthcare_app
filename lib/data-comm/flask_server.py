from flask import Flask, request, jsonify

app = Flask(__name__)


@app.route("/", methods=["GET", "POST"])
def handle_request():
    if request.method == "GET":
        response_data = {"body temp": "99 degree"}
        return jsonify(response_data)
    elif request.method == "POST":
        json_content = request.get_json(force=True, silent=True)
        print(json_content)
        return f"POST Request received"


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
