const std = @import("std");
const rl = @import("raylib_c.zig").raylib;
const fb = @import("framebuffer.zig");
const Point = fb.Point;

// Poligono 2: azul, orilla blanca
const polygon2 = [_]Point{
    .{ .x = 321, .y = 335 },
    .{ .x = 288, .y = 286 },
    .{ .x = 339, .y = 251 },
    .{ .x = 374, .y = 302 },
};

pub fn main() !void {
    const width = 800;
    const height = 600;
    var framebuffer = fb.Framebuffer.init(width, height, rl.BLACK);

    rl.InitWindow(width, height, "Software Renderer - Poligono 2");
    defer rl.CloseWindow();
    rl.SetTargetFPS(60);

    var exported = false;

    while (!rl.WindowShouldClose()) {
        framebuffer.clear();

        framebuffer.fill_polygon(&polygon2, rl.BLUE);
        framebuffer.draw_polygon_outline(&polygon2, rl.WHITE);

        if (!exported) {
            framebuffer.export_image("out.bmp");
            exported = true;
        }

        framebuffer.swap();
    }
}