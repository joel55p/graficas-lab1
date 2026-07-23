const std = @import("std");
const rl = @import("raylib_c.zig").raylib;

pub const Point = struct {
    x: i32,
    y: i32,
};

pub const Framebuffer = struct {
    width: i32,
    height: i32,
    image: rl.Image,
    texture: ?rl.Texture2D,
    background_color: rl.Color,

    pub fn init(width: i32, height: i32, color: rl.Color) Framebuffer {
        return Framebuffer{
            .width = width,
            .height = height,
            .image = rl.GenImageColor(width, height, color),
            .background_color = color,
            .texture = null,
        };
    }

    /// Pone un pixel usando coordenadas enteras. Ignora silenciosamente
    /// coordenadas fuera del canvas (el relleno y las lineas de un poligono
    /// facilmente generan valores fuera de rango al redondear).
    pub fn draw_pixel_i32(self: *Framebuffer, x: i32, y: i32, color: rl.Color) void {
        if (x < 0 or y < 0 or x >= self.width or y >= self.height) return;
        rl.ImageDrawPixel(&self.image, x, y, color);
    }

    /// Algoritmo de Bresenham para dibujar una linea entre dos puntos enteros.
    pub fn draw_line_i32(self: *Framebuffer, x0: i32, y0: i32, x1: i32, y1: i32, color: rl.Color) void {
        var x = x0;
        var y = y0;
        const dx: i32 = @intCast(@abs(x1 - x0));
        const dy: i32 = -@as(i32, @intCast(@abs(y1 - y0)));
        const step_x: i32 = if (x0 < x1) 1 else -1;
        const step_y: i32 = if (y0 < y1) 1 else -1;
        var err: i32 = dx + dy;

        while (true) {
            self.draw_pixel_i32(x, y, color);

            if (x == x1 and y == y1) break;

            const e2 = 2 * err;
            if (e2 >= dy) {
                err += dy;
                x += step_x;
            }
            if (e2 <= dx) {
                err += dx;
                y += step_y;
            }
        }
    }

    /// Dibuja el contorno (orilla) de un poligono, conectando cada punto
    /// con el siguiente y cerrando la figura (ultimo punto -> primer punto).
    pub fn draw_polygon_outline(self: *Framebuffer, points: []const Point, color: rl.Color) void {
        const n = points.len;
        if (n < 2) return;

        var i: usize = 0;
        while (i < n) : (i += 1) {
            const j = (i + 1) % n;
            self.draw_line_i32(points[i].x, points[i].y, points[j].x, points[j].y, color);
        }
    }

    /// Rellena uno o mas contornos con un scanline fill de regla par-impar
    /// (even-odd rule). Al pasar mas de un contorno (poligono exterior +
    /// poligono "agujero"), las zonas cubiertas por un numero par de
    /// contornos quedan sin pintar: asi sale el agujero solo, sin logica
    /// especial. Funciona con poligonos de cualquier cantidad de vertices,
    /// concavos o convexos.
    pub fn fill_polygon_with_holes(self: *Framebuffer, contours: []const []const Point, color: rl.Color) void {
        var y_min: i32 = self.height - 1;
        var y_max: i32 = 0;

        for (contours) |contour| {
            for (contour) |p| {
                if (p.y < y_min) y_min = p.y;
                if (p.y > y_max) y_max = p.y;
            }
        }

        if (y_min < 0) y_min = 0;
        if (y_max > self.height - 1) y_max = self.height - 1;

        // 256 intersecciones alcanza de sobra (el poligono mas grande de
        // este lab tiene 18 + 4 vertices).
        var intersections: [256]i32 = undefined;

        var y = y_min;
        while (y <= y_max) : (y += 1) {
            var count: usize = 0;

            for (contours) |contour| {
                const n = contour.len;
                var i: usize = 0;
                while (i < n) : (i += 1) {
                    const j = (i + 1) % n;
                    const p0 = contour[i];
                    const p1 = contour[j];

                    const y0 = p0.y;
                    const y1 = p1.y;

                    // Solo contamos la arista si realmente cruza la scanline.
                    // Intervalo semi-abierto [y0, y1) para no contar doble
                    // un vertice que cae justo sobre la linea.
                    if ((y0 <= y and y1 > y) or (y1 <= y and y0 > y)) {
                        const t: f32 = @as(f32, @floatFromInt(y - y0)) / @as(f32, @floatFromInt(y1 - y0));
                        const x_f: f32 = @as(f32, @floatFromInt(p0.x)) + t * @as(f32, @floatFromInt(p1.x - p0.x));
                        intersections[count] = @intFromFloat(@round(x_f));
                        count += 1;
                    }
                }
            }

            insertion_sort(intersections[0..count]);

            var k: usize = 0;
            while (k + 1 < count) : (k += 2) {
                var x = intersections[k];
                const x_end = intersections[k + 1];
                while (x <= x_end) : (x += 1) {
                    self.draw_pixel_i32(x, y, color);
                }
            }
        }
    }

    /// Version simplificada para un solo contorno (sin agujeros).
    pub fn fill_polygon(self: *Framebuffer, points: []const Point, color: rl.Color) void {
        self.fill_polygon_with_holes(&[_][]const Point{points}, color);
    }

    /// Exporta el framebuffer actual a un archivo (por ejemplo "out.bmp").
    /// El formato lo determina la extension del nombre.
    pub fn export_image(self: *Framebuffer, path: [*c]const u8) void {
        _ = rl.ExportImage(self.image, path);
    }

    pub fn clear(self: *Framebuffer) void {
        rl.ImageClearBackground(&self.image, self.background_color);
        if (self.texture) |texture| {
            rl.UnloadTexture(texture);
        }
    }

    pub fn swap(self: *Framebuffer) void {
        rl.BeginDrawing();
        defer rl.EndDrawing();

        self.texture = rl.LoadTextureFromImage(self.image);
        rl.DrawTexture(self.texture.?, 0, 0, rl.WHITE);
    }
};

/// Insertion sort: suficiente para las pocas intersecciones por scanline
/// que maneja este laboratorio, sin depender de una version especifica de
/// std.sort.
fn insertion_sort(arr: []i32) void {
    var i: usize = 1;
    while (i < arr.len) : (i += 1) {
        const key = arr[i];
        var j = i;
        while (j > 0 and arr[j - 1] > key) : (j -= 1) {
            arr[j] = arr[j - 1];
        }
        arr[j] = key;
    }
}