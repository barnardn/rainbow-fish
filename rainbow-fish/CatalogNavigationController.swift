//
//  PencilNavigationController.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 2/5/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit

class CatalogNavigationController: UINavigationController {

    fileprivate var navigationControllerDelegate: UINavigationControllerDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        let image = UIImage(named: "tabbar-icon-pencils")?.withRenderingMode(.alwaysTemplate)
        self.tabBarItem = UITabBarItem(title: NSLocalizedString("Catalog", comment:"all pencils tab bar item title"), image: image, tag: 1)
        self.title = NSLocalizedString("Catalog", comment:"browse all pencils navigation title")
        navigationControllerDelegate = CatalogNavigationControllerDelegate()
        self.delegate = navigationControllerDelegate
        self.viewControllers = [CatalogViewController()]
    }
    
    deinit {
        self.navigationControllerDelegate = nil
    }
    
}

class CatalogNavigationControllerDelegate: NSObject, UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if fromVC.isKind(of: CatalogViewController.self) && toVC.isKind(of: EditMfgTableViewController.self) {
            return self
        }
        if fromVC.isKind(of: EditMfgTableViewController.self) && toVC.isKind(of: CatalogViewController.self) {
            return self
        }
        return nil
    }

}

extension CatalogNavigationControllerDelegate: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        if  let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let fromViewcontroller = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) {
            
                let containerView = transitionContext.containerView
                containerView.addSubview(toViewController.view)
                toViewController.view.alpha = 0.0
                
                UIView.animate(withDuration: self.transitionDuration(using: transitionContext),
                    animations: { () -> Void in
                        
                        fromViewcontroller.view.alpha = 0.0
                        toViewController.view.alpha = 1.0
                        
                    }, completion: { (finished: Bool) -> Void in
                        
                        fromViewcontroller.view.alpha = 1.0
                        transitionContext.completeTransition(finished)
                    
                })
                
        }
        
        
        
        
    }
    
    
}
