//
//  TestViewController.swift
//  RCTest
//
//  Created by Sergey Sedov on 04/09/15.
//  Copyright (c) 2015 Sergey Sedov. All rights reserved.
//

import UIKit
import ReactiveCocoa

class TestViewController: UIViewController {

    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn2: UIButton!
    
    @IBOutlet weak var textField: UITextField!
    
    let viewModel: ViewModel;
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel;
        super.init(nibName: "TestViewController", bundle: NSBundle.mainBundle());
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.bind();
    }
    
    func bind() {
        self.viewModel.name.producer.start(next: { self.btn1.setTitle($0, forState: UIControlState.Normal)})
        self.viewModel.text.producer.start(next: { self.textField.text = $0})
        
        self.textField.rac_textSignal().toSignalProducer().start(next: {
            if let str = $0 as? String {
                self.viewModel.text.value = str;
            }
        });
        
        self.btn2.rac_signalForControlEvents(UIControlEvents.TouchUpInside).toSignalProducer().start(next: {sender in
                self.update();
            }
        );
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func update() {
        self.viewModel.name.value = "123";
        self.viewModel.text.value = "77777"
    }
    
}

