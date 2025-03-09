import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game/snake_game.dart';
import 'overlays/start_overlay.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snake Game',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const GamePage(),
    );
  }
}

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final gameSize = screenSize.width > screenSize.height 
        ? screenSize.height - kToolbarHeight - 80 // Account for AppBar and footer
        : screenSize.width - 20;
    
    final game = SnakeGame(gameSize: gameSize);
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: ValueListenableBuilder(
                valueListenable: SnakeGame.score,
                builder: (context, value, child) {
                  return Text(
                    'Score: $value',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: ValueListenableBuilder(
                valueListenable: SnakeGame.level,
                builder: (context, value, child) {
                  return Text(
                    'Level: $value',
                    style: const TextStyle(
                      color: Colors.purple,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.palette, color: Colors.green),
            onPressed: () => game.showColorPicker(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.green),
            onPressed: () => game.resetGame(),
          ),
          IconButton(
            icon: const Icon(Icons.pause, color: Colors.green),
            onPressed: () => game.togglePause(),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableHeight = constraints.maxHeight;
            return SingleChildScrollView(  // Tambahkan ScrollView
              child: Column(
                children: [
                  const SizedBox(height: 10),  // Kurangi padding atas
                  // Game Board
                  Container(
                    height: gameSize,
                    width: gameSize,
                    margin: const EdgeInsets.symmetric(vertical: 10),  // Kurangi margin
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green.withOpacity(0.3), width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: GameWidget(
                      game: game,
                      overlayBuilderMap: {
                        'start': (BuildContext context, SnakeGame game) {
                          return StartOverlay(game);
                        },
                      },
                    ),
                  ),
                  // Space between game board and controller
                  const SizedBox(height: 20),  // Fixed spacing
                  // Game Controller
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),  // Kurangi padding
                    margin: const EdgeInsets.only(bottom: 20),  // Tambah margin bottom
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTapDown: (_) => game.changeDirection(0, -1),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.keyboard_arrow_up, size: 28, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTapDown: (_) => game.changeDirection(-1, 0),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.keyboard_arrow_left, size: 28, color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(width: 32),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTapDown: (_) => game.changeDirection(1, 0),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.keyboard_arrow_right, size: 28, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTapDown: (_) => game.changeDirection(0, 1),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.keyboard_arrow_down, size: 28, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildControlHint(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.green, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.green,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}