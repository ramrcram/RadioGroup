//
//  RadioGroup.swift
//  RadioGroup
//
//  Created by Yonat Sharon on 03.02.2019.
//

import SweeterSwift
import UIKit

@IBDesignable open class RadioGroup: UIControl {
    public convenience init(titles: [String]) {
        self.init(frame: .zero)
        self.titles = titles
    }

    open var titles: [String?] {
        get {
            return items.map { $0.titleLabel.text }
        }
        set {
            stackView.removeAllArrangedSubviewsCompletely()
            stackView.addArrangedSubviews(newValue.map { RadioGroupItem(title: $0, group: self) })
            updateAllItems()
        }
    }

    open var attributedTitles: [NSAttributedString?] {
        get {
            return items.map { $0.titleLabel.attributedText }
        }
        set {
            stackView.removeAllArrangedSubviewsCompletely()
            stackView.addArrangedSubviews(newValue.map { RadioGroupItem(attributedTitle: $0, group: self) })
            updateAllItems()
        }
    }

    @IBInspectable open var selectedIndex: Int = -1 {
        didSet {
            item(at: oldValue)?.radioButton.isSelected = false
            item(at: oldValue)?.borderColour = itemBorderColour
            item(at: selectedIndex)?.radioButton.isSelected = true
        }
    }

    @IBInspectable open dynamic var selectedColor: UIColor? {
        didSet {
            forEachItem { $0.radioButton.selectedColor = selectedColor }
        }
    }

    @IBInspectable open dynamic var isVertical: Bool = true {
        didSet {
            stackView.axis = isVertical ? .vertical : .horizontal
        }
    }

    @IBInspectable open dynamic var buttonSize: CGFloat = 20 {
        didSet {
            forEachItem { $0.radioButton.size = buttonSize }
        }
    }

    @IBInspectable open dynamic var itemHeight: CGFloat = 80 {
        didSet {
            forEachItem { $0.fixedHeight = itemHeight }
        }
    }

    @IBInspectable open dynamic var itemBorderColour: UIColor = .clear {
        didSet {
            forEachItem { $0.borderColour = itemBorderColour }
        }
    }

    @IBInspectable open dynamic var selectedItemBorderColour: UIColor = .clear {
        didSet {
            forEachItem { $0.selectedBorderColour = selectedItemBorderColour }
        }
    }

    @IBInspectable open dynamic var itemBorderWidth: CGFloat = 1 {
        didSet {
            forEachItem { $0.borderWidth = itemBorderWidth }
        }
    }

    @IBInspectable open dynamic var itemCornerRadius: CGFloat = 0 {
        didSet {
            forEachItem { $0.cornerRadius = itemCornerRadius }
        }
    }

    open dynamic var itemInnerPadding: UIEdgeInsets = .zero {
        didSet {
            forEachItem { $0.innerPadding = itemInnerPadding }
        }
    }

    @IBInspectable open dynamic var spacing: CGFloat = 8 {
        didSet {
            stackView.spacing = spacing
        }
    }

    @IBInspectable open dynamic var itemSpacing: CGFloat = 4 {
        didSet {
            forEachItem { $0.stackView.spacing = itemSpacing }
        }
    }

    @IBInspectable open dynamic var isButtonAfterTitle: Bool = false {
        didSet {
            let direction: UISemanticContentAttribute = isButtonAfterTitle ? .forceRightToLeft : .unspecified
            forEachItem { $0.stackView.semanticContentAttribute = direction }
        }
    }

    @IBInspectable open dynamic var titleColor: UIColor? {
        didSet {
            guard titleColor != oldValue else { return }
            forEachItem { $0.titleLabel.textColor = titleColor }
        }
    }

    @objc open dynamic var titleAlignment: NSTextAlignment = .natural {
        didSet {
            forEachItem { $0.titleLabel.textAlignment = titleAlignment }
        }
    }

    @objc open dynamic var titleFont: UIFont? {
        didSet {
            guard titleFont != oldValue else { return }
            let newFont = titleFont ?? UIFont.systemFont(ofSize: UIFont.labelFontSize)
            forEachItem { $0.titleLabel.font = newFont }
        }
    }

    // MARK: - Private

    private let stackView = UIStackView()
    private var items: [RadioGroupItem] {
        return stackView.arrangedSubviews.compactMap { $0 as? RadioGroupItem }
    }

    private func setup() {
        addConstrainedSubview(stackView, constrain: .leftMargin, .rightMargin, .topMargin, .bottomMargin)
        stackView.distribution = .equalSpacing
        setContentCompressionResistancePriority(.required, for: .vertical)
        isVertical = { isVertical }()
        spacing = { spacing }()
        accessibilityIdentifier = "RadioGroup"
    }

    private func updateAllItems() {
        selectedColor = { selectedColor }()
        buttonSize = { buttonSize }()
        itemSpacing = { itemSpacing }()
        isButtonAfterTitle = { isButtonAfterTitle }()
        titleAlignment = { titleAlignment }()
        selectedIndex = { selectedIndex }()
    }

    private func item(at index: Int) -> RadioGroupItem? {
        guard index >= 0 && index < stackView.arrangedSubviews.count else { return nil }
        return stackView.arrangedSubviews[index] as? RadioGroupItem
    }

    private func forEachItem(_ perform: (RadioGroupItem) -> Void) {
        items.forEach(perform)
    }

    func selectIndex(item: RadioGroupItem) {
        guard let index = stackView.arrangedSubviews.firstIndex(of: item) else { return }
        selectedIndex = index
        sendActions(for: [.valueChanged, .primaryActionTriggered])
    }

    // MARK: - Overrides

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    open override var intrinsicContentSize: CGSize {
        layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        var size = stackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        size.width += layoutMargins.left + layoutMargins.right
        size.height += layoutMargins.top + layoutMargins.bottom
        return size
    }

    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        titles = ["First Option", "Second Option", "Third"]
    }
}

class RadioGroupItem: UIView {
    let titleLabel = UILabel()
    let radioButton = RadioButton()
    let stackView = UIStackView()

    var fixedHeight: CGFloat = 20 {
        didSet {
            constrain(.height, to: fixedHeight)
            invalidateIntrinsicContentSize()
        }
    }

    var borderWidth: CGFloat = 1 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }

    var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }

    var borderColour: UIColor = .clear {
        didSet {
            layer.borderColor = borderColour.cgColor
        }
    }

    var selectedBorderColour: UIColor = .clear

    var innerPadding: UIEdgeInsets = .zero {
        didSet {
            stackView.layoutMargins = innerPadding
            stackView.isLayoutMarginsRelativeArrangement = true
        }
    }

    unowned var group: RadioGroup

    init(title: String?, group: RadioGroup) {
        self.group = group
        super.init(frame: .zero)
        titleLabel.text = title
        setup()
    }

    init(attributedTitle: NSAttributedString?, group: RadioGroup) {
        self.group = group
        super.init(frame: .zero)
        titleLabel.attributedText = attributedTitle
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        if let titleFont = group.titleFont {
            titleLabel.font = titleFont
        }
        if let titleColor = group.titleColor {
            titleLabel.textColor = titleColor
        }
        let wrapper = UIView()
        wrapper.addConstrainedSubview(titleLabel, constrain: .top, .bottom, .left, .right)

        addConstrainedSubview(stackView, constrain: .left, .right, .top, .bottom)
        stackView.addArrangedSubviews([radioButton, wrapper])
        stackView.alignment = .center
        setContentCompressionResistancePriority(.required, for: .vertical)

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelect)))

        isAccessibilityElement = true
        accessibilityLabel = "option"
        accessibilityValue = titleLabel.text
        accessibilityIdentifier = "RadioGroupItem"
    }

    @objc func didSelect() {
        group.selectIndex(item: self)
        layer.borderColor = selectedBorderColour.cgColor
    }

    override var accessibilityTraits: UIAccessibilityTraits {
        get {
            return radioButton.isSelected ? [.selected] : []
        }
        set {} // swiftlint:disable:this unused_setter_value
    }
}

extension UIStackView {
    func addArrangedSubviews(_ subviews: [UIView]) {
        for subview in subviews {
            addArrangedSubview(subview)
        }
    }
}
