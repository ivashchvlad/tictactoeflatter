import 'package:flutter/material.dart';
import 'package:my_app/cell.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class TicTacToe extends StatefulWidget {
  @override
  _TicTacToeState createState() => _TicTacToeState();
}

class _TicTacToeState extends State<TicTacToe> {
  IO.Socket socket;
  List<String> board;
  String currentSymbol = 'X';
  int movesCount = 0;
  bool myTurn = false;
  String turnMessage = 'Waiting for an opponent...';
  @override
  void initState() {
    super.initState();
    socket = IO.io('http://localhost:8080', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket.connect();
    board = List.generate(9, (index) => '');
  }

  String checkWinner() {
    var winner = '';
    //check rows
    for (var i = 0; i <= 6; i += 3) {
      if (board[i] != '' &&
          board[i] == board[i + 1] &&
          board[i] == board[i + 2]) winner = board[i];
    }
    //check columns
    for (var i = 0; i < 3; i += 1) {
      if (board[i] != '' &&
          board[i] == board[i + 3] &&
          board[i] == board[i + 6]) winner = board[i];
    }
    //check diagonals
    if (board[0] != '' && board[0] == board[4] && board[0] == board[8])
      winner = board[0];
    if (board[2] != '' && board[2] == board[4] && board[2] == board[6])
      winner = board[2];
    return winner;
  }

  showEndDialog(title) {
    setState(() {
      turnMessage = title;
      myTurn = false;
    });
  }

  showTurnMessage() {
    setState(() {
      turnMessage = (myTurn) ? 'Your turn' : 'Your apponent turn';
    });
  }

  onMove(index) {
    if (!myTurn) return;
    if (board[index] != '') return;
    setState(() {
      //If cell is busy you can't make a move
      movesCount++;
    });
    socket.emit("make.move", {
      // Valid move (on client side) -> emit to server
      'symbol': currentSymbol,
      'position': index,
    });
    //if 5 moves is done there can be a winner
    if (movesCount >= 3) {
      var winner = checkWinner();
      var title;
      if (winner != '') {
        title = '$winner wins!';
        showEndDialog(title);
      } else if (movesCount >= 9) {
        title = 'Draw!';
        showEndDialog(title);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    socket.on("connect", (data) => print("connected"));
    socket.on("move.made", (data) {
      setState(() {
        print(data);
        if (data['position'] is int)
          board[data['position']] = data['symbol'];
        else
          board[int.parse(data['position'])] = data['symbol'];
        myTurn = (data['symbol'] != currentSymbol);
      });
      if (checkWinner() == '') // If game isn't over show who's turn is this
        showTurnMessage();
      else if (myTurn) {
        showEndDialog("You lost.");
      } else
        showEndDialog("You won!");
    });

    socket.on("game.begin", (data) {
      setState(() {
        currentSymbol = data['symbol']; // The server is assigning the symbol
        myTurn = currentSymbol == "X"; // 'X' starts first
      });
      showTurnMessage();
    });

    // Bind on event for opponent leaving the game
    socket.on("opponent.left",
        (data) => showEndDialog("Your opponent left the game."));

    final BorderSide _borderSide =
        BorderSide(width: 2.0, color: Theme.of(context).accentColor);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
              margin: EdgeInsets.only(bottom: 50.0),
              child: Text(
                turnMessage,
                style: TextStyle(fontSize: 18),
              )),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Cell(
                Border(
                  bottom: _borderSide,
                  right: _borderSide,
                ),
                0,
                board[0],
                onMove,
              ),
              Cell(
                Border(
                  bottom: _borderSide,
                  right: _borderSide,
                ),
                1,
                board[1],
                onMove,
              ),
              Cell(
                Border(bottom: _borderSide),
                2,
                board[2],
                onMove,
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Cell(
                Border(
                  bottom: _borderSide,
                  right: _borderSide,
                ),
                3,
                board[3],
                onMove,
              ),
              Cell(
                Border(
                  bottom: _borderSide,
                  right: _borderSide,
                ),
                4,
                board[4],
                onMove,
              ),
              Cell(
                Border(bottom: _borderSide),
                5,
                board[5],
                onMove,
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Cell(
                Border(
                  right: _borderSide,
                ),
                6,
                board[6],
                onMove,
              ),
              Cell(
                Border(
                  right: _borderSide,
                ),
                7,
                board[7],
                onMove,
              ),
              Cell(
                Border(),
                8,
                board[8],
                onMove,
              )
            ],
          ),
        ],
      ),
    );
  }
}
