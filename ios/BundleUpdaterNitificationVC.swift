//
//  test.swift
//  DoubleConversion
//
//  Created by Giulio Milani on 01/12/23.
//

import UIKit
import SPIndicator

/**
 AlertViewTest: the ViewController to present when an update is available
 TODO - show a loading screen while the update is running
 */
@objc(BundleUpdaterNitificationVC)
class BundleUpdaterNitificationVC: UIViewController {
    var customView: SPIndicatorView?
    var btn: UIButton = UIButton(frame:CGRect(x:0, y: 0, width: 50, height: 50));
    @objc public var isNecessaryUpdate: Bool = false
    
    // MARK: - init
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let downloadIcon: UIImage?
        if #available(iOS 13, *){
            downloadIcon =  UIImage(systemName: "tray.and.arrow.down.fill")
        }else{
            //TODO - default icon
            downloadIcon = UIImage(named: "test")
        }
        //lazy init
        if(customView == nil){
            self.customView = SPIndicatorView(title: "Update available", message: "Tap the icon to update the app", preset: .custom(downloadIcon!))
        }
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Setter for the objc prop
    @objc func setIsNecessaryUpdate(isNecessaryUpdate: Bool){
        self.isNecessaryUpdate = isNecessaryUpdate
    }
    
    // MARK: - View controller states
    override func viewDidLoad() {
        // TODO - background color black + opacity 0.5 + animation
        if let _customView = self.customView {
            self.displayAlertProps(alert: _customView)
            self.displayBTNProps(button: self.btn)
            DispatchQueue.main.async {
                self.btn.addTarget(self, action: #selector(self.update), for: .touchUpInside)
                _customView.addSubview(self.btn)
                _customView.present(haptic: .warning)
            }
        }
    }
    
    // MARK: - VC helpers
    @objc func update(){
        if let customView = self.customView {
            let updater = BundleUpdater.sharedInstance();
            updater.checkAndReplaceBundle(nil)
            customView.dismiss()
            //default duration of animation is 0.6
            Timer.scheduledTimer(timeInterval: 0.6, target: self, selector: #selector(dismissVC), userInfo: nil, repeats: false)
        }
    }
    @objc func dismissVC(){
        self.dismiss(animated: false);
    }
    
    // MARK: - View Props
    func displayAlertProps(alert:SPIndicatorView){
        alert.presentSide = .top
        alert.duration = self.isNecessaryUpdate ?  .infinity : 30
        alert.dismissByDrag = !self.isNecessaryUpdate
        // dismissByDrag is not sufficient
        if(self.isNecessaryUpdate){
            // override gesture recognizer
            let panGesture = UIPanGestureRecognizer(target: self, action: nil)
            alert.addGestureRecognizer(panGesture)
        }
        alert.layout.margins.left = 12
        alert.layout.margins.right = 12
    }
    func displayBTNProps(button: UIButton) {
        button.alpha = 1
        button.layer.cornerRadius = 25
        button.isUserInteractionEnabled = true
    }
    
}

