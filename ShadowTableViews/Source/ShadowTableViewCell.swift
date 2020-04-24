//
//  ShadowTableViewCell.swift
//  Sumanth
//
//  Created by Sumanth on 19/03/2020.
//

import UIKit

struct ShadowProperties {
    let color: UIColor
    let opacity: Float
    let blur: CGFloat
    let offset: CGPoint

    init(color: UIColor, opacity: Float = 1, blur: CGFloat = 0, offset: CGPoint = .zero) {
        self.color = color
        self.opacity = opacity
        self.blur = blur
        self.offset = offset
    }
}

enum ShadowTypes {
    case none
    case level0
    case level1
    case level2
    case level3
    case level4

    var properties: ShadowProperties? {
        switch self {
        case .none:
            return nil
        case .level0:
            return ShadowProperties(color: .white)
        case .level1:
            return ShadowProperties(color: .black, opacity: 0.12, blur: 9, offset: CGPoint(x: 0, y: 4))
        case .level2:
            return ShadowProperties(color: .black, opacity: 0.10, blur: 16, offset: CGPoint(x: 0, y: 8))
        case .level3:
            return ShadowProperties(color: .black, opacity: 0.10, blur: 20, offset: CGPoint(x: 0, y: 15))
        case .level4:
            return ShadowProperties(color: .black, opacity: 0.24, blur: 56, offset: CGPoint(x: 0, y: 48))
        }
    }
}

extension UIView {
    func applyShadow(with type: ShadowTypes) {
        shadowColor = type.properties?.color
        shadowOpacity = type.properties?.opacity ?? 1
        shadowBlur = type.properties?.blur ?? 0
        shadowOffset = type.properties?.offset ?? .zero
        shadowSpread = 0
        layer.masksToBounds = false
    }

    func setRoundedEdges(with type: ShadowTypes) {
        setRoundedEdges(with: .allCorners, radius: type.properties?.blur ?? 16)
    }
    
    func setRoundedEdges(with corners: UIRectCorner = [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: CGFloat = 16.0) {
        let navBarBounds = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        let maskPath = UIBezierPath(roundedRect: navBarBounds,
                                    byRoundingCorners: corners,
                                    cornerRadii: CGSize(width: radius, height: radius))

        let mask = CAShapeLayer()
        mask.path = maskPath.cgPath

        layer.mask = mask
    }
    
    func bindFrameToSuperviewBounds(with margin:UIEdgeInsets = .zero) {
        guard let superview = self.superview else {
            print("Error! `superview` was nil – call `addSubview(view: UIView)` before calling `bindFrameToSuperviewBounds()` to fix this.")
            return
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.topAnchor.constraint(equalTo: superview.topAnchor, constant: margin.top).isActive = true
        self.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -margin.bottom).isActive = true
        self.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: margin.left).isActive = true
        self.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -margin.right).isActive = true
        
    }
}

extension UIView {
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }

    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }

    var shadowOffset: CGPoint {
        get {
            return CGPoint(x: layer.shadowOffset.width, y: layer.shadowOffset.height)
        }
        set {
            layer.shadowOffset = CGSize(width: newValue.x, height: newValue.y)
        }
    }

    var shadowBlur: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue / 2.0
        }
    }

    var shadowSpread: CGFloat {
        get {
            return 0
        }
        set {
            let dx = -newValue
            let rect = bounds.insetBy(dx: dx, dy: dx)
            layer.shadowPath = UIBezierPath(rect: rect).cgPath
            layer.shouldRasterize = true
            layer.rasterizationScale = UIScreen.main.scale
        }
    }
}
