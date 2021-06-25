//
//  GameViewController.swift
//  XO-game
//
//  Created by Evgeny Kireev on 25/02/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    
    @IBOutlet var gameboardView: GameboardView!
    @IBOutlet var firstPlayerTurnLabel: UILabel!
    @IBOutlet var secondPlayerTurnLabel: UILabel!
    @IBOutlet var winnerLabel: UILabel!
    @IBOutlet var restartButton: UIButton!
    
    var gameType: GameType?
    
    private var counter: Int = 0
    
    private let gameBoard = Gameboard()
    private lazy var referee = Referee(gameboard: gameBoard)
    
    private var currentState: GameState! {
        didSet {
            currentState.begin()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstPlayerTurn()
        
        gameboardView.setAllPossiblePositions()
        
        gameboardView.onSelectPosition = { [weak self] position in
            guard let self = self else { return }
            
            self.currentState.addSign(at: position)
            
            if self.currentState.isMoveCompleted {
                self.nextPlayerTurn()
            }
        }
    }
    
    func firstPlayerTurn() {
        let firstPlayer: Player = .first
        currentState = getPlayerState(player: firstPlayer)
    }
    
    func nextPlayerTurn() {
        self.counter += 1
        
        if let winner = referee.determineWinner() {
            Logger.shared.log(action: .gameFinish(winner: winner))
            currentState = GameEndState(winnerPlayer: winner, gameViewController: self)
            return
        }
        
        if counter >= 9 {
            Logger.shared.log(action: .gameFinish(winner: nil))
            currentState = GameEndState(winnerPlayer: nil, gameViewController: self)
        }
        
        if let playerState = currentState as? PlayerState {
            let nextPlayer = playerState.player.next
            currentState = getPlayerState(player: nextPlayer)
        }
    }
    
    func getPlayerState(player: Player) -> GameState? {
        if player == .first || gameType == .twoPlayers {
            return PlayerGameState(player: player,
                                   gameViewController: self,
                                   gameBoard: gameBoard,
                                   gameBoardView: gameboardView,
                                   markViewPrototype: player.markViewPrototype)
            
        }
        
        if player == .second && gameType == .withComputerGame {
            return BotGameState(player: player,
                                gameViewController: self,
                                gameBoard: gameBoard,
                                gameBoardView: gameboardView,
                                markViewPrototype: player.markViewPrototype)
        }
        
        return nil
    }
    
    @IBAction func restartButtonTapped(_ sender: UIButton) {
        Logger.shared.log(action: .restartGame)
        gameboardView.clear()
        gameBoard.clear()
        counter = 0
        
        firstPlayerTurn()
    }
}

