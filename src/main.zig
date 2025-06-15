const std = @import("std");
const sapp = @import("sokol").app;
const sglue = @import("sokol").glue;
const sg = @import("sokol").gfx;
const slog = @import("sokol").log;
const simgui = @import("sokol").imgui;
const shaders = @import("shaders/shaders.glsl.zig");
const math = @import("math.zig");

// Cube steps
// 1. More data
// 2. View state
// 3. Shader (Uniform of a mat4 from math lib)
// 3. Frame
//      1. Proj/View/Model
//      2. Apply and send to uniform
//

const VERTEX_SIZE = 7;
const MAX_VERTEX_SIZE = VERTEX_SIZE * 1000;
const MAX_INDEX_SIZE = 1000;
const INSTANCE_VERTEX_SIZE = 64;
const MAX_INSTANCE_SIZE = 64 * 15625;

const Vertex = struct {
    position: [3]f32,
    color: sg.Color,
};

const Mesh = struct {
    vertices: []const Vertex,
    indices: []const u16,
};

const Shapes = struct {
    fn Cube() Mesh {
        return .{
            .vertices = &.{
                // Front face (red)
                .{ .position = .{ -1.0, -1.0, -1.0 }, .color = .{ .r = 1.0, .g = 0.0, .b = 0.0, .a = 1.0 } },
                .{ .position = .{ 1.0, -1.0, -1.0 }, .color = .{ .r = 1.0, .g = 0.0, .b = 0.0, .a = 1.0 } },
                .{ .position = .{ 1.0, 1.0, -1.0 }, .color = .{ .r = 1.0, .g = 0.0, .b = 0.0, .a = 1.0 } },
                .{ .position = .{ -1.0, 1.0, -1.0 }, .color = .{ .r = 1.0, .g = 0.0, .b = 0.0, .a = 1.0 } },

                // Back face (green)
                .{ .position = .{ -1.0, -1.0, 1.0 }, .color = .{ .r = 0.0, .g = 1.0, .b = 0.0, .a = 1.0 } },
                .{ .position = .{ 1.0, -1.0, 1.0 }, .color = .{ .r = 0.0, .g = 1.0, .b = 0.0, .a = 1.0 } },
                .{ .position = .{ 1.0, 1.0, 1.0 }, .color = .{ .r = 0.0, .g = 1.0, .b = 0.0, .a = 1.0 } },
                .{ .position = .{ -1.0, 1.0, 1.0 }, .color = .{ .r = 0.0, .g = 1.0, .b = 0.0, .a = 1.0 } },

                // Left face (blue)
                .{ .position = .{ -1.0, -1.0, -1.0 }, .color = .{ .r = 0.0, .g = 0.0, .b = 1.0, .a = 1.0 } },
                .{ .position = .{ -1.0, 1.0, -1.0 }, .color = .{ .r = 0.0, .g = 0.0, .b = 1.0, .a = 1.0 } },
                .{ .position = .{ -1.0, 1.0, 1.0 }, .color = .{ .r = 0.0, .g = 0.0, .b = 1.0, .a = 1.0 } },
                .{ .position = .{ -1.0, -1.0, 1.0 }, .color = .{ .r = 0.0, .g = 0.0, .b = 1.0, .a = 1.0 } },

                // Right face (orange)
                .{ .position = .{ 1.0, -1.0, -1.0 }, .color = .{ .r = 1.0, .g = 0.5, .b = 0.0, .a = 1.0 } },
                .{ .position = .{ 1.0, 1.0, -1.0 }, .color = .{ .r = 1.0, .g = 0.5, .b = 0.0, .a = 1.0 } },
                .{ .position = .{ 1.0, 1.0, 1.0 }, .color = .{ .r = 1.0, .g = 0.5, .b = 0.0, .a = 1.0 } },
                .{ .position = .{ 1.0, -1.0, 1.0 }, .color = .{ .r = 1.0, .g = 0.5, .b = 0.0, .a = 1.0 } },

                // Bottom face (cyan)
                .{ .position = .{ -1.0, -1.0, -1.0 }, .color = .{ .r = 0.0, .g = 0.5, .b = 1.0, .a = 1.0 } },
                .{ .position = .{ -1.0, -1.0, 1.0 }, .color = .{ .r = 0.0, .g = 0.5, .b = 1.0, .a = 1.0 } },
                .{ .position = .{ 1.0, -1.0, 1.0 }, .color = .{ .r = 0.0, .g = 0.5, .b = 1.0, .a = 1.0 } },
                .{ .position = .{ 1.0, -1.0, -1.0 }, .color = .{ .r = 0.0, .g = 0.5, .b = 1.0, .a = 1.0 } },

                // Top face (magenta)
                .{ .position = .{ -1.0, 1.0, -1.0 }, .color = .{ .r = 1.0, .g = 0.0, .b = 0.5, .a = 1.0 } },
                .{ .position = .{ -1.0, 1.0, 1.0 }, .color = .{ .r = 1.0, .g = 0.0, .b = 0.5, .a = 1.0 } },
                .{ .position = .{ 1.0, 1.0, 1.0 }, .color = .{ .r = 1.0, .g = 0.0, .b = 0.5, .a = 1.0 } },
                .{ .position = .{ 1.0, 1.0, -1.0 }, .color = .{ .r = 1.0, .g = 0.0, .b = 0.5, .a = 1.0 } },
            },
            .indices = &.{
                0,  1,  2,  0,  2,  3,
                6,  5,  4,  7,  6,  4,
                8,  9,  10, 8,  10, 11,
                14, 13, 12, 15, 14, 12,
                16, 17, 18, 16, 18, 19,
                22, 21, 20, 23, 22, 20,
            },
        };
    }
};

const Renderer = struct {
    vertexBuffer: sg.Buffer,

    indexBuffer: sg.Buffer,
    indexLength: u32,

    instanceBuffer: sg.Buffer,
    instanceLength: u32,

    passAction: sg.PassAction,
    pip: sg.Pipeline,
    bind: sg.Bindings,
    view: math.Mat4,

    fn init() Renderer {
        sg.setup(.{ .environment = sglue.environment(), .logger = .{ .func = slog.func } });

        return Renderer{
            .vertexBuffer = sg.makeBuffer(.{ .size = MAX_VERTEX_SIZE, .usage = .{ .vertex_buffer = true, .stream_update = true } }),
            .indexBuffer = sg.makeBuffer(.{ .size = MAX_INDEX_SIZE, .usage = .{ .index_buffer = true, .stream_update = true } }),
            .instanceBuffer = sg.makeBuffer(.{ .size = MAX_INSTANCE_SIZE, .usage = .{ .vertex_buffer = true, .stream_update = true } }),
            .passAction = .{},
            .pip = .{},
            .bind = .{},
            .view = math.Mat4.lookat(.{ .x = 0.0, .y = 70.0, .z = 100.0 }, math.Vec3.zero(), math.Vec3.up()),
            .indexLength = 0,
            .instanceLength = 0,
        };
    }

    fn addMesh(self: *Renderer, mesh: Mesh, instances: []math.Mat4) void {
        self.indexLength = @intCast(mesh.indices.len);
        self.instanceLength = @intCast(instances.len);
        sg.updateBuffer(self.vertexBuffer, sg.asRange(mesh.vertices));
        sg.updateBuffer(self.indexBuffer, sg.asRange(mesh.indices));
        sg.updateBuffer(self.instanceBuffer, sg.asRange(instances));
    }

    fn submit(self: *Renderer) void {
        var layout: sg.VertexLayoutState = .{};
        layout.attrs[shaders.ATTR_shader_pos].format = .FLOAT3;
        layout.attrs[shaders.ATTR_shader_pos].buffer_index = 0;

        layout.attrs[shaders.ATTR_shader_color0].format = .FLOAT4;
        layout.attrs[shaders.ATTR_shader_color0].buffer_index = 0;

        layout.buffers[1].stride = 64;
        layout.buffers[1].step_func = .PER_INSTANCE;
        layout.attrs[shaders.ATTR_shader_model0].format = .FLOAT4;
        layout.attrs[shaders.ATTR_shader_model0].buffer_index = 1;

        layout.attrs[shaders.ATTR_shader_model1].format = .FLOAT4;
        layout.attrs[shaders.ATTR_shader_model1].buffer_index = 1;

        layout.attrs[shaders.ATTR_shader_model2].format = .FLOAT4;
        layout.attrs[shaders.ATTR_shader_model2].buffer_index = 1;

        layout.attrs[shaders.ATTR_shader_model3].format = .FLOAT4;
        layout.attrs[shaders.ATTR_shader_model3].buffer_index = 1;

        self.pip = sg.makePipeline(.{
            .layout = layout,
            .shader = sg.makeShader(shaders.shaderShaderDesc(sg.queryBackend())),
            .index_type = .UINT16,
            .depth = .{
                .compare = .LESS_EQUAL,
                .write_enabled = true,
            },
            .cull_mode = .BACK,
        });

        self.bind.vertex_buffers[0] = self.vertexBuffer;
        self.bind.vertex_buffers[1] = self.instanceBuffer;
        self.bind.index_buffer = self.indexBuffer;
    }

    fn draw(self: *Renderer) void {
        const proj = math.Mat4.persp(60.0, sapp.widthf() / sapp.heightf(), 0.01, 1000.0);
        const vs_params: shaders.VsParams = .{ .vp = math.Mat4.mul(proj, self.view) };
        sg.beginPass(.{ .action = self.passAction, .swapchain = sglue.swapchain() });
        sg.applyPipeline(self.pip);
        sg.applyBindings(self.bind);
        sg.applyUniforms(shaders.UB_vs_params, sg.asRange(&vs_params));
        sg.draw(0, self.indexLength, self.instanceLength);
        sg.endPass();
        sg.commit();
    }

    fn clear(self: *Renderer, color: sg.Color) void {
        self.passAction.colors[0].load_action = .CLEAR;
        self.passAction.colors[0].clear_value = color;
    }
};

const state = struct {
    var rx: f32 = 0.0;
    var renderer: Renderer = undefined;
};

export fn init() void {
    state.renderer = Renderer.init();

    state.renderer.submit();
}

export fn frame() void {
    const dt: f32 = @floatCast(sapp.frameDuration() * 60);

    state.renderer.clear(.{ .r = 0.0, .g = 0.0, .b = 0.0, .a = 0.0 });

    const fps = 1.0 / (dt / 60);
    std.debug.print("FPS: {d:.2}\n", .{fps});

    var instances: [25 * 25 * 25]math.Mat4 = undefined;
    for (0..25) |xIndex| {
        for (0..25) |yIndex| {
            for (0..25) |zIndex| {
                const x: i32 = @intCast(xIndex);
                const y: i32 = @intCast(yIndex);
                const z: i32 = @intCast(zIndex);
                const index = xIndex * 25 * 25 + yIndex * 25 + zIndex;
                instances[index] = math.Mat4.mul(
                    math.Mat4.mul(
                        math.Mat4.identity(),
                        math.Mat4.translate(
                            .{ .x = (@as(f32, @floatFromInt(x)) - 12) * 3, .y = (@as(f32, @floatFromInt(y)) - 12) * 3, .z = (@as(f32, @floatFromInt(z)) - 12) * 3 },
                        ),
                    ),
                    math.Mat4.rotate(state.rx, .{ .x = 0.0, .y = 1.0, .z = 0.0 }),
                );
            }
        }
    }
    state.rx += dt * 1.0;
    state.renderer.addMesh(
        Shapes.Cube(),
        &instances,
    );

    state.renderer.draw();
}

export fn cleanup() void {
    sg.shutdown();
}

pub fn main() void {
    sapp.run(.{
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .window_title = "Sokol Instance Renderer",
        .width = 1280,
        .height = 720,
        .logger = .{ .func = slog.func },
    });
}
