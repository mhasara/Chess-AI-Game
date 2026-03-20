import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_chess_board/flutter_chess_board.dart';

void main() {
  runApp(ChessApp());
}

class ChessApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChessPage(),
    );
  }
}

class ChessPage extends StatefulWidget {
  @override
  _ChessPageState createState() => _ChessPageState();
}

class _ChessPageState extends State<ChessPage> {
  ChessBoardController controller = ChessBoardController();

  bool isLoading = false;

  Future<String> getAIMove(String fen) async {
    final response = await http.post(
      Uri.parse("http://10.0.2.2:5000/move"), // Android emulator localhost
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"fen": fen}),
    );

    final data = jsonDecode(response.body);
    return data["move"];
  }

  void onMove() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    String fen = controller.getFen();

    try {
      String aiMove = await getAIMove(fen);

      controller.makeMove(
        from: aiMove.substring(0, 2),
        to: aiMove.substring(2, 4),
      );
    } catch (e) {
      print("Error: $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AI Chess App"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ChessBoard(
              controller: controller,
              boardColor: BoardColor.brown,
              onMove: () {
                onMove(); // trigger AI after player move
              },
            ),
          ),
          if (isLoading)
            Padding(
              padding: EdgeInsets.all(10),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}