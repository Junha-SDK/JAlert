import UIKit
import Then

public class AlertIconErrorView: UIView, AlertIconAnimatable {

    private let lineThick: CGFloat
    
    init(lineThick: CGFloat) {
        self.lineThick = lineThick
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func animate() {
        animateTopToBottomLine()
        animateBottomToTopLine()
    }
        
    private func animateTopToBottomLine() {
        let length = frame.width
        
        let topToBottomLine = UIBezierPath().then {
            $0.move(to: CGPoint(x: length * 0, y: length * 0))
            $0.addLine(to: CGPoint(x: length * 1, y: length * 1))
        }
        
        let animatableLayer = CAShapeLayer().then {
            $0.path = topToBottomLine.cgPath
            $0.fillColor = UIColor.clear.cgColor
            $0.strokeColor = tintColor?.cgColor
            $0.lineWidth = lineThick
            $0.lineCap = .round
            $0.lineJoin = .round
            $0.strokeEnd = 0
        }

        self.layer.addSublayer(animatableLayer)
        
        let animation = CABasicAnimation(keyPath: "strokeEnd").then {
            $0.duration = 0.22
            $0.fromValue = 0
            $0.toValue = 1
            $0.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        }
        
        animatableLayer.strokeEnd = 1
        animatableLayer.add(animation, forKey: "animation")
    }
        
    private func animateBottomToTopLine() {
        let length = frame.width
        
        let bottomToTopLine = UIBezierPath().then {
            $0.move(to: CGPoint(x: length * 0, y: length * 1))
            $0.addLine(to: CGPoint(x: length * 1, y: length * 0))
        }
        
        let animatableLayer = CAShapeLayer().then {
            $0.path = bottomToTopLine.cgPath
            $0.fillColor = UIColor.clear.cgColor
            $0.strokeColor = tintColor?.cgColor
            $0.lineWidth = lineThick
            $0.lineCap = .round
            $0.lineJoin = .round
            $0.strokeEnd = 0
        }

        self.layer.addSublayer(animatableLayer)
        
        let animation = CABasicAnimation(keyPath: "strokeEnd").then {
            $0.duration = 0.22
            $0.fromValue = 0
            $0.toValue = 1
            $0.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        }
        
        animatableLayer.strokeEnd = 1
        animatableLayer.add(animation, forKey: "animation")
    }
}
