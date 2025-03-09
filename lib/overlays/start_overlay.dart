import 'package:flutter/material.dart';
import '../game/snake_game.dart';

class StartOverlay extends StatelessWidget {
  final SnakeGame game;

  StartOverlay(this.game);

  final List<ColorOption> colorOptions = [
    ColorOption('Green', Colors.green[700]!, Colors.green[400]!),
    ColorOption('Blue', Colors.blue[700]!, Colors.blue[400]!),
    ColorOption('Purple', Colors.purple[700]!, Colors.purple[400]!),
    ColorOption('Orange', Colors.orange[700]!, Colors.orange[400]!),
    ColorOption('Red', Colors.red[700]!, Colors.red[400]!),
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Snake Game',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Choose Snake Color:',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: colorOptions.map((option) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      game.setSnakeColor(option.baseColor, option.accentColor);
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [option.baseColor, option.accentColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => game.startGame(),
              child: const Text('Start Game'),
            ),
          ],
        ),
      ),
    );
  }
}

class ColorOption {
  final String name;
  final Color baseColor;
  final Color accentColor;

  ColorOption(this.name, this.baseColor, this.accentColor);
}