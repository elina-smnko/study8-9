//
//  ViewController.swift
//  SwiftCleanExample
//
//  Created by Elina Semenko on 17.03.2022.
//

import UIKit
import SwiftClean

class ViewController: UIViewController {
    let cleaner = SwiftCleaner()

    override func viewDidLoad() {
        super.viewDidLoad()
//        cleaner.fileTime = ["txt":60, "hello/app": 40]
        cleaner.addItem()
    }

    @IBAction private func checkAction(_ sender: Any) {
        cleaner.check()
    }
    
}

