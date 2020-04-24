//
//  HBShadowView.swift
//  Sumanth
//
//  Created by Sumanth on 20/03/2020.
//

import UIKit

class ShadowView: UIView {
    private var shadowLayer: CAShapeLayer!
    private var subview: UIView?
    var previousFrame: CGRect = .zero
    var hasRoundedEdges = true

    override func layoutSubviews() {
        super.layoutSubviews()
        if previousFrame != frame {
            previousFrame = frame
            applyShadow(with: .level1)
            if hasRoundedEdges {
                for eachSubView in subviews {
                    eachSubView.setRoundedEdges(with: .level1)
                }
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    init(with subView: UIView) {
        super.init(frame: .zero)
        subview = subView
        addSubview(subView)
        setupLayout()
    }

    func setupLayout() {
        if let subview = subview {
            subview.bindFrameToSuperviewBounds()
        }
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
