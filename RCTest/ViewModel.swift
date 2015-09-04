//
//  ViewModel.swift
//  RCTest
//
//  Created by Sergey Sedov on 04/09/15.
//  Copyright (c) 2015 Sergey Sedov. All rights reserved.
//

import UIKit
import ReactiveCocoa


class ViewModel: NSObject {
   
    let name = MutableProperty<String>("")
    let enabled = MutableProperty<Bool>(true)
    let text = MutableProperty<String>("")
    
}
