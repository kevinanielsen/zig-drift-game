const rl = @import("raylib");
const std = @import("std");
const math = std.math;
const rlm = rl.math;
const Vector2 = rl.Vector2;

const THICKNESS: f32 = 2;
const SCALE: f32 = 3;
const ROT_SPEED = 0.6;
const ACCELERATION = 5;
const DRAG = 0.97;

const Car = struct {
    pos: Vector2 = Vector2.init(0, 0),
    velocity: Vector2,
    rot: f32 = 0,
};

const State = struct {
    now: f32,
    delta: f32,
    car: Car,
};

var state: State = undefined;

fn drawLines(
    org: Vector2,
    scale: f32,
    rot: f32,
    points: []const Vector2,
) void {
    const Transformer = struct {
        org: Vector2,
        scale: f32,
        rot: f32,

        fn apply(self: @This(), p: Vector2) Vector2 {
            return rlm.vector2Add(
                rlm.vector2Scale(
                    rlm.vector2Rotate(p, self.rot),
                    self.scale,
                ),
                self.org,
            );
        }
    };

    const t = Transformer{
        .org = org,
        .scale = scale,
        .rot = rot,
    };

    for (0..points.len) |i| {
        rl.drawLineEx(
            t.apply(points[i]),
            t.apply(points[(i + 1) % points.len]),
            THICKNESS,
            rl.Color.white,
        );
    }
}

fn update() void {
    if (rl.isKeyDown(.key_a)) {
        state.car.rot -= state.delta * ROT_SPEED * math.tau;
    }

    if (rl.isKeyDown(.key_d)) {
        state.car.rot += state.delta * ROT_SPEED * math.tau;
    }

    if (rl.isKeyDown(.key_w)) {
        state.car.velocity = rlm.vector2Add(state.car.velocity, Vector2.init(
            math.cos(state.car.rot) * state.delta * ACCELERATION,
            math.sin(state.car.rot) * state.delta * ACCELERATION,
        ));
    }

    if (rl.isKeyDown(.key_s)) {
        state.car.velocity = rlm.vector2Subtract(state.car.velocity, Vector2.init(
            math.cos(state.car.rot) * state.delta * ACCELERATION,
            math.sin(state.car.rot) * state.delta * ACCELERATION,
        ));
    }

    state.car.pos = rlm.vector2Add(
        state.car.pos,
        state.car.velocity,
    );

    if (!rl.isKeyDown(.key_w) and !rl.isKeyDown(.key_s)) {
        state.car.velocity = rlm.vector2Scale(state.car.velocity, DRAG);
    }
}

fn render() void {
    drawLines(
        state.car.pos,
        SCALE,
        state.car.rot,
        &.{
            Vector2.init(-10, -5),
            Vector2.init(-10, 5),
            Vector2.init(10, 5),
            Vector2.init(10, -5),
        },
    );
}

pub fn main() !void {
    rl.initWindow(800, 600, "Drifting Game");
    defer rl.closeWindow();
    rl.setTargetFPS(60);

    state = .{
        .delta = 0.0,
        .now = 0.0,
        .car = .{
            .pos = Vector2.init(400, 300),
            .velocity = Vector2.init(0, 0),
            .rot = 0.0,
        },
    };

    while (!rl.windowShouldClose()) {
        state.delta = rl.getFrameTime();
        state.now += state.delta;
        update();

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);

        render();
    }
}
