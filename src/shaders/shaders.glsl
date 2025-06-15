@header const m = @import("../math.zig")
@ctype mat4 m.Mat4

@vs vs

in vec3 pos;
in vec4 color0;

in vec4 model0;
in vec4 model1;
in vec4 model2;
in vec4 model3;

layout(binding = 0) uniform vs_params {
	mat4 vp;
};

out vec4 color;

void main() {
	mat4 model = mat4(model0, model1, model2, model3);
	gl_Position = vp * model * vec4(pos, 1.0);
	color = color0;
}

@end

@fs fs

in vec4 color;

out vec4 fragColor;

void main() {
	fragColor = color;
}

@end

@program shader vs fs
