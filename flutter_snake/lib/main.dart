// ignore_for_file: prefer_final_fields, no_leading_underscores_for_local_identifiers

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(
    const FlutterSnakeApp(),
  );
}

class FlutterSnakeApp extends StatefulWidget {
  const FlutterSnakeApp({super.key});

  @override
  State<FlutterSnakeApp> createState() => _FlutterSnakeAppState();
}

class _FlutterSnakeAppState extends State<FlutterSnakeApp> {
  int score = 0;
  bool isGameOver = false;

  @override
  Widget build(BuildContext context) {
    if (isGameOver) {
      return MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Score: $score',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                const Text(
                  'GAME OVER!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            Text(
              'Score: $score',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
            Center(
              child: GameBoard(
                onScoreChanged: (score) {
                  setState(() {
                    this.score = score;
                  });
                },
                onGameOver: (isGameOver) => setState(() {
                  if (!isGameOver) return;

                  this.isGameOver = isGameOver;
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 3. an apple

const kGameboardSize =
    10; // size of the game board MxM where M = kGameboardSize

class GameBoard extends StatefulWidget {
  const GameBoard({
    super.key,
    this.onScoreChanged,
    this.onGameOver,
  });

  final void Function(int score)? onScoreChanged;
  final void Function(bool isGameOver)? onGameOver;

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  /* ------------------------------- game logic ------------------------------- */
  final FocusNode _focusNode = FocusNode();

  List<BoardCellType> _board = List.filled(
    kGameboardSize * kGameboardSize,
    BoardCellType.empty,
  );

  int playerPosition = 54;
  PlayerDirection playerDirection = PlayerDirection.up;

  int applePosition = 34;
  bool appleIsSpawned = true;

  List<int> bombPositions = [];

  int score = 0;

  @override
  void initState() {
    super.initState();

    // FocusScope.of(context).requestFocus(_focusNode);

    //starting position of the snake
    _board[playerPosition] = BoardCellType.player;
    _board[applePosition] = BoardCellType.apple;

    //make the player move every 1 second
    Timer.periodic(const Duration(milliseconds: 750), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      switch (playerDirection) {
        case PlayerDirection.up:
          _movePlayer(playerPosition - kGameboardSize);
          break;
        case PlayerDirection.down:
          _movePlayer(playerPosition + kGameboardSize);
          break;
        case PlayerDirection.left:
          _movePlayer(playerPosition - 1);
          break;
        case PlayerDirection.right:
          _movePlayer(playerPosition + 1);
          break;
      }
    });

    Timer.periodic(const Duration(milliseconds: 20), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_hasAppleBeenEaten()) {
        _scoreChanged();
      }

      _isGameOver();
    });

    //Randomly generate an apple
    Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (appleIsSpawned) return;

      int randomPosition = Random().nextInt(kGameboardSize * kGameboardSize);
      while (_board[randomPosition] != BoardCellType.empty) {
        randomPosition = Random().nextInt(kGameboardSize * kGameboardSize);
      }
      setState(() {
        appleIsSpawned = true;
        applePosition = randomPosition;
        _board[randomPosition] = BoardCellType.apple;
      });
    });

    //Randomly generate a bomb
    Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (bombPositions.length > 50) return;

      int randomPosition = Random().nextInt(kGameboardSize * kGameboardSize);
      while (_board[randomPosition] != BoardCellType.empty) {
        randomPosition = Random().nextInt(kGameboardSize * kGameboardSize);
      }
      setState(() {
        bombPositions.add(randomPosition);
        _board[randomPosition] = BoardCellType.bomb;
      });
    });

    Timer.periodic(const Duration(milliseconds: 3000), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (bombPositions.isEmpty) return;

      setState(() {
        final removedPosition = bombPositions.first;
        bombPositions.removeAt(0);
        _board[removedPosition] = BoardCellType.empty;
      });
    });
  }

  // gives the 2D position of a 1D position
  (int, int) _mapTo2D(int position) {
    return (position % kGameboardSize, position ~/ kGameboardSize);
  }

  int _mapTo1D(int x, int y) {
    return y * kGameboardSize + x;
  }

  bool _hasAppleBeenEaten() {
    if (playerPosition == applePosition) {
      appleIsSpawned = false;
      return true;
    }

    return false;
  }

  bool _isGameOver() {
    for (int bombPosition in bombPositions) {
      if (playerPosition == bombPosition) {
        widget.onGameOver?.call(true);
        return true;
      }
    }
    widget.onGameOver?.call(false);
    return false;
  }

  void _scoreChanged() {
    score++;
    widget.onScoreChanged?.call(score);
  }

  void _movePlayer(int newPosition) {
    int playerX = _mapTo2D(playerPosition).$1;
    int playerY = _mapTo2D(playerPosition).$2;

    int newX = _mapTo2D(newPosition).$1;
    int newY = _mapTo2D(newPosition).$2;

    //when on left edge of the board
    if (newX == (kGameboardSize - 1) && playerX == 0) {
      int _newPosition = _mapTo1D(kGameboardSize - 1, playerY);

      setState(() {
        _board[playerPosition] = BoardCellType.empty;
        playerPosition = _newPosition;
        _board[_newPosition] = BoardCellType.player;
      });
      //when on right edge of the board
    } else if (newX == 0 && playerX == (kGameboardSize - 1)) {
      int _newPosition = _mapTo1D(0, playerY);
      setState(() {
        _board[playerPosition] = BoardCellType.empty;
        playerPosition = _newPosition;
        _board[_newPosition] = BoardCellType.player;
      });
      //when on top edge of the board
    } else if (playerY == 0 && newY <= 0) {
      int _newPosition = _mapTo1D(playerX, kGameboardSize - 1);
      setState(() {
        _board[playerPosition] = BoardCellType.empty;
        playerPosition = _newPosition;
        _board[_newPosition] = BoardCellType.player;
      });
//when on bottom edge of the board
    } else if (playerY == kGameboardSize - 1 && newY > kGameboardSize - 1) {
      int _newPosition = _mapTo1D(playerX, 0);
      setState(() {
        _board[playerPosition] = BoardCellType.empty;
        playerPosition = _newPosition;
        _board[_newPosition] = BoardCellType.player;
      });
    } else {
      setState(() {
        _board[playerPosition] = BoardCellType.empty;
        playerPosition = newPosition;
        _board[playerPosition] = BoardCellType.player;
      });
    }
  }
/* ------------------------------- game logic ------------------------------- */

  Widget _buildCell(int index) {
    return switch (_board[index]) {
      BoardCellType.empty => Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey,
            ),
            color: Colors.grey.shade200,
          ),
        ),
      BoardCellType.player => const Player(),
      BoardCellType.apple => const Apple(),
      BoardCellType.bomb => const Bomb(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      autofocus: true,
      focusNode: _focusNode,
      onKeyEvent: (event) {
        if (event is! KeyUpEvent) return;

        //do this in a switch case
        switch (event.logicalKey) {
          case LogicalKeyboardKey.arrowUp:
            playerDirection = PlayerDirection.up;
            _movePlayer(playerPosition - kGameboardSize);
          case LogicalKeyboardKey.arrowDown:
            playerDirection = PlayerDirection.down;
            _movePlayer(playerPosition + kGameboardSize);
          case LogicalKeyboardKey.arrowLeft:
            playerDirection = PlayerDirection.left;
            _movePlayer(playerPosition - 1);
          case LogicalKeyboardKey.arrowRight:
            playerDirection = PlayerDirection.right;
            _movePlayer(playerPosition + 1);
        }
      },
      child: SizedBox(
        width: 500,
        height: 500,
        child: GridView.builder(
          itemCount: kGameboardSize * kGameboardSize,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: kGameboardSize,
          ),
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return _buildCell(index);
          },
        ),
      ),
    );
  }
}

enum BoardCellType {
  empty,
  player,
  apple,
  bomb,
}

enum PlayerDirection {
  up,
  down,
  left,
  right,
}

class Player extends StatelessWidget {
  const Player({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
        ),
        color: Colors.grey.shade50,
      ),
      child: const FittedBox(
        fit: BoxFit.fill,
        alignment: Alignment.center,
        child: Text(
          '🐍',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class Apple extends StatelessWidget {
  const Apple({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
        ),
        color: Colors.grey.shade50,
      ),
      child: const FittedBox(
        fit: BoxFit.fill,
        alignment: Alignment.center,
        child: Text(
          '🍎',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}

class Bomb extends StatelessWidget {
  const Bomb({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
        ),
        color: Colors.grey.shade50,
      ),
      child: const FittedBox(
        fit: BoxFit.fill,
        alignment: Alignment.center,
        child: Text(
          '💣',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
