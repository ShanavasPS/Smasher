/// Copyright (c) 2018 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SpriteKit

func +(left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func -(left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func *(point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func /(point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
  func sqrt(a: CGFloat) -> CGFloat {
    return CGFloat(sqrtf(Float(a)))
  }
#endif

extension CGPoint {
  func length() -> CGFloat {
    return sqrt(x*x + y*y)
  }
  
  func normalized() -> CGPoint {
    return self / length()
  }
}

struct PhysicsCategory {
  static let none      : UInt32 = 0
  static let all       : UInt32 = UInt32.max
  static let monster   : UInt32 = 0b1       // 1
  static let projectile: UInt32 = 0b10      // 2
}

enum ColorType: String {
    case red = "Red_Ball", green = "Green_Ball", blue = "Blue_Ball", yellow = "Yellow_Ball"
}

class Ball: SKSpriteNode {

    var colorType: ColorType {
        didSet {
            self.texture = SKTexture(imageNamed: colorType.rawValue)
        }
    }

    init(colorType: ColorType) {
        self.colorType = colorType
        let texture = SKTexture(imageNamed: colorType.rawValue)
        super.init(texture: texture, color: .clear, size: texture.size())
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class GameScene: SKScene {
  let player = SKSpriteNode(imageNamed: "chammu")
  let players = ["adam", "fazu", "chammu_left"]
  
  override func didMove(to view: SKView) {
    
    // 2
    backgroundColor = SKColor.white
    
    physicsWorld.gravity = .zero
    physicsWorld.contactDelegate = self

    run(SKAction.repeatForever(
      SKAction.sequence([
        SKAction.run(addMonsters),
        SKAction.wait(forDuration: 1.0)
        ])
    ))
    
    let backgroundMusic = SKAudioNode(fileNamed: "background-music-aac.caf")
    backgroundMusic.autoplayLooped = true
    addChild(backgroundMusic)
  }
  
  func random() -> CGFloat {
    return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
  }

  func random(min: CGFloat, max: CGFloat) -> CGFloat {
    return random() * (max - min) + min
  }

  func addMonsters() {
    addMonster(position: 0.2, ball: .blue)
    addMonster(position: 0.4, ball: .green)
    addMonster(position: 0.6, ball: .red)
    addMonster(position: 0.8, ball: .yellow)
  }
  
  func addMonster(position: Double, ball: ColorType) {
    
    // Create sprite
    let monster = Ball(colorType: ball)
    monster.size.height = 80
    monster.size.width = 80
    monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size) // 1
    monster.physicsBody?.isDynamic = true // 2
    monster.physicsBody?.categoryBitMask = PhysicsCategory.monster // 3
    monster.physicsBody?.contactTestBitMask = PhysicsCategory.projectile // 4
    monster.physicsBody?.collisionBitMask = PhysicsCategory.none // 5

    monster.position = CGPoint(x: size.width * CGFloat(position), y: size.height * 0.9)
    
    // Add the monster to the scene
    addChild(monster)
    
    // Determine speed of the monster
    let actualDuration = CGFloat(8.0)
    
    // Create the actions
    let actionMove = SKAction.move(to: CGPoint(x: size.width * CGFloat(position), y: -monster.size.height/2),
                                   duration: TimeInterval(actualDuration))
    let actionMoveDone = SKAction.removeFromParent()
    monster.run(SKAction.sequence([actionMove, actionMoveDone]))
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    // 1 - Choose one of the touches to work with
    guard let touch = touches.first else {
      return
    }
    
    let touchLocation = touch.location(in: self)
    
    if let monster = physicsWorld.body(at: touchLocation)?.node {
      run(SKAction.playSoundFileNamed("blast.mp3", waitForCompletion: false))
      if let examp = monster as? Ball {
        if(examp.colorType == .red) {
          examp.texture = SKTexture.init(imageNamed: "Red_Ball_Splattered")
        } else {
          examp.texture = SKTexture.init(imageNamed: "Splattered_Common")
        }
      }
    }
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else {
      return
    }
    
    let touchLocation = touch.location(in: self)
    
    if let monster = physicsWorld.body(at: touchLocation)?.node {
      run(SKAction.playSoundFileNamed("blast.mp3", waitForCompletion: false))
      if let examp = monster as? Ball {
        if(examp.colorType == .red) {
          examp.texture = SKTexture.init(imageNamed: "Red_Ball_Splattered")
        } else {
          examp.texture = SKTexture.init(imageNamed: "Splattered_Common")
        }
      }
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    // 1 - Choose one of the touches to work with
    guard let touch = touches.first else {
      return
    }
    
    let touchLocation = touch.location(in: self)
    
    if let monster = physicsWorld.body(at: touchLocation)?.node {
      run(SKAction.playSoundFileNamed("blast.mp3", waitForCompletion: false))
      if let examp = monster as? Ball {
        if(examp.colorType == .red) {
          examp.texture = SKTexture.init(imageNamed: "Red_Ball_Splattered")
        } else {
          examp.texture = SKTexture.init(imageNamed: "Splattered_Common")
        }
      }
    }
  }
  
  func projectileDidCollideWithMonster(projectile: SKSpriteNode, monster: SKSpriteNode) {
    print("Hit")
    run(SKAction.playSoundFileNamed("blast.mp3", waitForCompletion: false))
    projectile.removeFromParent()
    monster.removeFromParent()
  }
}

extension GameScene: SKPhysicsContactDelegate {
  
  
  func didBegin(_ contact: SKPhysicsContact) {
    // 1
    var firstBody: SKPhysicsBody
    var secondBody: SKPhysicsBody
    if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
      firstBody = contact.bodyA
      secondBody = contact.bodyB
    } else {
      firstBody = contact.bodyB
      secondBody = contact.bodyA
    }
   
    // 2
    if ((firstBody.categoryBitMask & PhysicsCategory.monster != 0) &&
        (secondBody.categoryBitMask & PhysicsCategory.projectile != 0)) {
      if let monster = firstBody.node as? SKSpriteNode,
        let projectile = secondBody.node as? SKSpriteNode {
        projectileDidCollideWithMonster(projectile: projectile, monster: monster)
      }
    }
  }
}
