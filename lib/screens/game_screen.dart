import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // Add this import
import '../game/snake_game.dart';
import 'package:flame/game.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Set static game size
    const gameSize = 320.0; // Fixed size for game board
    
    final game = SnakeGame(gameSize: gameSize);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ValueListenableBuilder(
              valueListenable: SnakeGame.level,
              builder: (context, level, child) {
                return Text('Level: $level');
              },
            ),
            ValueListenableBuilder(
              valueListenable: SnakeGame.score,
              builder: (context, score, child) {
                return Text('Score: $score');
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => game.resetGame(),
          ),
          IconButton(
            icon: const Icon(Icons.pause),
            onPressed: () => game.togglePause(),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableHeight = constraints.maxHeight;
            final topBottomPadding = (availableHeight - gameSize - 60) / 2;
            
            return Column(
              children: [
                SizedBox(height: topBottomPadding),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: gameSize,
                    height: gameSize,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green.withOpacity(0.3), width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: GameWidget(
                      game: game,
                      initialActiveOverlays: const ['start'],
                      overlayBuilderMap: {
                      'start': (BuildContext context, SnakeGame game) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Snake Game',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  game.overlays.remove('start');
                                  game.startGame();
                                },
                                child: const Text('Start Game'),
                              ),
                            ],
                          ),
                        );
                      },
                    },
                  ),
                ),
                SizedBox(height: topBottomPadding),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      // Up button
                      IconButton(
                        iconSize: 40,
                        icon: const Icon(Icons.keyboard_arrow_up, color: Colors.green),
                        onPressed: () => game.direction = Vector2(0, -1),
                      ),
                      // Middle row with Left, Right buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            iconSize: 40,
                            icon: const Icon(Icons.keyboard_arrow_left, color: Colors.green),
                            onPressed: () => game.direction = Vector2(-1, 0),
                          ),
                          const SizedBox(width: 60), // Space between left and right
                          IconButton(
                            iconSize: 40,
                            icon: const Icon(Icons.keyboard_arrow_right, color: Colors.green),
                            onPressed: () => game.direction = Vector2(1, 0),
                          ),
                        ],
                      ),
                      // Down button
                      IconButton(
                        iconSize: 40,
                        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.green),
                        onPressed: () => game.direction = Vector2(0, 1),
                      ),
                    ],
                  ),
                ),
                // Remove the old control hints
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  color: Colors.black,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildControlHint(Icons.arrow_upward, 'Up'),
                      _buildControlHint(Icons.arrow_downward, 'Down'),
                      _buildControlHint(Icons.arrow_left, 'Left'),
                      _buildControlHint(Icons.arrow_right, 'Right'),
                    ],
                  ),
                ),
                const Spacer(),
                // Game Controller
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () => game.direction = Vector2(0, -1),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.withOpacity(0.3),
                          padding: const EdgeInsets.all(12),
                        ),
                        child: const Icon(Icons.keyboard_arrow_up, size: 32, color: Colors.green),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () => game.direction = Vector2(-1, 0),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.withOpacity(0.3),
                              padding: const EdgeInsets.all(12),
                            ),
                            child: const Icon(Icons.keyboard_arrow_left, size: 32, color: Colors.green),
                          ),
                          const SizedBox(width: 48),
                          ElevatedButton(
                            onPressed: () => game.direction = Vector2(1, 0),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.withOpacity(0.3),
                              padding: const EdgeInsets.all(12),
                            ),
                            child: const Icon(Icons.keyboard_arrow_right, size: 32, color: Colors.green),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () => game.direction = Vector2(0, 1),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.withOpacity(0.3),
                          padding: const EdgeInsets.all(12),
                        ),
                        child: const Icon(Icons.keyboard_arrow_down, size: 32, color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
