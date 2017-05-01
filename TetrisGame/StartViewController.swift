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
        let def = UserDefaults.standard
        //delete savings
        def.removeObject(forKey: "currentScore")
        def.removeObject(forKey: "blockArray")
        
        let controller = storyboard?.instantiateViewController(withIdentifier: "Game") as! GameViewController
        present(controller, animated: false, completion: nil)
    }
    
    
    @IBAction func continueClick(_ sender: UIButton) {
        
        let controller = storyboard?.instantiateViewController(withIdentifier: "Game") as! GameViewController
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
    
    var boardScheme = [String]()
    var score = 0
    
    @IBOutlet weak var continueButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        continueButton.setTitleColor(.green, for: .normal)
        continueButton.setTitleColor(.gray, for: .disabled);
        
        let def = UserDefaults.standard
        
        if let decoded = def.object(forKey: "blockArray") as? NSData {
            let array = NSKeyedUnarchiver.unarchiveObject(with: decoded as Data) as! [String]
            boardScheme = array
        }
        score = def.integer(forKey: "currentScore")
        continueButton.isEnabled = !((score == 0) && (boardScheme.isEmpty))

    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}
