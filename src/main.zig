const rl = @import("raylib");

var playerPos = rl.Vector2{ .x = 100, .y = 100 };

pub fn main() anyerror!void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 800;
    const screenHeight = 450;

    rl.initWindow(screenWidth, screenHeight, "raylib-zig [core] example - basic window");
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        // Player Movement
        if (rl.isKeyDown(rl.KeyboardKey.key_w)) {
            playerPos.y -= 2;
        }
        if (rl.isKeyDown(rl.KeyboardKey.key_a)) {
            playerPos.x -= 2;
        }
        if (rl.isKeyDown(rl.KeyboardKey.key_s)) {
            playerPos.y += 2;
        }
        if (rl.isKeyDown(rl.KeyboardKey.key_d)) {
            playerPos.x += 2;
        }

        // Draw
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.white);

        rl.drawCircleV(playerPos, 16.0, rl.Color.red);
    }
}
