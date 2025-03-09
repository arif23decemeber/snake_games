import 'dart:async' as async;
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Add this enum at the top of the file, after the imports
enum FoodType {
  regular, // Red - regular food
  shrink, // Blue - reduces snake length
  slowDown, // Yellow - decreases speed
  speedUp, // Purple - increases speed
}

class SnakeGame extends FlameGame with KeyboardEvents {
  static const int gridSize = 20;
  final double gameSize;
  late final double tileSize;
  static const double speed = 5.0; // Keep this one

  SnakeGame({required this.gameSize}) {
    tileSize = gameSize / gridSize;
  }

  // Remove this duplicate declaration
  // static const double speed = 5.0;  // <- Remove this line

  // Remove this line as we already have tileSize defined above
  // static const double tileSize = 20.0;  // <- Remove this line

  // Add snake color properties
  Color snakeBaseColor = Colors.green[700]!;
  Color snakeAccentColor = Colors.green[400]!;

  // Add method to change snake color
  void setSnakeColor(Color baseColor, Color accentColor) {
    snakeBaseColor = baseColor;
    snakeAccentColor = accentColor;
  }

  // Adjust speed values
  bool isGameOver = false;
  double baseSpeed = 0.15; // Faster base speed (was 0.25)
  double currentSpeed = 0.15; // Initial speed same as base speed
  double elapsedTime = 0;

  static ValueNotifier<int> level = ValueNotifier<int>(1);
  static ValueNotifier<int> score = ValueNotifier<int>(0);

  Vector2 direction = Vector2(1, 0);
  List<Vector2> snakeBody = [Vector2(10, 10)];
  bool isPlaying = false;

  // Add these new properties
  Vector2 regularFoodPosition = Vector2(5, 5);
  Map<FoodType, Vector2?> specialFoods = {
    FoodType.shrink: null,
    FoodType.slowDown: null,
    FoodType.speedUp: null,
  };
  Map<FoodType, bool> specialFoodVisible = {
    FoodType.shrink: false,
    FoodType.slowDown: false,
    FoodType.speedUp: false,
  };
  final Random random = Random();
  double specialFoodTimer = 0;

  // Replace the existing spawnFood method
  void spawnFood() {
    regularFoodPosition = Vector2(
      random.nextInt(gridSize).toDouble(),
      random.nextInt(gridSize).toDouble(),
    );
  }

  // Add this new method
  void handleSpecialFoods(double dt) {
    specialFoodTimer += dt;

    if (specialFoodTimer >= 3.0) {
      // Every 3 seconds
      specialFoodTimer = 0;

      // For each special food type
      specialFoods.forEach((type, position) {
        if (random.nextBool()) {
          // 50% chance to toggle visibility
          if (!specialFoodVisible[type]!) {
            // Spawn new special food
            specialFoods[type] = Vector2(
              random.nextInt(gridSize).toDouble(),
              random.nextInt(gridSize).toDouble(),
            );
            specialFoodVisible[type] = true;
          } else {
            // Hide special food
            specialFoodVisible[type] = false;
          }
        }
      });
    }
  }

  // Modify the moveSnake method
  void moveSnake() {
    Vector2 newHead = snakeBody.first + direction;

    // Wrap around screen edges instead of game over
    if (newHead.x < 0) {
      newHead.x = gridSize - 1;
    } else if (newHead.x >= gridSize) {
      newHead.x = 0;
    }
    if (newHead.y < 0) {
      newHead.y = gridSize - 1;
    } else if (newHead.y >= gridSize) {
      newHead.y = 0;
    }

    // Check self collision before adding new head
    for (int i = 0; i < snakeBody.length; i++) {
      if (newHead.x == snakeBody[i].x && newHead.y == snakeBody[i].y) {
        gameOver();
        return;
      }
    }

    snakeBody.insert(0, newHead);

    bool foodEaten = false;

    // Check regular food collision
    if (newHead.x == regularFoodPosition.x &&
        newHead.y == regularFoodPosition.y) {
      score.value += 10;
      foodEaten = true;
      spawnFood();

      // Level up every 5 regular foods (50 points)
      if (score.value > 0 && score.value % 50 == 0) {
        level.value++;
      }
    }

    // Check special food collisions
    specialFoods.forEach((type, position) {
      if (position != null &&
          specialFoodVisible[type]! &&
          newHead.x == position.x &&
          newHead.y == position.y) {
        foodEaten = true;
        specialFoodVisible[type] = false;

        switch (type) {
          case FoodType.shrink:
            if (snakeBody.length > 3) {
              snakeBody.removeLast();
              snakeBody.removeLast();
            }
            break;
          case FoodType.slowDown:
            currentSpeed = baseSpeed * 1.3;
            Future.delayed(const Duration(seconds: 5), () {
              currentSpeed = baseSpeed;
            });
            break;
          case FoodType.speedUp:
            currentSpeed = baseSpeed * 0.7;
            Future.delayed(const Duration(seconds: 5), () {
              currentSpeed = baseSpeed;
            });
            break;
          default:
            break;
        }
      }
    });

    if (!foodEaten) {
      snakeBody.removeLast();
    }
  }

  // Modify the update method
  @override
  void update(double dt) {
    if (!isPlaying || isGameOver) return;
    
    elapsedTime += dt;
    final speedMultiplier = (1.0 - (level.value * 0.05)).clamp(0.3, 1.0);
    
    if (elapsedTime >= currentSpeed * speedMultiplier) {
      elapsedTime = 0;
      moveSnake();
    }
  }

  @override
  void render(Canvas canvas) {
    if (!isPlaying) return;
    
    // Draw background grid
    final gridPaint = Paint()
      ..color = Colors.grey[850]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int i = 0; i <= gridSize; i++) {
      canvas.drawLine(
        Offset(i * tileSize, 0),
        Offset(i * tileSize, gridSize * tileSize),
        gridPaint,
      );
      canvas.drawLine(
        Offset(0, i * tileSize),
        Offset(gridSize * tileSize, i * tileSize),
        gridPaint,
      );
    }

    // Draw regular food
    drawFood(canvas, regularFoodPosition, Colors.red);

    // Draw special foods with tooltips
    specialFoods.forEach((type, position) {
      if (position != null && specialFoodVisible[type]!) {
        drawFood(canvas, position, getFoodColor(type));
        
        // Add tooltip based on food type
        String tooltip = '';
        switch (type) {
          case FoodType.shrink:
            tooltip = 'Shrink';
            break;
          case FoodType.slowDown:
            tooltip = 'Slow';
            break;
          case FoodType.speedUp:
            tooltip = 'Speed';
            break;
          default:
            break;
        }
        drawTooltip(canvas, position, tooltip, getFoodColor(type));
      }
    });

    // Draw snake
    for (int i = snakeBody.length - 1; i >= 0; i--) {
      final segment = snakeBody[i];
      final isHead = i == 0;
      final segmentSize = isHead ? tileSize : tileSize - 2;

      // Draw snake segment
      final snakePaint = Paint()
        ..color = snakeBaseColor
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(
              segment.x * tileSize + tileSize / 2,
              segment.y * tileSize + tileSize / 2,
            ),
            width: segmentSize - 2,
            height: segmentSize - 2,
          ),
          const Radius.circular(3),
        ),
        snakePaint,
      );

      // Draw eyes if it's the head
      if (isHead) {
        drawSnakeEyes(canvas, segment);
      }
    }
  }

  // Helper method untuk menggambar mata ular
  void drawSnakeEyes(Canvas canvas, Vector2 segment) {
    final eyePaint = Paint()..color = Colors.white;
    final pupilPaint = Paint()..color = Colors.black;

    // Calculate eye positions based on direction
    double leftEyeX = segment.x * tileSize;
    double leftEyeY = segment.y * tileSize;
    double rightEyeX = segment.x * tileSize;
    double rightEyeY = segment.y * tileSize;

    if (direction.x == 1) {
      leftEyeX += tileSize * 0.7;
      rightEyeX += tileSize * 0.7;
      leftEyeY += tileSize * 0.3;
      rightEyeY += tileSize * 0.7;
    } else if (direction.x == -1) {
      leftEyeX += tileSize * 0.3;
      rightEyeX += tileSize * 0.3;
      leftEyeY += tileSize * 0.3;
      rightEyeY += tileSize * 0.7;
    } else if (direction.y == -1) {
      leftEyeX += tileSize * 0.3;
      rightEyeX += tileSize * 0.7;
      leftEyeY += tileSize * 0.3;
      rightEyeY += tileSize * 0.3;
    } else if (direction.y == 1) {
      leftEyeX += tileSize * 0.3;
      rightEyeX += tileSize * 0.7;
      leftEyeY += tileSize * 0.7;
      rightEyeY += tileSize * 0.7;
    }

    // Draw eyes
    canvas.drawCircle(Offset(leftEyeX, leftEyeY), tileSize * 0.15, eyePaint);
    canvas.drawCircle(Offset(leftEyeX, leftEyeY), tileSize * 0.08, pupilPaint);
    canvas.drawCircle(Offset(rightEyeX, rightEyeY), tileSize * 0.15, eyePaint);
    canvas.drawCircle(Offset(rightEyeX, rightEyeY), tileSize * 0.08, pupilPaint);
  }

  // Add this helper method
  void drawFood(Canvas canvas, Vector2 position, Color color) {
    final foodGlow = Paint()
      ..color = color.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    final foodPaint = Paint()
      ..shader = RadialGradient(
        colors: [color.withOpacity(0.7), color.withOpacity(0.3)],
        center: Alignment.topLeft,
      ).createShader(Rect.fromLTWH(
        position.x * tileSize,
        position.y * tileSize,
        tileSize,
        tileSize,
      ));

    canvas.drawCircle(
      Offset(
        position.x * tileSize + tileSize / 2,
        position.y * tileSize + tileSize / 2,
      ),
      tileSize / 2,
      foodGlow,
    );
    canvas.drawCircle(
      Offset(
        position.x * tileSize + tileSize / 2,
        position.y * tileSize + tileSize / 2,
      ),
      tileSize / 2 - 2,
      foodPaint,
    );
  }

  // Modify getFoodColor to accept a parameter
  Color getFoodColor(FoodType type) {
    switch (type) {
      case FoodType.regular:
        return Colors.red;
      case FoodType.shrink:
        return Colors.blue;
      case FoodType.slowDown:
        return Colors.yellow;
      case FoodType.speedUp:
        return Colors.purple;
    }
  }

  // Modify resetGame to include special foods reset
  // Modify resetGame method
  void resetGame() {
    // Initialize snake with 5 segments
    snakeBody = [
      Vector2(10, 10), // Head
      Vector2(9, 10), // Body
      Vector2(8, 10), // Body
      Vector2(7, 10), // Body
      Vector2(6, 10), // Tail
    ];
    direction = Vector2(1, 0);
    score.value = 0;
    level.value = 1;
    isGameOver = false;
    isPlaying = false;
    currentSpeed = baseSpeed;
    spawnFood();

    // Reset special foods
    specialFoods.forEach((type, _) {
      specialFoods[type] = null;
      specialFoodVisible[type] = false;
    });
    specialFoodTimer = 0;
  }

  void startGame() {
    if (isGameOver) {
      resetGame();
    }
    isPlaying = true;
    overlays.remove('start');
  }

  void togglePause() {
    if (!isGameOver) {
      isPlaying = !isPlaying;
      if (isPlaying) {
        overlays.remove('start');
      } else {
        overlays.add('start');
      }
    }
  }

  // Add this method if it's missing
  void gameOver() {
    isGameOver = true;
    isPlaying = false;
    overlays.add('start');
  }

  // Add this helper method for drawing tooltips
  void drawTooltip(Canvas canvas, Vector2 position, String text, Color color) {
    final tooltipPaint = Paint()
      ..color = Colors.black.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 8, // Smaller font size
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final tooltipWidth = textPainter.width + 6; // Smaller padding
    final tooltipHeight = 12.0; // Smaller height
    final tooltipX = position.x * tileSize + (tileSize - tooltipWidth) / 2;
    final tooltipY =
        position.y * tileSize - tooltipHeight - 1; // Closer to food

    // Draw tooltip background with rounded corners
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(tooltipX, tooltipY, tooltipWidth, tooltipHeight),
        const Radius.circular(6), // Smaller corner radius
      ),
      tooltipPaint,
    );

    // Draw text centered in tooltip
    textPainter.paint(
      canvas,
      Offset(
        tooltipX + 3, // Smaller padding
        tooltipY + (tooltipHeight - textPainter.height) / 2,
      ),
    );
  }

  @override
  Future<void> onLoad() async {
    resetGame();
    overlays.add('start');
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (!isPlaying) return KeyEventResult.handled;

    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowUp:
          if (direction.y != 1) direction = Vector2(0, -1);
          break;
        case LogicalKeyboardKey.arrowDown:
          if (direction.y != -1) direction = Vector2(0, 1);
          break;
        case LogicalKeyboardKey.arrowLeft:
          if (direction.x != 1) direction = Vector2(-1, 0);
          break;
        case LogicalKeyboardKey.arrowRight:
          if (direction.x != -1) direction = Vector2(1, 0);
          break;
        case LogicalKeyboardKey.space:
          togglePause();
          break;
      }
    }
    return KeyEventResult.handled;
  }
  // Add this method near other control methods
  void changeDirection(int x, int y) {
  // Prevent snake from reversing directly
  if ((x == 0 || direction.x != -x) && (y == 0 || direction.y != -y)) {
  direction = Vector2(x.toDouble(), y.toDouble());
  // Force immediate update for responsive controls
  elapsedTime = currentSpeed;
  }
  }

  void showColorPicker(BuildContext context) {
    if (!isPlaying) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        title: const Text('Customize Snake', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Preview
            Container(
              width: 200,
              height: 100,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomPaint(
                painter: SnakePreviewPainter(
                  baseColor: snakeBaseColor,
                  accentColor: snakeAccentColor,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Color Pickers
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text('Base Color', style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 8),
                      _buildColorGrid(context, true),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      const Text('Accent Color', style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 8),
                      _buildColorGrid(context, false),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorGrid(BuildContext context, bool isBase) {
    final colors = [
      Colors.green,
      Colors.blue,
      Colors.red,
      Colors.purple,
      Colors.orange,
      Colors.teal,
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: colors.map((color) {
        return GestureDetector(
          onTap: () {
            setSnakeColor(
              isBase ? color[700]! : snakeBaseColor,
              isBase ? snakeAccentColor : color[400]!,
            );
            Navigator.pop(context);
          },
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: isBase ? color[700] : color[400],
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: Colors.white24,
                width: 1,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class SnakePreviewPainter extends CustomPainter {
  final Color baseColor;
  final Color accentColor;

  SnakePreviewPainter({
    required this.baseColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final snakePaint = Paint()
      ..shader = LinearGradient(
        colors: [baseColor, accentColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Draw snake body in S shape
    double x = size.width * 0.1;
    double y = size.height * 0.5;
    final segmentSize = size.height * 0.3;
    
    for (int i = 0; i < 5; i++) {
      canvas.drawCircle(
        Offset(x, y),
        segmentSize / 2,
        snakePaint,
      );
      
      if (i < 2) {
        y -= segmentSize * 0.8;
      } else if (i < 4) {
        y += segmentSize * 0.8;
      }
      x += segmentSize * 0.8;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
