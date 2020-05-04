/// Copyright (c) 2020 Razeware LLC
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

enum ColorType: String, CaseIterable {
  case red = "Red_Ball", green = "Green_Ball", blue = "Blue_Ball", yellow = "Yellow_Ball"
}

class Ball: SKSpriteNode {
  
  var colorType: ColorType {
    didSet {
      if smashed {
        self.texture = SKTexture(imageNamed: colorType.rawValue + "_Splash")
      } else {
        self.texture = SKTexture(imageNamed: colorType.rawValue)
      }
    }
  }
  
  init(colorType: ColorType) {
    self.colorType = colorType
    let texture = SKTexture(imageNamed: colorType.rawValue)
    super.init(texture: texture, color: .clear, size: texture.size())
  }
  
  var smashed: Bool = false {
    didSet {
      if smashed {
      self.texture = SKTexture(imageNamed: colorType.rawValue + "_Splash")
    } else {
      self.texture = SKTexture(imageNamed: colorType.rawValue)
    }
  }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
