//
//  PIXView.swift
//  Pixels
//
//  Created by Hexagons on 2018-07-26.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import MetalKit

public class PIXView: UIView {
    
    let metalView: PIXMetalView

    var res: PIX.Res?

    var boundsReady: Bool { return bounds.width > 0 }

    public enum FillMode {
        case aspectFit
        case aspectFill
        case pixelPerfect
        case fill
    }
    public var fillMode: FillMode = .aspectFit { didSet { layoutFillMode() } }
    
    var widthLayoutConstraint: NSLayoutConstraint!
    var heightLayoutConstraint: NSLayoutConstraint!
    
    public var checker: Bool = true { didSet { checkerView.isHidden = !checker } }
    let checkerView: CheckerView
    
    init() {
        
        checkerView = CheckerView()

        metalView = PIXMetalView()
        
        super.init(frame: .zero)
        
        clipsToBounds = true
        
        addSubview(checkerView)
        
        addSubview(metalView)
        
        layout()
        style()
        
    }
    
    func layout() {
        
        checkerView.translatesAutoresizingMaskIntoConstraints = false
        checkerView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        checkerView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        checkerView.widthAnchor.constraint(equalTo: metalView.widthAnchor).isActive = true
        checkerView.heightAnchor.constraint(equalTo: metalView.heightAnchor).isActive = true
        
        metalView.translatesAutoresizingMaskIntoConstraints = false
        metalView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        metalView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        widthLayoutConstraint = metalView.widthAnchor.constraint(equalToConstant: 1)
        heightLayoutConstraint = metalView.heightAnchor.constraint(equalToConstant: 1)
        widthLayoutConstraint.isActive = true
        heightLayoutConstraint.isActive = true
        
    }
    
    func layoutFillMode() {
        
        guard boundsReady else { return }
        guard let res = res else { return }
        
        let resolutionAspect = res.width / res.height
        let viewAspect = bounds.width / bounds.height
        let combinedAspect = resolutionAspect / viewAspect
        let dynamicAspect = resolutionAspect > viewAspect ? combinedAspect : 1 / combinedAspect
        
        let width: CGFloat
        let height: CGFloat
        switch fillMode {
        case .aspectFit:
            width = resolutionAspect >= viewAspect ? bounds.width : bounds.width / dynamicAspect
            height = resolutionAspect <= viewAspect ? bounds.height : bounds.height / dynamicAspect
        case .aspectFill:
            width = resolutionAspect <= viewAspect ? bounds.width : bounds.width * dynamicAspect
            height = resolutionAspect >= viewAspect ? bounds.height : bounds.height * dynamicAspect
        case .pixelPerfect:
            width = res.width / UIScreen.main.nativeScale
            height = res.height / UIScreen.main.nativeScale
        case .fill:
            width = bounds.width
            height = bounds.height
        }
        
        widthLayoutConstraint.constant = width
        heightLayoutConstraint.constant = height
        
    }
    
    func style() {
        
//        checkerLayer.tileSize = checkerSize
        
    }
    
    func setRes(_ newRes: PIX.Res) {
        res = newRes
        metalView.res = newRes
        layoutFillMode()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        layoutFillMode()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
