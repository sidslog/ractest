//
//  ViewController.swift
//  RCTest
//
//  Created by Sergey Sedov on 04/09/15.
//  Copyright (c) 2015 Sergey Sedov. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func onButton(sender: AnyObject) {
        
        let model = ViewModel();
        model.name.value = "test button";
        
        let ctrl = TestViewController(viewModel: model)
        self.presentViewController(ctrl, animated: true, completion: nil);
    }
}

