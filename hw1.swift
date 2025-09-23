//
//  main.swift
//  HW1
//
//  Created by Иван Топоров on 22.09.2025.
//

import Foundation

// настроечки
let num_rows = 5
let num_snakes = 4
let num_ladders = 3
let height = 4

var board = Array(repeating: " ", count: num_rows*num_rows)
board[0] = ">"
board[board.count-1] = "<"

var current_player_idx = 0
var players = [Int]()

func get_row(pos: Int) -> (Int, Int){
    if pos == 0{
        return (0, num_rows - 1)
    }
    let idx = pos / num_rows
    return (idx * num_rows, (idx + 1) * num_rows - 1)
}

var snakes_heads = [Int]()
var snakes_tails = [Int]()
for _ in 1...num_snakes{
    var snake_haed = Int.random(in: num_rows...board.count - 2)
    while snakes_heads.contains(_: snake_haed)
            || snakes_heads.contains(_: snake_haed + 1)
            || snakes_heads.contains(_: snake_haed - 1)
            || snakes_heads.contains(_: snake_haed + 2)
            || snakes_heads.contains(_: snake_haed - 2){
        snake_haed = Int.random(in: num_rows...board.count - 2)
    }
    //board[snake_haed] = "H"
    snakes_heads.append(snake_haed)
}

for snake_haed in snakes_heads{
    var min_pos = snake_haed-6
    for head in snakes_heads{
        if head != snake_haed && head < snake_haed && head > min_pos{
            min_pos = head + 1
        }
    }
    var snake_tail = Int.random(in: max(1, min_pos)...snake_haed-2)
    while snakes_tails.contains(snake_tail) || snakes_heads.contains(snake_tail) {
        snake_tail = Int.random(in: max(1, min_pos)...snake_haed-2)
    }
    board[snake_haed] = String(snake_tail)
    board[snake_tail] = "S"
    snakes_tails.append(snake_tail)
}

var ladders_tops = [Int]()
var ladders_bottoms = [Int]()

for _ in 1...num_ladders{
    var ladder_top = Int.random(in: num_rows * 2...board.count - 2)
    while ladders_tops.contains(_: ladder_top)
            || ladders_tops.contains(ladder_top - 1)
            || ladders_tops.contains(ladder_top + 1)
            || snakes_heads.contains(_: ladder_top)
            || snakes_tails.contains(_: ladder_top){
        ladder_top = Int.random(in: num_rows * 2...board.count - 2)
    }
    ladders_tops.append(ladder_top)
    //board[ladder_top] = "L"
}

for ladder_top in ladders_tops{
    let (r_s, r_e) = get_row(pos: ladder_top)
    
    var ladder_bottom = Int.random(in: max(1, r_s - num_rows * 1)...r_e - num_rows * 1)
    while ladders_tops.contains(_: ladder_bottom)
            || ladders_bottoms.contains(_: ladder_bottom)
            || snakes_heads.contains(_: ladder_bottom)
            || snakes_tails.contains(_: ladder_bottom){
        ladder_bottom = Int.random(in: max(1, r_s - num_rows * 1)...r_e - num_rows * 1)
    }
    ladders_bottoms.append(ladder_bottom)
    board[ladder_top] = "L"
    board[ladder_bottom] = String(ladder_top)
}

var order = num_rows % 2 == 0

func calc_pos(i: Int, j: Int) -> Int {
    let pos : Int
    if order{
        pos = (num_rows - i) * num_rows - j - 1
    }
    else{
        pos = (num_rows - i - 1) * num_rows + j
    }
    return pos
}

let width = (height + 1) * 2

func print_horizontal(draw_path: Bool = true){
    print("+", terminator: "")
    let idx = order ? 0 : num_rows - 1
    for i in 0...num_rows-1{
        for r in 1...width{
            var sym = "-"
            if draw_path && i == idx && (r != 1 && r != width){
                sym = " "
            }
            print(sym, terminator: "")
        }
        print("+", terminator: "")
    }
    print()
}

func draw_board() {
    // отрисовка доски
    for i in 0...num_rows-1{
        // рисуем верхние малки
        print_horizontal(draw_path: i != 0)
        // рисуем горизонтальные поля
        var line : String = ""
        for h in 1...height{
            line += "|"
            for j in 0...num_rows-1{
                let pos = calc_pos(i: i, j: j)
                let s_val = String(pos)
                let b_val = board[pos]
                for w in 1...width{
                    var fill_char = Character(" ")
                    
                    // отрисовка игроков
                    if h == 1 && w <= players.count && pos == players[w-1]{
                        fill_char = Character(String(w))
                    }
                    
                    // проверка на то, что пора рисовать номер ячейки
                    if h == height{
                        let s_v_pos = s_val.count - width + w - 1
                        if s_v_pos >= 0{
                            let idx = s_val.index(s_val.startIndex, offsetBy: s_v_pos)
                            fill_char = s_val[idx]
                        }
                    }
                    
                    // проверка на печать сивмола с доски
                    if h == (height / 2) + 1{
                        let delta = w - width / 2
                        if delta >= 0 && delta < b_val.count{
                            let idx = b_val.index(b_val.startIndex, offsetBy: delta)
                            fill_char = b_val[idx]
                        }
                    }
                    
                    line += String(fill_char)
                }
                line += "|"
            }
            line += "\n"
        }
        
        print(line, terminator: "")
        order = !order
    }
    print_horizontal(draw_path: false)
    order = num_rows % 2 == 0
}

print("Игра")
print("Введите количество игроков (2 - 6):")

if let start_input = readLine(), var num_players = Int(start_input) {
    if num_players < 2{
        num_players = 2
        print("Количество игроков автоматически установлено на '2'")
    }
    else if num_players > 6{
        num_players = 6
        print("Количество игроков автоматически установлено на '6'")
    }
    players = Array(repeating: 0, count: num_players)
}

draw_board()
var playing = true
while playing{
    print("Ход игрока: \(current_player_idx + 1)")
    let _ = readLine()
    let dice = Int.random(in: 1...6)
    print("Выпало: \(dice) очков")
    let new_pos = players[current_player_idx] + dice
    
    if new_pos >= board.count - 1{
        print("Игрок \(current_player_idx + 1) победил!")
        players[current_player_idx] = board.count - 1
        playing = false
    }
    else if snakes_heads.contains(new_pos){
        let snake_index = snakes_heads.firstIndex(of: new_pos)!
        let snake_tail = snakes_tails[snake_index]
        print("Вы попали на голову змеи! Отправляйтесь на \(snake_tail)")
        players[current_player_idx] = snake_tail
    }
    else if ladders_bottoms.contains(new_pos){
        let ladder_index = ladders_bottoms.firstIndex(of: new_pos)!
        let ladder_top = ladders_tops[ladder_index]
        print("Вы попали на лесенку! Отправляйтесь на \(ladder_top)")
        players[current_player_idx] = ladder_top
    }
    else{
        players[current_player_idx] = new_pos
        print("Новая позиция: \(new_pos)")
    }
    
    draw_board()
    
    current_player_idx += 1
    if current_player_idx >= players.count{
        current_player_idx = 0
    }
}
