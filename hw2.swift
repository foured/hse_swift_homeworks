//
//  main.swift
//  HW2
//
//  Created by Иван Топоров on 02.10.2025.
//

import Foundation

let field_size = 5
let cell_height = 5

let num_cells_to_win = field_size

let cell_width = (cell_height + 1) * 2

var field = Array(repeating: " ", count: field_size * field_size)


enum PlayMode{
    case Coop
    case AI
}

var play_mode = PlayMode.AI

func print_horizontal(){
    print("+", terminator: "")
    for _ in 1...field_size{
        for _ in 1...cell_width{
            print("-", terminator: "")
        }
        print("+", terminator: "")
    }
    print()
}

func print_field() {
    
    for p1 in 0...field_size-1{
        print_horizontal()
        var line = ""
        for h in 0...cell_height-1{
            line += "|"
            for p2 in 0...field_size-1{
                let pos = p1 * field_size + p2
                let pos_str = String(pos+1)
                for w in 0...cell_width-1{
                    if h == (cell_height) / 2 && w == (cell_width + 1) / 2{
                        line += field[pos]
                    }
                    else{
                        if h == cell_height-1{
                            let id_offset = w + pos_str.count - cell_width
                            if(id_offset >= 0){
                                let idx = pos_str.index(pos_str.startIndex, offsetBy: id_offset)
                                line += String(pos_str[idx])
                            }
                            else{
                                line += " "
                            }
                        }
                        else{
                            line += " "
                        }
                    }
                }
                line += "|"
            }
            print(line)
            line = ""
        }
    }
    print_horizontal()
}

func check_winner() -> Bool {
    // Проверка строк
    for row in 0..<field_size {
        for col in 0...(field_size - num_cells_to_win) {
            var won = true
            let startPos = row * field_size + col
            let firstSymbol = field[startPos]

            if firstSymbol == " " {
                continue
            }

            for k in 1..<num_cells_to_win {
                let pos = startPos + k
                if field[pos] != firstSymbol {
                    won = false
                    break
                }
            }

            if won {
                return true
            }
        }
    }

    // Проверка столбцов
    for col in 0..<field_size {
        for row in 0...(field_size - num_cells_to_win) {
            var won = true
            let startPos = row * field_size + col
            let firstSymbol = field[startPos]

            if firstSymbol == " " {
                continue
            }

            for k in 1..<num_cells_to_win {
                let pos = startPos + k * field_size
                if field[pos] != firstSymbol {
                    won = false
                    break
                }
            }

            if won {
                return true
            }
        }
    }

    // Проверка диагонали "\"
    for row in 0...(field_size - num_cells_to_win) {
        for col in 0...(field_size - num_cells_to_win) {
            var won = true
            let startPos = row * field_size + col
            let firstSymbol = field[startPos]

            if firstSymbol == " " {
                continue
            }

            for k in 1..<num_cells_to_win {
                let pos = startPos + k * (field_size + 1)
                if field[pos] != firstSymbol {
                    won = false
                    break
                }
            }

            if won {
                return true
            }
        }
    }

    // Проверка диагонали "/"
    for row in 0...(field_size - num_cells_to_win) {
        for col in (num_cells_to_win-1)..<field_size {
            var won = true
            let startPos = row * field_size + col
            let firstSymbol = field[startPos]

            if firstSymbol == " " {
                continue
            }

            for k in 1..<num_cells_to_win {
                let pos = startPos + k * (field_size - 1)
                if field[pos] != firstSymbol {
                    won = false
                    break
                }
            }

            if won {
                return true
            }
        }
    }

    return false
}


func start_game(){
    print_field()
    var moving_first = true
    game_loop: while true {
        var free_cells = [Int]();
        for i in 0...field.count-1{
            if field[i] == " "{
                free_cells.append(i + 1)
            }
        }
        
        if (play_mode == .Coop) || (play_mode == .AI && moving_first){
            print("Ход игрока: \(moving_first ? "1" : "2"). Введите ячейку \(free_cells).");
            var int_input: Int
            while true {
                if let input = readLine(), let num = Int(input), free_cells.contains(num) {
                    int_input = num
                    break
                } else {
                    print("Некорректный ввод. Введите число из списка \(free_cells): ")
                }
            }
            
            field[int_input - 1] = moving_first ? "X" : "O"
        }
        else{
            print("Ход компьютера")
            var made_move = false
            // пытается выиграть
            for fc in free_cells{
                field[fc-1] = "O"
                if check_winner(){
                    made_move = true
                    break
                }
                else{
                    field[fc-1] = " "
                }
            }
            
            //пытается защититься
            if !made_move{
                for fc in free_cells{
                    field[fc-1] = "X"
                    if check_winner(){
                        field[fc-1] = "O"
                        made_move = true
                        break
                    }
                    else{
                        field[fc-1] = " "
                    }
                }
            }
            
            // рандомный ход
            if !made_move {
                field[free_cells.randomElement()! - 1] = "O"
            }
        }
        
        print_field()
        if check_winner(){
            print("Игоок \(moving_first ? "1" : "2") победил!")
            break game_loop
        }
        moving_first = !moving_first
    }
}

print("Игра")
print("Играть с игроком? : 1 (иначе с компьютером):")

if let start_input = readLine(){
    play_mode = start_input == "1" ? .Coop : .AI
    start_game()
}
