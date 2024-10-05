const rl = @import("raylib");

var playerPos = rl.Vector2{ .x = 100, .y = 100 };
var playerAngle: f32 = 0.0;

const PI = 3.1415;

const map = [8][8]i32{
    [_]i32{ 1, 1, 1, 1, 1, 1, 1, 1 },
    [_]i32{ 1, 0, 0, 0, 0, 0, 0, 1 },
    [_]i32{ 1, 0, 0, 0, 1, 1, 1, 1 },
    [_]i32{ 1, 0, 0, 0, 1, 0, 0, 1 },
    [_]i32{ 1, 0, 0, 0, 1, 0, 1, 1 },
    [_]i32{ 1, 0, 1, 0, 1, 0, 0, 1 },
    [_]i32{ 1, 0, 0, 0, 0, 0, 0, 1 },
    [_]i32{ 1, 1, 1, 1, 1, 1, 1, 1 },
};

fn handlePlayerMovement() !void {
    const pastPlayerPos = playerPos;

    // Rotation
    if (rl.isKeyDown(rl.KeyboardKey.key_a)) {
        playerAngle -= 0.1;

        if (playerAngle < 0) {
            playerAngle += 2 * PI;
        }
    }
    if (rl.isKeyDown(rl.KeyboardKey.key_d)) {
        playerAngle += 0.1;

        if (playerAngle > 2 * PI) {
            playerAngle -= 2 * PI;
        }
    }

    // Motion
    if (rl.isKeyDown(rl.KeyboardKey.key_w)) {
        playerPos.x -= @cos(playerAngle);
        playerPos.y -= @sin(playerAngle);
    }
    if (rl.isKeyDown(rl.KeyboardKey.key_s)) {
        playerPos.x -= @cos(playerAngle);
        playerPos.y -= @sin(playerAngle);
    }

    // Check collisions and undo movement if any collide
    for (0..8) |x| {
        for (0..8) |y| {
            if (map[x][y] == 1) {
                if (rl.checkCollisionCircleRec(playerPos, 8.0, rl.Rectangle{ .x = @as(f32, @floatFromInt(x * 32)), .y = @as(f32, @floatFromInt(y * 32)), .width = 32, .height = 32 })) {
                    playerPos = pastPlayerPos;
                    break;
                }
            }
        }
    }
}

fn roundToNearestMultiple(value: f32, multiple: f32) f32 {
    return ((value + multiple / 2) / multiple) * multiple;
}

fn draw3dRays() !void {
    const rayMaxLength = 8;
    const rayCount = 1;

    const rayAngle = playerAngle;
    var rayDistance: i32 = 0;

    var rayPosition = rl.Vector2{ .x = 0, .y = 0 };
    var rayOffset = rl.Vector2{ .x = 0, .y = 0 };

    // For each ray we travel up to rayMaxLength pixels at the corresponding angle to find a wall
    for (0..rayCount) |_| {
        rayDistance = 0;

        const aTan = -1 / @tan(rayAngle);

        // Looking up (less than 180 degrees)
        if (rayAngle > PI) {
            rayPosition.y = roundToNearestMultiple(rayPosition.y, 32); // Snap to grid
            rayPosition.x = (playerPos.y - rayPosition.y) * aTan + playerPos.x; // Distance between ray's position and player's position times aTan + player x position
            rayOffset.y = -32;
            rayOffset.x = -rayOffset.y * aTan;
        }
        // Looking down
        else if (rayAngle < PI) {
            rayPosition.y = roundToNearestMultiple(rayPosition.y, 32) + 32; // Snap to grid
            rayPosition.x = (playerPos.y - rayPosition.y) * aTan + playerPos.x; // Distance between ray's position and player's position times aTan + player x position
            rayOffset.y = 32;
            rayOffset.x = -rayOffset.y * aTan;
        }
        // Looking directly left or right (can't ever hit a horizontal line so we skip)
        else if (rayAngle == 0 or rayAngle == PI) {
            rayPosition.x = playerPos.x;
            rayPosition.y = playerPos.y;
            rayDistance = rayMaxLength; // End the ray prematurely
        }

        while (rayDistance < 8) {
            const mapPosition = rl.Vector2{ .x = rayPosition.x / 32, .y = rayPosition.y / 32 };

            if (mapPosition.x < 0 or mapPosition.y < 0 or map[@intFromFloat(mapPosition.x)][@intFromFloat(mapPosition.y)] == 1) {
                rayDistance = 8; // Wall hiti
            } else {
                // Otherwise if no wall hit we simply move the ray forward one block in the grid
                rayPosition.x += rayOffset.x;
                rayPosition.y += rayOffset.y;
                rayDistance += 1;
            }
        }

        rl.drawLineV(playerPos, rayPosition, rl.Color.green);
    }
}

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
        _ = handlePlayerMovement() catch {};

        // == Begin Drawing ==
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.gray);

        // Draw Map
        for (0..8) |x| {
            for (0..8) |y| {
                if (map[x][y] == 1) {
                    rl.drawRectangle(@as(i32, @intCast(x * 32)), @as(i32, @intCast(y * 32)), 32, 32, rl.Color.blue);
                }
            }
        }

        // Draw Player
        rl.drawCircleV(playerPos, 8.0, rl.Color.red);
        rl.drawLine(@intFromFloat(playerPos.x), @intFromFloat(playerPos.y), @intFromFloat(playerPos.x + @cos(playerAngle) * -8), @intFromFloat(playerPos.y + @sin(playerAngle) * -8), rl.Color.yellow); // View angle line
        _ = draw3dRays() catch {};
    }
}
