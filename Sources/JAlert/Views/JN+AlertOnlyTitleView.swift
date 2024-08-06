import UIKit
import JUtile
import Then

public class JNAlertOnlyTitleView: UIView, AlertViewProtocol, AlertViewInternalDismissProtocol {
    
    open var dismissByTap: Bool = true
    open var dismissInTime: Bool = true
    open var duration: TimeInterval
    open var haptic: AlertHaptic?
    
    private var customHeight: CGFloat
    private var customYPosition: CGFloat?
    
    public let titleLabel: UILabel?
    
    public static var defaultContentColor = UIColor { trait in
        switch trait.userInterfaceStyle {
        case .dark: return UIColor(red: 127 / 255, green: 127 / 255, blue: 129 / 255, alpha: 1)
        default: return UIColor(red: 88 / 255, green: 87 / 255, blue: 88 / 255, alpha: 1)
        }
    }
    
    fileprivate weak var viewForPresent: UIView?
    fileprivate var presentDismissDuration: TimeInterval
    fileprivate var presentDismissScale: CGFloat
    
    fileprivate var completion: (() -> Void)?
    
    private lazy var backgroundView: UIView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        view.isUserInteractionEnabled = false
        return view
    }()
    
    public init(title: String?,
                height: CGFloat = 42.0,
                yPosition: CGFloat? = nil,
                duration: TimeInterval = 0.5,
                scale: CGFloat = 0.8,
                dismissTime: TimeInterval = 1.5
    ) {
        self.customHeight = height
        self.customYPosition = yPosition
        self.presentDismissDuration = duration
        self.presentDismissScale = scale
        self.duration = dismissTime
        titleLabel = UILabel().then {
            $0.font = UIFont.preferredFont(forTextStyle: .body, weight: .semibold, addPoints: -2)
            $0.numberOfLines = 0
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 3
            style.alignment = .left
            $0.attributedText = NSAttributedString(string: title ?? "", attributes: [.paragraphStyle: style])
        }
        
        self.titleLabel?.textColor = Self.defaultContentColor
        
        super.init(frame: .zero)
        
        preservesSuperviewLayoutMargins = false
        insetsLayoutMarginsFromSafeArea = false
        
        backgroundColor = .clear
        addSubview(backgroundView)
        
        if let titleLabel = self.titleLabel {
            addSubview(titleLabel)
        }
        
        layer.masksToBounds = true
        layer.cornerRadius = 8
        layer.cornerCurve = .continuous
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func present(on view: UIView, completion: (() -> Void)? = nil) {
        self.viewForPresent = view
        self.completion = completion
        viewForPresent?.addSubview(self)
        guard let viewForPresent = viewForPresent else { return }

        alpha = 0
        sizeToFit()

        let yPos = customYPosition ?? (viewForPresent.safeAreaInsets.top + frame.height)
        center.x = viewForPresent.frame.midX
        frame.origin.y = yPos

        transform = transform.scaledBy(x: self.presentDismissScale, y: self.presentDismissScale)

        if dismissByTap {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismiss))
            addGestureRecognizer(tapGestureRecognizer)
        }

        UIView.animate(withDuration: presentDismissDuration, animations: {
            self.alpha = 1
            self.transform = CGAffineTransform.identity
        }, completion: { [weak self] _ in
            guard let self = self else { return }
            if self.dismissInTime {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + self.duration) {
                    if self.alpha != 0 {
                        self.dismiss()
                    }
                }
            }
        })
    }
    
    @objc open func dismiss() {
        self.dismiss(customCompletion: self.completion)
    }
    
    func dismiss(customCompletion: (() -> Void)? = nil) {
        UIView.animate(withDuration: presentDismissDuration, animations: {
            self.alpha = 0
            self.transform = self.transform.scaledBy(x: self.presentDismissScale, y: self.presentDismissScale)
        }, completion: { [weak self] _ in
            self?.removeFromSuperview()
            customCompletion?()
        })
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        guard self.transform == .identity else { return }
        backgroundView.frame = self.bounds
        center.x = viewForPresent?.frame.midX ?? 0
        layout(maxWidth: frame.width)
    }
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        let fixedWidth: CGFloat = 390.0
        layout(maxWidth: fixedWidth)
        
        let maxX = subviews.sorted(by: { $0.frame.maxX > $1.frame.maxX }).first?.frame.maxX ?? .zero
        let currentNeedWidth = maxX + layoutMargins.right
        
        let usingWidth = min(currentNeedWidth, fixedWidth)
        layout(maxWidth: usingWidth)
        let height = customHeight
        return .init(width: usingWidth, height: height + layoutMargins.bottom)
    }
    
    private func layout(maxWidth: CGFloat?) {
        let leadingMargin: CGFloat = 0.0
        let trailingMargin: CGFloat = 24.0
        
        let availableWidth = maxWidth ?? 390.0
        let labelWidth = availableWidth - leadingMargin - trailingMargin
        titleLabel?.frame = CGRect(
            x: leadingMargin + layoutMargins.left,
            y: layoutMargins.top - 3,
            width: labelWidth,
            height: customHeight
        )
    }
}
