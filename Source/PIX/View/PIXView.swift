//
//  PIXView.swift
//  HxPxE
//
//  Created by Hexagons on 2018-07-26.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import MetalKit

public class PIXView: UIView {
    
    let metalView: PIXMetalView

    var resolution: CGSize?

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
    
//    public enum Checker {
//        case lightGray
//        case gray
//        case darkGray
//    }
//    public var checker: Checker? = .gray {
//        didSet {
//            checkerView.isHidden = checker == nil
//            if checker != nil {
//                // ...
//            }
//        }
//    }
//    let checkerSize = CGSize(width: 8, height: 8)
//
//    let checkerLayer: CheckerLayer
//    let checkerView: UIView
    
    init() {
        
//        checkerLayer = CheckerLayer()
//        checkerView = UIView()

        metalView = PIXMetalView()
        
        super.init(frame: .zero)
        
        clipsToBounds = true
        
//        checkerView.layer.addSublayer(checkerLayer)
//        addSubview(checkerView)
        
        addSubview(metalView)
        
        layout()
        style()
        
    }
    
    func layout() {
        
//        checkerView.translatesAutoresizingMaskIntoConstraints = false
//        checkerView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
//        checkerView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
//        checkerView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
//        checkerView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        metalView.translatesAutoresizingMaskIntoConstraints = false
        metalView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        metalView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        widthLayoutConstraint = metalView.widthAnchor.constraint(equalToConstant: 128) // CHECK 128
        heightLayoutConstraint = metalView.heightAnchor.constraint(equalToConstant: 128) // CHECK 128
        widthLayoutConstraint.isActive = true
        heightLayoutConstraint.isActive = true
        
    }
    
    func layoutFillMode() {
        
        guard boundsReady else { return }
        guard resolution != nil else { return }
        
        let resolutionAspect = resolution!.width / resolution!.height
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
            width = resolution!.width / UIScreen.main.nativeScale
            height = resolution!.height / UIScreen.main.nativeScale
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
    
    func setResolution(_ newResolution: CGSize) {
        if newResolution != resolution {
            resolution = newResolution
            layoutFillMode()
            metalView.setResolution(newResolution) // CHECK layoutSubviews()
        } else {
//            layoutFillMode()
            if HxPxE.main.frameIndex < 10 { print("PIX View", "Same res...") }
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        layoutFillMode()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
