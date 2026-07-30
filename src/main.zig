const std = @import("std");
const rl = @import("raylib_c.zig").raylib;
const fb = @import("framebuffer.zig");
const Point = fb.Point;

//  Poligono 1: amarillo, orilla blanca 
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

//  Poligono 2: azul, orilla blanca 
const polygon2 = [_]Point{
    .{ .x = 321, .y = 335 },
    .{ .x = 288, .y = 286 },
    .{ .x = 339, .y = 251 },
    .{ .x = 374, .y = 302 },
};

//  Poligono 3: rojo, orilla blanca 
const polygon3 = [_]Point{
    .{ .x = 377, .y = 249 },
    .{ .x = 411, .y = 197 },
    .{ .x = 436, .y = 249 },
};

//  Poligono 4: verde, orilla blanca, con poligono 5 como agujero 
const polygon4 = [_]Point{
    .{ .x = 413, .y = 177 },
    .{ .x = 448, .y = 159 },
    .{ .x = 502, .y = 88 },
    .{ .x = 553, .y = 53 },
    .{ .x = 535, .y = 36 },
    .{ .x = 676, .y = 37 },
    .{ .x = 660, .y = 52 },
    .{ .x = 750, .y = 145 },
    .{ .x = 761, .y = 179 },
    .{ .x = 672, .y = 192 },
    .{ .x = 659, .y = 214 },
    .{ .x = 615, .y = 214 },
    .{ .x = 632, .y = 230 },
    .{ .x = 580, .y = 230 },
    .{ .x = 597, .y = 215 },
    .{ .x = 552, .y = 214 },
    .{ .x = 517, .y = 144 },
    .{ .x = 466, .y = 180 },
};

//  Poligono 5: agujero dentro del poligono 4, no se pinta 
const polygon5_hole = [_]Point{
    .{ .x = 682, .y = 175 },
    .{ .x = 708, .y = 120 },
    .{ .x = 735, .y = 148 },
    .{ .x = 739, .y = 170 },
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

        framebuffer.fill_polygon_with_holes(&[_][]const Point{ &polygon4, &polygon5_hole }, rl.GREEN);
        framebuffer.draw_polygon_outline(&polygon4, rl.WHITE);
        framebuffer.draw_polygon_outline(&polygon5_hole, rl.WHITE);

        if (!exported) {
            framebuffer.export_image("out.bmp");
            exported = true;
        }

        framebuffer.swap();
    }
}