import UIKit

public class JNAlertBarView: UIView, AlertViewProtocol, AlertViewInternalDismissProtocol {
    
    open var dismissByTap: Bool = true
    open var dismissInTime: Bool = true
    open var duration: TimeInterval = 1.5
    open var haptic: AlertHaptic?
    
    public let titleLabel: UILabel?
    public let subtitleLabel: UILabel?
    public let iconView: UIView?
    
    public static var defaultContentColor = UIColor { trait in
        switch trait.userInterfaceStyle {
        case .dark: return UIColor(red: 127 / 255, green: 127 / 255, blue: 129 / 255, alpha: 1)
        default: return UIColor(red: 88 / 255, green: 87 / 255, blue: 88 / 255, alpha: 1)
        }
    }
    
    fileprivate weak var viewForPresent: UIView?
    fileprivate var presentDismissDuration: TimeInterval = 0.2
    fileprivate var presentDismissScale: CGFloat = 0.8
    
    fileprivate var completion: (() -> Void)?
    
    private lazy var backgroundView: UIView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        view.isUserInteractionEnabled = false
        return view
    }()
    
    public init(title: String?, subtitle: String?, icon: AlertIcon?, effect: UIBlurEffect.Style = .systemMaterial,
                dismissByTap: Bool = true, dismissInTime: Bool = true, duration: TimeInterval = 1.5,
                presentDismissDuration: TimeInterval = 0.2, presentDismissScale: CGFloat = 0.8,
                cornerRadius: CGFloat = 14) {
        self.dismissByTap = dismissByTap
        self.dismissInTime = dismissInTime
        self.duration = duration
        self.presentDismissDuration = presentDismissDuration
        self.presentDismissScale = presentDismissScale
        
        titleLabel = UILabel().then {
            $0.font = UIFont.preferredFont(forTextStyle: .body, weight: .semibold, addPoints: -2)
            $0.numberOfLines = 0
            $0.attributedText = NSAttributedString(string: title ?? "", attributes: [
                .paragraphStyle: NSMutableParagraphStyle().then {
                    $0.lineSpacing = 3
                    $0.alignment = .left
                }
            ])
            $0.textColor = Self.defaultContentColor
        }
        
        subtitleLabel = UILabel().then {
            $0.font = UIFont.preferredFont(forTextStyle: .footnote)
            $0.numberOfLines = 0
            $0.attributedText = NSAttributedString(string: subtitle ?? "", attributes: [
                .paragraphStyle: NSMutableParagraphStyle().then {
                    $0.lineSpacing = 2
                    $0.alignment = .left
                }
            ])
            $0.textColor = Self.defaultContentColor
        }
        
        iconView = icon?.createView(lineThick: 3).then {
            $0.tintColor = Self.defaultContentColor
        }
        
        super.init(frame: .zero)
        
        preservesSuperviewLayoutMargins = false
        insetsLayoutMarginsFromSafeArea = false
        backgroundColor = .clear
        
        backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: effect))
        addSubview(backgroundView)
        
        if let titleLabel = titleLabel { addSubview(titleLabel) }
        if let subtitleLabel = subtitleLabel { addSubview(subtitleLabel) }
        if let iconView = iconView { addSubview(iconView) }
        
        layer.masksToBounds = true
        layer.cornerRadius = cornerRadius
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
        center.x = viewForPresent.frame.midX
        frame.origin.y = viewForPresent.frame.height - viewForPresent.safeAreaInsets.bottom - frame.height - 64
        
        transform = transform.scaledBy(x: self.presentDismissScale, y: self.presentDismissScale)
        
        if dismissByTap {
            let tapGesterRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismiss))
            addGestureRecognizer(tapGesterRecognizer)
        }
                
        haptic?.impact()
        
        UIView.animate(withDuration: presentDismissDuration, animations: {
            self.alpha = 1
            self.transform = CGAffineTransform.identity
        }, completion: { [weak self] _ in
            guard let self = self else { return }
            
            if let iconView = self.iconView as? AlertIconAnimatable {
                iconView.animate()
            }
            
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
        layout(maxWidth: frame.width)
    }
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        layout(maxWidth: nil)
        
        let maxX = subviews.sorted(by: { $0.frame.maxX > $1.frame.maxX }).first?.frame.maxX ?? .zero
        let currentNeedWidth = maxX + layoutMargins.right
        
        let maxWidth = {
            if let viewForPresent = self.viewForPresent {
                return min(viewForPresent.frame.width * 0.8, 270)
            } else {
                return 270
            }
        }()
        
        let usingWidth = min(currentNeedWidth, maxWidth)
        layout(maxWidth: usingWidth)
        let height = subtitleLabel?.frame.maxY ?? titleLabel?.frame.maxY ?? .zero
        return .init(width: usingWidth, height: height + layoutMargins.bottom)
    }
    
    private func layout(maxWidth: CGFloat?) {
        let spaceBetweenLabelAndIcon: CGFloat = 12
        let spaceBetweenTitleAndSubtitle: CGFloat = 4

        if let iconView = self.iconView {
            layoutWithIcon(iconView,
                           maxWidth: maxWidth,
                           spaceBetweenLabelAndIcon: spaceBetweenLabelAndIcon,
                           spaceBetweenTitleAndSubtitle: spaceBetweenTitleAndSubtitle)
        } else {
            layoutWithoutIcon(maxWidth: maxWidth,
                              spaceBetweenTitleAndSubtitle: spaceBetweenTitleAndSubtitle)
        }

        iconView?.center.y = frame.height / 2
    }

    private func layoutWithIcon(_ iconView: UIView,
                                maxWidth: CGFloat?,
                                spaceBetweenLabelAndIcon: CGFloat,
                                spaceBetweenTitleAndSubtitle: CGFloat
    ) {
        iconView.frame = .init(x: layoutMargins.left, y: .zero, width: 20, height: 20)
        let xPosition = iconView.frame.maxX + spaceBetweenLabelAndIcon

        if let maxWidth = maxWidth {
            layoutWithMaxWidth(maxWidth,
                               xPosition: xPosition,
                               spaceBetweenTitleAndSubtitle: spaceBetweenTitleAndSubtitle
            )
        } else {
            layoutWithoutMaxWidth(xPosition: xPosition,
                                  spaceBetweenTitleAndSubtitle: spaceBetweenTitleAndSubtitle
            )
        }
    }

    private func layoutWithMaxWidth(_ maxWidth: CGFloat, xPosition: CGFloat, spaceBetweenTitleAndSubtitle: CGFloat) {
        let labelWidth = maxWidth - xPosition - layoutMargins.right

        titleLabel?.frame = .init(
            x: xPosition,
            y: layoutMargins.top,
            width: labelWidth,
            height: titleLabel?.frame.height ?? .zero
        )
        titleLabel?.sizeToFit()

        subtitleLabel?.frame = .init(
            x: xPosition,
            y: (titleLabel?.frame.maxY ?? layoutMargins.top) + spaceBetweenTitleAndSubtitle,
            width: labelWidth,
            height: subtitleLabel?.frame.height ?? .zero
        )
        subtitleLabel?.sizeToFit()
    }

    private func layoutWithoutMaxWidth(xPosition: CGFloat, spaceBetweenTitleAndSubtitle: CGFloat) {
        titleLabel?.sizeToFit()
        titleLabel?.frame.origin.x = xPosition
        titleLabel?.frame.origin.y = layoutMargins.top

        subtitleLabel?.sizeToFit()
        subtitleLabel?.frame.origin.x = xPosition
        subtitleLabel?.frame.origin.y = (titleLabel?.frame.maxY ?? layoutMargins.top) + spaceBetweenTitleAndSubtitle
    }

    private func layoutWithoutIcon(maxWidth: CGFloat?, spaceBetweenTitleAndSubtitle: CGFloat) {
        if let maxWidth = maxWidth {
            layoutWithoutIconAndMaxWidth(maxWidth, spaceBetweenTitleAndSubtitle: spaceBetweenTitleAndSubtitle)
        } else {
            layoutWithoutIconAndWithoutMaxWidth(spaceBetweenTitleAndSubtitle: spaceBetweenTitleAndSubtitle)
        }
    }

    private func layoutWithoutIconAndMaxWidth(_ maxWidth: CGFloat, spaceBetweenTitleAndSubtitle: CGFloat) {
        let labelWidth = maxWidth - layoutMargins.left - layoutMargins.right

        titleLabel?.frame = .init(
            x: layoutMargins.left,
            y: layoutMargins.top,
            width: labelWidth,
            height: titleLabel?.frame.height ?? .zero
        )
        titleLabel?.sizeToFit()

        subtitleLabel?.frame = .init(
            x: layoutMargins.left,
            y: (titleLabel?.frame.maxY ?? layoutMargins.top) + spaceBetweenTitleAndSubtitle,
            width: labelWidth,
            height: subtitleLabel?.frame.height ?? .zero
        )
        subtitleLabel?.sizeToFit()
    }

    private func layoutWithoutIconAndWithoutMaxWidth(spaceBetweenTitleAndSubtitle: CGFloat) {
        titleLabel?.sizeToFit()
        titleLabel?.frame.origin.x = layoutMargins.left
        titleLabel?.frame.origin.y = layoutMargins.top

        subtitleLabel?.sizeToFit()
        subtitleLabel?.frame.origin.x = layoutMargins.left
        subtitleLabel?.frame.origin.y = (titleLabel?.frame.maxY ?? layoutMargins.top) + spaceBetweenTitleAndSubtitle
    }
}
