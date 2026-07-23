const std = @import("std");
const rl = @import("raylib_c.zig").raylib;
const fb = @import("framebuffer.zig");
const Point = fb.Point;

// Poligono 3: rojo, orilla blanca
const polygon3 = [_]Point{
    .{ .x = 377, .y = 249 },
    .{ .x = 411, .y = 197 },
    .{ .x = 436, .y = 249 },
};

pub fn main() !void {
    const width = 800;
    const height = 600;
    var framebuffer = fb.Framebuffer.init(width, height, rl.BLACK);

    rl.InitWindow(width, height, "Software Renderer - Poligono 3");
    defer rl.CloseWindow();
    rl.SetTargetFPS(60);

    var exported = false;

    while (!rl.WindowShouldClose()) {
        framebuffer.clear();

        framebuffer.fill_polygon(&polygon3, rl.RED);
        framebuffer.draw_polygon_outline(&polygon3, rl.WHITE);

        if (!exported) {
            framebuffer.export_image("out.bmp");
            exported = true;
        }

        framebuffer.swap();
    }
}