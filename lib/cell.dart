import 'package:flutter/material.dart';

class Cell extends StatefulWidget {
  final Border _border;
  final int index;
  final String symbol;
  final Function onMove;
  Cell(this._border, this.index, this.symbol, this.onMove);
  @override
  CellState createState() => CellState();
}

class CellState extends State<Cell> {
  handleTap() {
    widget.onMove(widget.index);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: handleTap,
        child: Container(
            height: 100,
            width: 100,
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(border: widget._border),
            child: Center(
              child: Container(
                  child: Text(widget.symbol,
                      style: TextStyle(
                          fontSize: 50, color: Theme.of(context).accentColor))),
            )));
  }
}
