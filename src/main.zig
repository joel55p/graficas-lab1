const std = @import("std");
const rl = @import("raylib_c.zig").raylib;
const fb = @import("framebuffer.zig");
const Point = fb.Point;

// --- Poligono 1: amarillo, orilla blanca ---
const polygon1 = [_]Point{
    .{ .x = 165, .y = 380 },
    .{ .x = 185, .y = 360 },
    .{ .x = 180, .y = 330 },
    .{ .x = 207, .y = 345 },
    .{ .x = 233, .y = 330 },
    .{ .x = 230, .y = 360 },
    .{ .x = 250, .y = 380 },
    .{ .x = 220, .y = 385 },
    .{ .x = 205, .y = 410 },
    .{ .x = 193, .y = 383 },
};

// --- Poligono 2: azul, orilla blanca ---
const polygon2 = [_]Point{
    .{ .x = 321, .y = 335 },
    .{ .x = 288, .y = 286 },
    .{ .x = 339, .y = 251 },
    .{ .x = 374, .y = 302 },
};

// --- Poligono 3: rojo, orilla blanca ---
const polygon3 = [_]Point{
    .{ .x = 377, .y = 249 },
    .{ .x = 411, .y = 197 },
    .{ .x = 436, .y = 249 },
};


pub fn main() !void {
    const width = 800;
    const height = 600;
    var framebuffer = fb.Framebuffer.init(width, height, rl.BLACK);

    rl.InitWindow(width, height, "Software Renderer - Poligonos");
    defer rl.CloseWindow();
    rl.SetTargetFPS(60);

    var exported = false;

    while (!rl.WindowShouldClose()) {
        framebuffer.clear();

        framebuffer.fill_polygon(&polygon1, rl.YELLOW);
        framebuffer.draw_polygon_outline(&polygon1, rl.WHITE);

        framebuffer.fill_polygon(&polygon2, rl.BLUE);
        framebuffer.draw_polygon_outline(&polygon2, rl.WHITE);

        framebuffer.fill_polygon(&polygon3, rl.RED);
        framebuffer.draw_polygon_outline(&polygon3, rl.WHITE);


        if (!exported) {
            framebuffer.export_image("out.bmp");
            exported = true;
        }

        framebuffer.swap();
    }
}