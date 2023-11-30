package main

import "core:fmt"
import glm "core:math/linalg/glsl"
import "core:strings"
import "core:time"

import gl "vendor:OpenGL"
import SDL "vendor:sdl2"

main :: proc() {
	WINDOW_WIDTH :: 800
	WINDOW_HEIGHT :: 600

	SDL.Init({.VIDEO, .EVENTS})
	defer SDL.Quit()

	SDL.GL_SetAttribute(SDL.GLattr.CONTEXT_MAJOR_VERSION, 3)
	SDL.GL_SetAttribute(SDL.GLattr.CONTEXT_MINOR_VERSION, 3)
	SDL.GL_SetAttribute(SDL.GLattr.CONTEXT_PROFILE_MASK, gl.CONTEXT_CORE_PROFILE_BIT)
	SDL.GL_SetAttribute(SDL.GLattr.CONTEXT_FLAGS, gl.CONTEXT_COMPATIBILITY_PROFILE_BIT)

	window := SDL.CreateWindow(
		"Odin SDL2 Demo",
		SDL.WINDOWPOS_UNDEFINED,
		SDL.WINDOWPOS_UNDEFINED,
		WINDOW_WIDTH,
		WINDOW_HEIGHT,
		{.OPENGL, .SHOWN},
	)
	if window == nil {
		fmt.eprintln("Failed to create window")
		return
	}
	defer SDL.DestroyWindow(window)

	gl_context := SDL.GL_CreateContext(window)
	defer SDL.GL_DeleteContext(gl_context)
	

	SDL.GL_MakeCurrent(window, gl_context)
	gl.load_up_to(3, 3, SDL.gl_set_proc_address)

	SDL.GL_SetSwapInterval(1)
	gl.Viewport(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)

	vertices := [?]f32 {
		-0.5, -0.5, 0,
		0.5, -0.5, 0,
		0, 0.5, 0
	}

	shader_program, ok := gl.load_shaders_source(vertex_source, fragment_source)
	if !ok {
		fmt.eprintln("Failed to compile and link shaders into a program.")
		return
	}

	vbo, vao: u32
	gl.GenVertexArrays(1, &vao)
	gl.GenBuffers(1, &vbo)

	gl.BindVertexArray(vao)
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
	gl.BufferData(gl.ARRAY_BUFFER, size_of(f32) * len(vertices), &vertices, gl.STATIC_DRAW)
	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 3 * size_of(f32), 0)
	gl.EnableVertexAttribArray(0)
	
	// Reset the buffers
	gl.BindBuffer(gl.ARRAY_BUFFER, 0)
	gl.BindVertexArray(0)

	for {
		if !process_events() {
			break
		}

		gl.ClearColor(0.2, 0.3, 0.3, 1.0)
		gl.Clear(gl.COLOR_BUFFER_BIT)
		
		gl.UseProgram(shader_program)
		gl.BindVertexArray(vao)
		gl.DrawArrays(gl.TRIANGLES, 0, 3)

		SDL.GL_SwapWindow(window)
	}
}

process_events :: proc() -> bool {
	event: SDL.Event
	for SDL.PollEvent(&event) {
		// #partial switch tells the compiler not to error if every case is not present
		#partial switch event.type {
		case .KEYDOWN:
			#partial switch event.key.keysym.sym {
			case .ESCAPE:
				// labelled control flow
				return false
			}
		case .QUIT:
			// labelled control flow
			return false
		}
	}

	return true
}


vertex_source := `#version 330 core

layout(location = 0) in vec3 aPos;

void main() {
    gl_Position = vec4(aPos, 1.0);
}
`

fragment_source := `#version 330 core

out vec4 FragColor;

void main() {
	FragColor = vec4(1.0, 0.5, 0.2, 1.0);
}
`
