//
//  PencilNavigationController.swift
//  rainbow-fish
//
//  Created by Norm Barnard on 2/5/15.
//  Copyright (c) 2015 Clamdango. All rights reserved.
//

import UIKit

class CatalogNavigationController: UINavigationController {

    private var navigationControllerDelegate: UINavigationControllerDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        let image = UIImage(named: "tabbar-icon-pencils")?.imageWithRenderingMode(.AlwaysTemplate)
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

    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if fromVC.isKindOfClass(CatalogViewController.self) && toVC.isKindOfClass(EditMfgTableViewController.self) {
            return self
        }
        if fromVC.isKindOfClass(EditMfgTableViewController.self) && toVC.isKindOfClass(CatalogViewController.self) {
            return self
        }
        return nil
    }

}

extension CatalogNavigationControllerDelegate: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        if  let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey),
            let fromViewcontroller = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) {
            
                let containerView = transitionContext.containerView()
                containerView!.addSubview(toViewController.view)
                toViewController.view.alpha = 0.0
                
                UIView.animateWithDuration(self.transitionDuration(transitionContext),
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