//
//  LoseViewController.swift
//  TetrisGame
//
//  Created by User on 4/30/17.
//  Copyright © 2017 Alex. All rights reserved.
//

import UIKit

class LoseViewController: UIViewController {

    var currentScore: Int!
    var bestScore: Int!
    
    @IBAction func menuClick(_ sender: UIButton) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "Start") as! StartViewController
        present(controller, animated: false, completion: nil)
    }
    
    @IBOutlet weak var currentScoreLabel: UILabel!
    @IBOutlet weak var bestScoreLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let def = UserDefaults.standard
        bestScore = def.integer(forKey: "bestScore")
        if (currentScore > bestScore){
            bestScore = currentScore
            def.set(bestScore, forKey: "bestScore")
        }
        
        currentScoreLabel.text = "\(currentScore!)"
        bestScoreLabel.text = "\(bestScore!)"
        
        //delete savings
        def.removeObject(forKey: "currentScore")
        def.removeObject(forKey: "blockArray")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
