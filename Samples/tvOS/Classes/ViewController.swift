//
//  ViewController.swift
//  tvOS
//
//  Copyright © 2019 The Home Assistant Authors
//  Licensed under the Apache 2.0 license
//  For more information see https://github.com/home-assistant/Iconic
//

import UIKit
import Iconic

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var upButton: UIButton!
    @IBOutlet weak var downButton: UIButton!

    var scale: UInt = 10
    let maxScale: UInt = 50
    let buttonSize = CGSize(width: 60, height: 60)

    override func viewDidLoad() {

        super.viewDidLoad()

        upButton.setIconImage(withIcon: .angleUpIcon, size: buttonSize, color: nil, forState: .normal)
        downButton.setIconImage(withIcon: .angleDownIcon, size: buttonSize, color: nil, forState: .normal)

        updateImage(scale)
    }

    @IBAction func didPress(up sender: UIButton) {

        if scale > maxScale {
            return
        }

        scale += 2
        updateImage(scale)
    }

    @IBAction func didPress(down sender: UIButton) {

        if scale <= 2 {
            return
        }

        scale -= 2
        updateImage(scale)
    }

    func updateImage(_ scale: UInt) {

        let width = CGFloat(20 * scale)
        let imgSize = CGSize(width: width, height: width)
        let image = FontAwesomeIcon.githubAltIcon.image(ofSize: imgSize, color: .black)

        imageView.image = image

        let transition = CATransition()
        transition.duration = 0.05
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        transition.type = kCATransitionFade

        imageView.layer.add(transition, forKey: nil)
    }
}
