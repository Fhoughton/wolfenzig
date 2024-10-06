const rl = @import("raylib");
const rlm = rl.math;

var playerPos = rl.Vector2{ .x = 100, .y = 100 };
var playerAngle: f32 = 0.0;

const PI = 3.1415;
const ONEDEG = 0.0174533; // One degree in radians

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
        playerPos.x += @cos(playerAngle);
        playerPos.y += @sin(playerAngle);
    }

    // Check collisions and undo movement if any collide
    for (0..8) |x| {
        for (0..8) |y| {
            if (map[x][y] == 1) {
                if (rl.checkCollisionCircleRec(playerPos, 4.0, rl.Rectangle{ .x = @as(f32, @floatFromInt(x * 32)), .y = @as(f32, @floatFromInt(y * 32)), .width = 32, .height = 32 })) {
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
    const fieldOfView = 60;
    const viewDistance = 128;
    const rayStart = playerPos;

    var viewAngle: f32 = (-fieldOfView / 2) * ONEDEG;
    var rayDirection = rl.Vector2{ .x = -@cos(playerAngle + viewAngle), .y = -@sin(playerAngle + viewAngle) };

    const rayStep = 0.1;

    var rayDelta = rlm.vector2Scale(rayDirection, rayStep);

    var rayPosition = rayStart;
    var rayHit: bool = false;

    for (0..fieldOfView) |rayCount| {
        while (rlm.vector2Distance(rayStart, rayPosition) < viewDistance) {
            rayPosition = rlm.vector2Add(rayPosition, rayDelta);

            const rayMapPosition = rl.Vector2{ .x = rayPosition.x / 32, .y = rayPosition.y / 32 };
            if (rayMapPosition.x < 8 and rayMapPosition.y < 8 and rayMapPosition.x > 0 and rayMapPosition.y > 0 and map[@intFromFloat(rayMapPosition.x)][@intFromFloat(rayMapPosition.y)] == 1) {
                rayHit = true;
                break;
            }
        }

        // Draw 2D Rays
        if (rayHit) {
            rl.drawLineV(rayStart, rayPosition, rl.Color.green);
        } else {
            rl.drawLineV(rayStart, rayPosition, rl.Color.red);
        }

        // Draw 3D Walls
        const windowPos = rl.Vector2{ .x = 400, .y = 20 };
        const lineHeight = (8 * 2000) / rlm.vector2Distance(rayStart, rayPosition); // (Map size * window height) / line distance (to make it so further walls are smaller)

        if (rayHit) {
            rl.drawLineEx(rl.Vector2{ .x = @as(f32, @floatFromInt(rayCount)) * 8 + windowPos.x, .y = windowPos.y }, rl.Vector2{ .x = @as(f32, @floatFromInt(rayCount)) * 8 + windowPos.x, .y = windowPos.y + lineHeight }, 8.0, rl.Color.blue);
        }

        // Recalculate the ray for the next angle
        viewAngle += ONEDEG;
        rayPosition = rayStart;
        rayDirection = rl.Vector2{ .x = -@cos(playerAngle + viewAngle), .y = -@sin(playerAngle + viewAngle) };
        rayDelta = rlm.vector2Scale(rayDirection, rayStep);
        rayHit = false;
    }
}

pub fn main() anyerror!void {
    const screenWidth = 800;
    const screenHeight = 450;

    rl.initWindow(screenWidth, screenHeight, "raylib-zig [core] example - basic window");
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second

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
        rl.drawCircleV(playerPos, 4.0, rl.Color.red);
        _ = draw3dRays() catch {};
        rl.drawLine(@intFromFloat(playerPos.x), @intFromFloat(playerPos.y), @intFromFloat(playerPos.x + @cos(playerAngle) * -8), @intFromFloat(playerPos.y + @sin(playerAngle) * -8), rl.Color.yellow); // View angle line
    }
}
