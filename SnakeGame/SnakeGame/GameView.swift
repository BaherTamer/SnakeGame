//
//  GameView.swift
//  SnakeGame
//
//  Created by Baher Tamer on 22/10/2022.
//

import SwiftUI

struct GameView: View {

    @State private var startPosition: CGPoint = .zero
    @State private var isSwipeStarted = true
    @State private var isGameOver = false
    @State private var direction: Direction = .down
    @State private var positions = [CGPoint(x: 0, y: 0)]
    @State private var foodPosition = CGPoint(x: 0, y: 0)

    let snakeSize: CGFloat = 10
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    let minX = UIScreen.main.bounds.minX
    let maxX = UIScreen.main.bounds.maxX
    let minY = UIScreen.main.bounds.minY
    let maxY = UIScreen.main.bounds.maxY

    var body: some View {
        ZStack {
            Color.green.opacity(0.5).ignoresSafeArea()

            ZStack {
                ForEach(0 ..< positions.count, id: \.self) { index in
                    Rectangle()
                        .fill(.indigo)
                        .frame(width: self.snakeSize, height: self.snakeSize)
                        .position(self.positions[index])
                }

                Rectangle()
                    .fill(.red)
                    .frame(width: snakeSize, height: snakeSize)
                    .position(foodPosition)
            }
            .onAppear() {
                self.foodPosition = self.changeRectanglePostion()
                self.positions[0] = self.changeRectanglePostion()
            }

            if self.isGameOver {
                Text("Game Over!")
            }
        }
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    if self.isSwipeStarted {
                        self.startPosition = gesture.location
                        self.isSwipeStarted.toggle()
                    }
                }
                .onEnded { gesture in
                    let xDistance = abs(gesture.location.x - self.startPosition.x)
                    let yDistance = abs(gesture.location.y - self.startPosition.y)

                    if self.startPosition.y < gesture.location.y && yDistance > xDistance {
                        self.direction = .down
                    } else if self.startPosition.y > gesture.location.y && yDistance > xDistance {
                        self.direction = .up
                    } else if self.startPosition.x < gesture.location.x && yDistance < xDistance {
                        self.direction = .left
                    } else if self.startPosition.x > gesture.location.x && yDistance < xDistance {
                        self.direction = .right
                    }

                    self.isSwipeStarted.toggle()
                }
        )
        .onReceive(timer) { _ in
            if !self.isGameOver {
                self.changeDirection()

                if self.positions[0] == self.foodPosition {
                    self.positions.append(self.positions[0])
                    self.foodPosition = self.changeRectanglePostion()
                }
            }
        }
    }

    func changeRectanglePostion() -> CGPoint {
        let rows = Int(maxX/snakeSize)
        let columns = Int(maxY/snakeSize)

        let randomX = Int.random(in: 1 ..< rows) * Int(snakeSize)
        let randomY = Int.random(in: 1 ..< columns) * Int(snakeSize)

        return CGPoint(x: randomX, y: randomY)
    }

    func changeDirection() {
        if self.positions[0].x < minX || self.positions[0].x > maxX && !isGameOver {
            isGameOver.toggle()
        } else if self.positions[0].y < minY || self.positions[0].y > maxY && !isGameOver {
            isGameOver.toggle()
        }

        var previousPosition = positions[0]

        switch direction {
        case .up:
            self.positions[0].y -= snakeSize
        case .down:
            self.positions[0].y += snakeSize
        case .left:
            self.positions[0].x += snakeSize
        case .right:
            self.positions[0].x -= snakeSize
        }

        for index in 1 ..< positions.count {
            let currentPosition = positions[index]
            positions[index] = previousPosition
            previousPosition = currentPosition
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
