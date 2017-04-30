//
//  StartViewController.swift
//  TetrisGame
//
//  Created by User on 4/29/17.
//  Copyright © 2017 Alex. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {

    
    
    @IBAction func startClick(_ sender: UIButton) {
        startNewGame()
    }
    
    func startNewGame(){
        let controller = storyboard?.instantiateViewController(withIdentifier: "Game") as! GameViewController
        present(controller, animated: false, completion: nil)
    }
    
    
    @IBAction func continueClick(_ sender: UIButton) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "Game") as! GameViewController
        let def = UserDefaults.standard
        var boardScheme = [String]()
        if let decoded = def.object(forKey: "blockArray") as? NSData {
            let array = NSKeyedUnarchiver.unarchiveObject(with: decoded as Data) as! [String]
            boardScheme = array
        }
        let score = def.integer(forKey: "currentScore")
        guard (score != 0) || (!boardScheme.isEmpty) else
        {
            return startNewGame()
        }
        
        controller.swiftris = Swiftris()
        controller.swiftris.score = score
        
        controller.swiftris.blockArray = Array2D<Block>(columns: NumColumns, rows: NumRows)
        for stringBlock in boardScheme{
            let values = stringBlock.components(separatedBy: " ").flatMap { Int($0.trimmingCharacters(in: .whitespaces)) }
            let block = Block(column: values[0], row: values[1], color: BlockColor(rawValue: values[2])!)
            controller.swiftris.blockArray[values[0], values[1]] = block
        }
        
        
        present(controller, animated: false, completion: nil)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}
