from flask import Flask, request, jsonify
import chess
import chess.engine

app = Flask(__name__)

engine = chess.engine.SimpleEngine.popen_uci("stockfish.exe")

@app.route("/move", methods=["POST"])
def get_move():
    data = request.json
    board = chess.Board(data["fen"])

    result = engine.play(board, chess.engine.Limit(time=0.2))

    return jsonify({"move": str(result.move)})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)