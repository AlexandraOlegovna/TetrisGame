//
//  GameViewController.swift
//  TetrisGame
//
//  Created by User on 3/13/17.
//  Copyright © 2017 Alex. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController, SwiftrisDelegate, UIGestureRecognizerDelegate {

    var scene: GameScene!
    
    var swiftris:Swiftris!
    
    var panPointReference:CGPoint?
    
//    override func loadView() {
//        self.view = SKView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Configure the view.
        let skView = view as! SKView
        skView.isMultipleTouchEnabled = false
        
        // Create and configure the scene.
        //scene.nextShapeSize = nextShapePreview.bounds.size
        scene = GameScene(size: skView.bounds.size, header: scoreLabel.bounds.size)
        scene.scaleMode = .aspectFill
        
        scene.tick = didTick
        if (swiftris == nil){
            swiftris = Swiftris()
        }
        
        //render existing blocks
        for block in swiftris.blockArray.array{
            if (block != nil){
                scene.addBlockSprite(block: block!)
            }
        }
        
        swiftris.delegate = self
        swiftris.beginGame()
        
        // Present the scene.
        skView.presentScene(scene)
        
    }
    
//    func 
    
    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    @IBAction func didTap(_ sender: UITapGestureRecognizer) {
        swiftris.rotateShape()
    }
    
    @IBAction func didPan(_ sender: UIPanGestureRecognizer) {
        let currentPoint = sender.translation(in: self.view)
        if let originalPoint = panPointReference {
            if abs(currentPoint.x - originalPoint.x) > (BlockSize * 0.9) {
                if sender.velocity(in: self.view).x > CGFloat(0) {
                    swiftris.moveShapeRight()
                    panPointReference = currentPoint
                } else {
                    swiftris.moveShapeLeft()
                    panPointReference = currentPoint
                }
            }
        } else if sender.state == .began {
            panPointReference = currentPoint
        }
    }
    
    @IBAction func didSwipe(_ sender: UISwipeGestureRecognizer) {
        swiftris.dropShape()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UISwipeGestureRecognizer {
            if otherGestureRecognizer is UIPanGestureRecognizer {
                return true
            }
        } else if gestureRecognizer is UIPanGestureRecognizer {
            if otherGestureRecognizer is UITapGestureRecognizer {
                return true
            }
        }
        return false
    }
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    
    func didTick() {
        swiftris.letShapeFall()
    }
    
    func nextShape() {
        let newShapes = swiftris.newShape()
        guard let fallingShape = newShapes.fallingShape else {
            return
        }
        self.scene.addPreviewShapeToScene(shape: newShapes.nextShape!) {}
        self.scene.movePreviewShape(shape: fallingShape) {
            self.view.isUserInteractionEnabled = true
            self.scene.startTicking()
        }
    }
    
    func gameDidBegin(swiftris: Swiftris) {
        scoreLabel.text = "\(swiftris.score)"
        
        // The following is false when restarting a new game
        if swiftris.nextShape != nil && swiftris.nextShape!.blocks[0].sprite == nil {
            scene.addPreviewShapeToScene(shape: swiftris.nextShape!) {
                self.nextShape()
            }
        } else {
            nextShape()
        }
    }
    
    func gameDidEnd(swiftris: Swiftris) {
        view.isUserInteractionEnabled = false
        scene.stopTicking()
        
        
        scene.animateCollapsingLines(linesToRemove: swiftris.removeAllBlocks(), fallenBlocks: swiftris.removeAllBlocks()) {
//            swiftris.beginGame()
        }
        let controller = storyboard?.instantiateViewController(withIdentifier: "Lose") as! LoseViewController
        controller.currentScore = swiftris.score
        present(controller, animated: false, completion: nil)
    }

    
    func gameShapeDidDrop(swiftris: Swiftris) {
        scene.stopTicking()
        scene.redrawShape(shape: swiftris.fallingShape!) {
            swiftris.letShapeFall()
        }
        
    }
    
    func gameShapeDidLand(swiftris: Swiftris) {
        scene.stopTicking()
        
        self.view.isUserInteractionEnabled = false
        let removedLines = swiftris.removeCompletedLines()
        if removedLines.linesRemoved.count > 0 {
            self.scoreLabel.text = "\(swiftris.score)"
            scene.animateCollapsingLines(linesToRemove: removedLines.linesRemoved, fallenBlocks:removedLines.fallenBlocks) {
                // #11
                self.gameShapeDidLand(swiftris: swiftris)
            }
        } else {
            nextShape()
        }
    }
    

    func gameShapeDidMove(swiftris: Swiftris) {
        scene.redrawShape(shape: swiftris.fallingShape!) {}
    }
    
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var pauseView: UIView!
    
    @IBOutlet var panG: UIPanGestureRecognizer!
    @IBOutlet var swipeG: UISwipeGestureRecognizer!
    @IBOutlet var tapG: UITapGestureRecognizer!
    @IBAction func clickPause(_ sender: UIButton) {
        header.isHidden = true
        pauseView.isHidden = false
        scene.isPaused = true
        scene.stopTicking()
        panG.isEnabled = false;
        swipeG.isEnabled = false;
        tapG.isEnabled = false;
    }
    
    @IBAction func continueClick(_ sender: UIButton) {
        header.isHidden = false
        pauseView.isHidden = true
        scene.isPaused = false
        scene.startTicking()
        panG.isEnabled = true;
        swipeG.isEnabled = true;
        tapG.isEnabled = true;
    }
    
    enum UserDefaultsKeys: String {
        case blockCategory
    }
    
    @IBAction func menuClick(_ sender: UIButton) {
        let def = UserDefaults.standard
//        let x:(Int, Int) = (1,2)
        var boardScheme = [String]()
        for block in swiftris.blockArray.array{
            if (block != nil){
                boardScheme.append("\(block!.column) " +  "\(block!.row) " + "\(block!.color.rawValue)")
            }
        }
        
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: boardScheme)
        def.set(encodedData, forKey: "blockArray")
        def.set(self.swiftris.score, forKey: "currentScore")
        
        def.synchronize()
        
        let controller = storyboard?.instantiateViewController(withIdentifier: "Start") as! StartViewController
        present(controller, animated: false, completion: nil)
    }
    
}
