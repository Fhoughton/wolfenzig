const rl = @import("raylib");

var playerPos = rl.Vector2{ .x = 100, .y = 100 };

const map = [8][8]i32{
    [_]i32{1,1,1,1,1,1,1,1},
    [_]i32{1,0,0,0,0,0,0,1},
    [_]i32{1,0,0,0,1,1,1,1},
    [_]i32{1,0,0,0,1,0,0,1},
    [_]i32{1,0,0,0,1,0,1,1},
    [_]i32{1,0,1,0,1,0,0,1},
    [_]i32{1,0,0,0,0,0,0,1},
    [_]i32{1,1,1,1,1,1,1,1},
};

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
        const pastPlayerPos = playerPos;
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

        // Check collisions and undo movement if any collide
        for (0..8) |x| {
            for (0..8) |y| {
                if (map[x][y] == 1) {
                    if (rl.checkCollisionCircleRec(playerPos, 8.0, rl.Rectangle{ .x = @as(f32, @floatFromInt(x*32)), .y = @as(f32, @floatFromInt(y*32)), .width = 32, .height = 32})) {
                        playerPos = pastPlayerPos;
                        break;
                    }
                }
            }
        }

        // Begin Drawing
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.white);

        // Draw Map
        for (0..8) |x| {
            for (0..8) |y| {
                if (map[x][y] == 1) {
                    rl.drawRectangle(@as(i32, @intCast(x*32)), @as(i32, @intCast(y*32)), 32, 32, rl.Color.blue);
                }
            }
        }

        // Draw Player
        rl.drawCircleV(playerPos, 8.0, rl.Color.red);
    }
}
