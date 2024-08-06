import UIKit
import Then

public class AlertIconDoneView: UIView, AlertIconAnimatable {
    
    private let lineThick: CGFloat
    
    init(lineThick: CGFloat) {
        self.lineThick = lineThick
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func animate() {
        let length = frame.width
        let animatablePath = UIBezierPath().then {
            $0.move(to: CGPoint(x: length * 0.196, y: length * 0.527))
            $0.addLine(to: CGPoint(x: length * 0.47, y: length * 0.777))
            $0.addLine(to: CGPoint(x: length * 0.99, y: length * 0.25))
        }
        
        let animatableLayer = CAShapeLayer().then {
            $0.path = animatablePath.cgPath
            $0.fillColor = UIColor.clear.cgColor
            $0.strokeColor = tintColor?.cgColor
            $0.lineWidth = lineThick
            $0.lineCap = .round
            $0.lineJoin = .round
            $0.strokeEnd = 0
        }
        layer.addSublayer(animatableLayer)
        
        let animation = CABasicAnimation(keyPath: "strokeEnd").then {
            $0.duration = 0.3
            $0.fromValue = 0
            $0.toValue = 1
            $0.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        }
        animatableLayer.strokeEnd = 1
        animatableLayer.add(animation, forKey: "animation")
    }
}
