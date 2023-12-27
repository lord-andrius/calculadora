package main

import "core:fmt"
import "core:strings"
import rl "vendor:raylib"
import "gui"
import "core:math"
import "core:strconv"

LARGURA :: 480
ALTURA :: 690

main :: proc() {
    using rl
    using gui

    Operations :: enum {
        Clear,
        None,
        NumberEntered,
        Sum,
        Subtraction,
        Division, 
        Multiplication,
        Dot,
        Result
    }

    InitWindow(LARGURA, ALTURA, "GUI")
    defer CloseWindow()

    accumulator: f32 = 0
    painel_builder : strings.Builder
    current_op: Operations = .None
    previous_op: Operations = .None
    number_input := 0
    first_op := true

    strings.builder_init_len(&painel_builder, 0)
    defer delete(painel_builder.buf)

    strings.write_string(&painel_builder, "00.00\x00") 

    should_clean_painel := true

    for !WindowShouldClose() {
        screen_rectangle := Rectangle{width = LARGURA, height = ALTURA}
        BeginDrawing()
        ClearBackground(WHITE)
        beginGui()
        display(row(&screen_rectangle, 150), cstring(raw_data(painel_builder.buf)))
        tamanho_linha := screen_rectangle.height / 5
        tamanho_botao := screen_rectangle.width / 4

        primeira_linha := row(&screen_rectangle, tamanho_linha)  
        {
            switch {
                case button(column(&primeira_linha, tamanho_botao), "7"):
                    current_op = .NumberEntered
                    number_input = 7
                case button(column(&primeira_linha, tamanho_botao), "8"):
                     current_op = .NumberEntered
                     number_input = 8
                case button(column(&primeira_linha, tamanho_botao), "9"):
                    current_op = .NumberEntered
                    number_input = 9
                case button(column(&primeira_linha, tamanho_botao), "-"):
                    current_op = .Subtraction
            }
        }

        segunda_linha := row(&screen_rectangle, tamanho_linha)
        {
            switch {
                case button(column(&segunda_linha, tamanho_botao), "4"):
                    current_op = .NumberEntered
                    number_input = 4
                case button(column(&segunda_linha, tamanho_botao), "5"):
                    current_op = .NumberEntered
                    number_input = 5
                case button(column(&segunda_linha, tamanho_botao), "6"):
                    current_op = .NumberEntered
                    number_input = 6
                case button(column(&segunda_linha, tamanho_botao), "+"):
                    current_op = .Sum
            }
        }

        terceira_linha := row(&screen_rectangle, tamanho_linha)
        {
            switch {
                case button(column(&terceira_linha, tamanho_botao), "1"):
                    current_op = .NumberEntered
                    number_input = 1
                case button(column(&terceira_linha, tamanho_botao), "2"):
                    current_op = .NumberEntered
                    number_input = 2
                case button(column(&terceira_linha, tamanho_botao), "3"):
                    current_op = .NumberEntered
                    number_input = 3
                case button(column(&terceira_linha, tamanho_botao), "X"):
                    current_op = .Multiplication
            }
        }

        quarta_linha := row(&screen_rectangle, tamanho_linha)
        {
            switch {
                case button(column(&quarta_linha, tamanho_botao), "0"):
                    current_op = .NumberEntered
                    number_input = 0
                case button(column(&quarta_linha, tamanho_botao), "."):
                    current_op = .Dot
                case button(column(&quarta_linha, tamanho_botao), "="):
                    current_op = .Result
                case button(column(&quarta_linha, tamanho_botao), "/"):
                    current_op = .Division
            }
        }

        quinta_linha := row(&screen_rectangle, tamanho_linha)
        if (button(quinta_linha, "Limpar")) {
            current_op = .Clear
        }


        #partial switch current_op {
            case .NumberEntered:
                if should_clean_painel {
                    strings.builder_reset(&painel_builder)
                    fmt.sbprintf(&painel_builder, "\x00")
                    should_clean_painel = false
                }
                if strings.builder_len(painel_builder) != 0 {
                    strings.pop_byte(&painel_builder)
                    fmt.sbprintf(&painel_builder, "%d\x00", number_input)
                }
                current_op = .None
            case .Dot:
                if !should_clean_painel && strings.contains(strings.to_string(painel_builder), ".") == false {
                    strings.pop_byte(&painel_builder)
                    fmt.sbprintf(&painel_builder, ".\x00")
                }
            case .Clear:
                    strings.builder_reset(&painel_builder)
                    fmt.sbprintf(&painel_builder, "\x00")
                    should_clean_painel = true
                    first_op = true
                    accumulator = 0
            case .Sum:
                if !should_clean_painel && strings.builder_len(painel_builder) > 1 {
                    accumulator += strconv.parse_f32(string(painel_builder.buf[0:strings.builder_len(painel_builder) - 1])) or_else 0
                    strings.builder_reset(&painel_builder)
                    fmt.sbprintf(&painel_builder, "%.2f\x00", accumulator) 
                    should_clean_painel = true
                    previous_op = .Sum
                } else if previous_op == .Result {
                    strings.builder_reset(&painel_builder)
                    fmt.sbprintf(&painel_builder, "\x00", accumulator)
                    previous_op = .Sum
                }

                case .Subtraction:
                if first_op {
                    accumulator += strconv.parse_f32(string(painel_builder.buf[0:strings.builder_len(painel_builder) - 1])) or_else 0
                    first_op = false
                    fmt.sbprintf(&painel_builder, "%.2f\x00", accumulator)
                    should_clean_painel = true
                    previous_op = .Subtraction

                } else if !should_clean_painel && strings.builder_len(painel_builder) > 1 {
                    
                    accumulator -= strconv.parse_f32(string(painel_builder.buf[0:strings.builder_len(painel_builder) - 1])) or_else 0
                    strings.builder_reset(&painel_builder)
                    fmt.sbprintf(&painel_builder, "%.2f\x00", accumulator)
                    should_clean_painel = true
                    previous_op = .Subtraction
                } else if previous_op == .Result {
                    strings.builder_reset(&painel_builder)
                    fmt.sbprintf(&painel_builder, "\x00", accumulator)
                    previous_op = .Subtraction
                }

            case .Multiplication:
                if first_op {
                    accumulator += strconv.parse_f32(string(painel_builder.buf[0:strings.builder_len(painel_builder) - 1])) or_else 0
                    first_op = false
                    fmt.sbprintf(&painel_builder, "%.2f\x00", accumulator)
                    should_clean_painel = true
                    previous_op = .Multiplication
                }else if !should_clean_painel  && strings.builder_len(painel_builder) > 1 {
                    accumulator *= strconv.parse_f32(string(painel_builder.buf[0:strings.builder_len(painel_builder) - 1])) or_else 0
                    strings.builder_reset(&painel_builder)
                    fmt.sbprintf(&painel_builder, "%.2f\x00", accumulator)
                    should_clean_painel = true
                    previous_op = .Multiplication
                } else if previous_op == .Result {
                    strings.builder_reset(&painel_builder)
                    fmt.sbprintf(&painel_builder, "\x00", accumulator)
                    previous_op = .Subtraction
                }
            case .Division:
                if first_op {
                    accumulator += strconv.parse_f32(string(painel_builder.buf[0:strings.builder_len(painel_builder) - 1])) or_else 0
                    first_op = false
                    fmt.sbprintf(&painel_builder, "%.2f\x00", accumulator)
                    should_clean_painel = true
                    previous_op = .Division
                }
                else if !should_clean_painel && strings.builder_len(painel_builder) > 1 {
                    accumulator /= strconv.parse_f32(string(painel_builder.buf[0:strings.builder_len(painel_builder) - 1])) or_else 0
                    strings.builder_reset(&painel_builder)
                    fmt.sbprintf(&painel_builder, "%.2f\x00", accumulator)
                    should_clean_painel = true
                    previous_op = .Division
                } else if previous_op == .Result {
                    strings.builder_reset(&painel_builder)
                    fmt.sbprintf(&painel_builder, "\x00", accumulator)
                    previous_op = .Subtraction
                }
            case .Result:
                if !should_clean_painel && previous_op != .Result{
                     painel_number := strconv.parse_f32(string(painel_builder.buf[0:strings.builder_len(painel_builder) - 1])) or_else 0
                     #partial switch previous_op {
                        case .Sum:
                            accumulator += painel_number
                        case .Subtraction:
                            accumulator -= painel_number
                        case .Multiplication:
                            accumulator *= painel_number
                        case .Division:
                            accumulator /= painel_number
                     }
                     strings.builder_reset(&painel_builder)
                     fmt.sbprintf(&painel_builder, "%.2f\x00", accumulator)
                     previous_op = .Result
                     should_clean_painel = true
                }
        }

        endGui()
        EndDrawing()
    }
}
