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
        let controller = storyboard?.instantiateViewController(withIdentifier: "Game") as! GameViewController
        present(controller, animated: false, completion: nil)
    }
    
    @IBAction func continueClick(_ sender: UIButton) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "Game") as! GameViewController
        //        let def = UserDefaults.standard
        //        def.set(self.swiftris.blockArray, forKey:"array")
        
        
        
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
