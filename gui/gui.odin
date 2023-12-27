package gui

import rl "vendor:raylib"
import "core:fmt"

@(private)
UiState :: struct {
    mousePos: rl.Vector2,
    mouseDown: bool,
    hotItem: int,
    activeItem: int
}

State: UiState

beginGui :: proc() {
    using rl
    using State

    mousePos = GetMousePosition()
    mouseDown = IsMouseButtonDown(MouseButton.LEFT);
    hotItem = 0
}


endGui :: proc() {
    using rl
    using State

    if !mouseDown {
        activeItem = 0
    } else {
        if activeItem == 0 {
           activeItem = -1 
        }
    }
}

row :: proc(dimensoes: ^rl.Rectangle, thickness: f32) -> rl.Rectangle {
   using rl
   
   row := dimensoes^
   row.height = thickness
   dimensoes.y += thickness 
   dimensoes.height -= thickness
   return row
}


column :: proc(dimensoes: ^rl.Rectangle, thickness: f32) -> rl.Rectangle {
   using rl
   
   column := dimensoes^
   column.width = thickness
   dimensoes.x += thickness 
   dimensoes.width -= thickness
   return column
}

button :: proc(dimensoes: rl.Rectangle, text: cstring) -> bool {
    using rl
    using State
    id: int = int(dimensoes.x + dimensoes.y + dimensoes.height + dimensoes.width)
    if CheckCollisionPointRec(mousePos, dimensoes) {
        hotItem = id
        if (activeItem == 0 && mouseDown) {
            activeItem = id
        }
    }

    DrawRectangleRec(dimensoes, GRAY)
    if hotItem == id {
        DrawRectangleLinesEx(dimensoes, 1, RED)
        if activeItem == id {
            DrawRectangleLinesEx(dimensoes, 2, RED)
        }
    }

    if !mouseDown && hotItem == id && activeItem == id do return true
    
    text_size := i32(dimensoes.height) / 2
    text_length := MeasureText(text, text_size)
    DrawText(text, i32(dimensoes.x) + ((i32(dimensoes.width) - text_length) / 2), i32(dimensoes.y) + ((i32(dimensoes.height) - text_size) / 2), text_size, BLACK) 
    

    return false
}

display :: proc(dimensoes: rl.Rectangle, text: cstring) {
    using rl
    using State
    id: int = int(dimensoes.x + dimensoes.y + dimensoes.height + dimensoes.width)
    if CheckCollisionPointRec(mousePos, dimensoes) {
        hotItem = id
        if (activeItem == 0 && mouseDown) {
            activeItem = id
        }
    }

    DrawRectangleRec(dimensoes, GRAY)
    if hotItem == id {
        DrawRectangleLinesEx(dimensoes, 1, RED)
    }

    text_size := i32(dimensoes.height) / 2
    text_length := MeasureText(text, text_size)
    DrawText(text, i32(dimensoes.x) + ((i32(dimensoes.width) - text_length) / 2), i32(dimensoes.y) + ((i32(dimensoes.height) - text_size) / 2), text_size, BLACK) 
    
}

slider :: proc(dimensoes: rl.Rectangle, max: f32, current_value: ^f32) {
    using rl
    using State

    id: int = int(dimensoes.x + dimensoes.y + dimensoes.height + dimensoes.width)

    Orientation :: enum {
        Vertical,
        Horizontal,
    }
    
    orientation :=  Orientation.Vertical if dimensoes.height > dimensoes.width else Orientation.Horizontal 

    
    paddle := dimensoes

    paddle_size := dimensoes.height / max if orientation == .Vertical else dimensoes.width / max
    paddle_size *= 2
    paddle_position := current_value^ * (paddle_size / 2)

    rastrear_cursor := false

    if orientation == .Vertical {
       paddle.height = paddle_size 
       paddle.y += dimensoes.height
       paddle.y -= paddle_position
    } else {
       paddle.width = paddle_size 
       paddle.x += paddle_position
    }

    if CheckCollisionPointRec(mousePos, dimensoes) {
        hotItem = id
        if mouseDown {
            activeItem = id
        }
    }
    

    if hotItem == id {
        DrawRectangleRec(dimensoes, GREEN)
        DrawRectangleLinesEx(paddle, 1, RED)
        paddle.x += 1
        paddle.y += 1
        paddle.width -= 2
        paddle.height -= 2
        DrawRectangleRec(paddle, GRAY)
        if activeItem == id {
           rastrear_cursor = true 
        }
    } else {

        DrawRectangleRec(dimensoes, GREEN)
        DrawRectangleRec(paddle, GRAY)
    }

    if hotItem == id && activeItem == id {

        //proporção para descobrir o valor atual pela posicao do mouse
        if orientation == .Vertical {
            current_value^ = (max * ((dimensoes.height + dimensoes.y) - mousePos.y) / dimensoes.height)
        } else {
            current_value^ = (max * (mousePos.x - dimensoes.x) / dimensoes.width)
        }
    }

}

