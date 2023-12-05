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
@objc(AlertViewTest)
class AlertViewTest: UIViewController {
    var customView: SPIndicatorView?
    var btn: UIButton?
    
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
        if(btn == nil ){
            self.btn = UIButton(frame:CGRect(x:0, y: 0, width: 50, height: 50))
        }
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View controller states
    override func viewDidLoad() {
        if let _customView = self.customView, let _btn = self.btn {
            self.displayAlertProps(alert: _customView)
            self.displayBTNProps(button: _btn)
            DispatchQueue.main.async {
                _btn.addTarget(self, action: #selector(self.update), for: .touchUpInside)
                _customView.addSubview(_btn)
                _customView.present(haptic: .warning)
            }
        }
    }
    
    // MARK: - VC helpers
    @objc func update(){
        if let customView = self.customView {
            var updater = BundleUpdater.sharedInstance();
            updater.reload();
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
        alert.duration = .infinity // TODO infinity or long time ?
        alert.layout.margins.left = 12
        alert.layout.margins.right = 12
    }
    func displayBTNProps(button: UIButton) {
        //button.setTitle("update", for: .normal)
        //button.backgroundColor = UIColor.red;
        button.alpha = 1;
        button.layer.cornerRadius = 25;
    }
    
}

