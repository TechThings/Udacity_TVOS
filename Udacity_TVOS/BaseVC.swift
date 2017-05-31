//
//  BaseVC.swift
//  Udacity_TVOS
//
//  Created by inailuy on 7/15/16.
//
//

import Foundation
import AVKit

class BaseVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGestureRec = UITapGestureRecognizer(target: self, action: #selector(BaseVC.menuButtonPressed(_:)))
        tapGestureRec.allowedPressTypes = [NSNumber(value: UIPressType.menu.rawValue as Int)]
        view.addGestureRecognizer(tapGestureRec)
    }
    
    func menuButtonPressed(_ gesture: UITapGestureRecognizer) {
        navigationController?.popViewController(animated: true)
    }
}
