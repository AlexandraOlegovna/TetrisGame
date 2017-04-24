//
//  GameScene.swift
//  TetrisGame
//
//  Created by User on 3/13/17.
//  Copyright © 2017 Alex. All rights reserved.
//

import SpriteKit
import GameplayKit

var BlockSize:CGFloat = 20.0

let TickLengthLevelOne = TimeInterval(600)

class GameScene: SKScene {
    
    let gameLayer = SKNode()
    let shapeLayer = SKNode()
    var LayerPosition = CGPoint(x: 0, y: 0)
    var nextShapeSize = CGSize(width: 0, height: 0)
    
    var tick:(() -> ())?
    var tickLengthMillis = TickLengthLevelOne
    var lastTick:NSDate?

    var textureCache = Dictionary<String, SKTexture>()
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoder not supported")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
    }
    
    convenience init(size: CGSize, header: CGSize) {
        self.init(size: size)
        BlockSize = (size.width) / CGFloat(NumColumns + 5)
        LayerPosition = CGPoint(x: 6, y: -header.height / 2 - 10)
        //print(header.height)
        //print(size.height)
        
        anchorPoint = CGPoint(x: 0, y: 1.0)
        
//        let background = SKSpriteNode(imageNamed: "background.png")
//        background.position = CGPoint(x: 0, y: 0)
//        background.anchorPoint = CGPoint(x: 0, y: 1.0)
//        addChild(background)
        
        addChild(gameLayer)
        
        let gameBoardTexture = SKTexture(imageNamed: "gameboard.png")
        let gameBoard = SKSpriteNode(texture: gameBoardTexture, size: CGSize(width: BlockSize * CGFloat(NumColumns), height: BlockSize * CGFloat(NumRows)))
        gameBoard.anchorPoint = CGPoint(x:0, y:1.0)
        gameBoard.position = LayerPosition
//
        
        shapeLayer.position = LayerPosition
        shapeLayer.addChild(gameBoard)
        gameLayer.addChild(shapeLayer)
        
        
//        CGPoint mypositionInScene 
        //print(gameLayer.position)
        //print(shapeLayer.position)
        
//        run(SKAction.repeatForever(SKAction.playSoundFileNamed("theme.mp3", waitForCompletion: true)))
    }
    
    func playSound(sound:String) {
        run(SKAction.playSoundFileNamed(sound, waitForCompletion: false))
    }
    
    
    override func update(_ currentTime: CFTimeInterval) {
        guard let lastTick = lastTick else {
            return
        }
        let timePassed = lastTick.timeIntervalSinceNow * -1000.0
        if timePassed > tickLengthMillis {
            self.lastTick = NSDate()
            tick?()
        }
    }
    
    func startTicking() {
        lastTick = NSDate()
    }
    
    func stopTicking() {
        lastTick = nil
    }
    
    func pointForColumn(column: Int, row: Int) -> CGPoint {
        let x = LayerPosition.x + (CGFloat(column) * BlockSize) + (BlockSize / 2)
        let y = LayerPosition.y - ((CGFloat(row) * BlockSize) + (BlockSize / 2))
        return CGPoint(x: x, y: y)
    }
    
    func addPreviewShapeToScene(shape:Shape, completion:@escaping () -> ()) {
        for block in shape.blocks {
            var texture = textureCache[block.spriteName]
            if texture == nil {
                texture = SKTexture(imageNamed: block.spriteName)
                textureCache[block.spriteName] = texture
            }
            let sprite = SKSpriteNode(texture: texture, size: CGSize(width: BlockSize, height: BlockSize))
            
            sprite.position = pointForColumn(column: block.column, row:block.row - 2)
            shapeLayer.addChild(sprite)
            block.sprite = sprite
            
            // Animation
            sprite.alpha = 0

            let moveAction = SKAction.move(to: pointForColumn(column: block.column, row: block.row), duration: TimeInterval(0.2))
            moveAction.timingMode = .easeOut
            let fadeInAction = SKAction.fadeAlpha(to: 0.7, duration: 0.4)
            fadeInAction.timingMode = .easeOut
            sprite.run(SKAction.group([moveAction, fadeInAction]))
        }
        run(SKAction.wait(forDuration: 0.4), completion: completion)
    }
    
    func animateCollapsingLines(linesToRemove: Array<Array<Block>>, fallenBlocks: Array<Array<Block>>, completion:@escaping () -> ()) {
        var longestDuration: TimeInterval = 0
        for (columnIdx, column) in fallenBlocks.enumerated() {
            for (blockIdx, block) in column.enumerated() {
                let newPosition = pointForColumn(column: block.column, row: block.row)
                print(blockIdx, " / ", block)
                let sprite = block.sprite!
                let delay = (TimeInterval(columnIdx) * 0.05) + (TimeInterval(blockIdx) * 0.05)
                let duration = TimeInterval(((sprite.position.y - newPosition.y) / BlockSize) * 0.1)
                let moveAction = SKAction.move(to: newPosition, duration: duration)
                moveAction.timingMode = .easeOut
                sprite.run(
                    SKAction.sequence([
                        SKAction.wait(forDuration: delay),
                        moveAction]))
                longestDuration = max(longestDuration, duration + delay)
            }
        }
        
        for rowToRemove in linesToRemove {
            for block in rowToRemove {
                let randomRadius = CGFloat(UInt(arc4random_uniform(400) + 100))
                let goLeft = (arc4random_uniform(100) % 2 == 0)
                let dx = goLeft ? -randomRadius : randomRadius
                
                var point = pointForColumn(column: block.column, row: block.row)
                point = CGPoint(x: point.x + dx, y: point.y)
                
                let randomDuration = TimeInterval(arc4random_uniform(2)) + 0.5
                var startAngle = CGFloat(M_PI)
                var endAngle = startAngle * 2
                if goLeft {
                    endAngle = startAngle
                    startAngle = 0
                }
                let archPath = UIBezierPath(arcCenter: point, radius: randomRadius, startAngle: startAngle, endAngle: endAngle, clockwise: goLeft)
                let archAction = SKAction.follow(archPath.cgPath, asOffset: false, orientToPath: true, duration: randomDuration)
                archAction.timingMode = .easeIn
                let sprite = block.sprite!
                sprite.zPosition = 100
                sprite.run(
                    SKAction.sequence(
                        [SKAction.group([archAction, SKAction.fadeOut(withDuration: TimeInterval(randomDuration))]),
                         SKAction.removeFromParent()]))
            }
        }
        run(SKAction.wait(forDuration: longestDuration), completion:completion)
    }
    
    func movePreviewShape(shape:Shape, completion:@escaping () -> ()) {
        for block in shape.blocks {
            let sprite = block.sprite!
            let moveTo = pointForColumn(column: block.column, row:block.row)
            let moveToAction:SKAction = SKAction.move(to: moveTo, duration: 0.2)
            moveToAction.timingMode = .easeOut
            sprite.run(
                SKAction.group([moveToAction, SKAction.fadeAlpha(to: 1.0, duration: 0.2)]), completion: {})
        }
        run(SKAction.wait(forDuration: 0.2), completion: completion)
    }
    
    func redrawShape(shape:Shape, completion:@escaping () -> ()) {
        for block in shape.blocks {
            let sprite = block.sprite!
            let moveTo = pointForColumn(column: block.column, row:block.row)
            let moveToAction:SKAction = SKAction.move(to: moveTo, duration: 0.05)
            moveToAction.timingMode = .easeOut
            if block == shape.blocks.last {
                sprite.run(moveToAction, completion: completion)
            } else {
                sprite.run(moveToAction)
            }
        }
    }
}
