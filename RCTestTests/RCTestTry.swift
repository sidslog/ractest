//
//  RCTestTry.swift
//  RCTest
//
//  Created by Sergey Sedov on 08/09/15.
//  Copyright (c) 2015 Sergey Sedov. All rights reserved.
//

import RCTest
import XCTest

public protocol ErrorType2 {
    
}

public enum Error : ErrorType2  {
    case Error1
}

class RCTestTry: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        
        let try = Try<String, NSError>.success("123");
        
        switch try {
        case let .Success(value):
            println(value);
            break;
        case let .Failure(error):
            println(error)
            break
        }
    }
    
    
    func testFlatMap() {
        let try = Try<String, NSError>.success("123");
        
        let next = try.flatMap( {
                return Try.success(count($0))
            }
        )
        XCTAssertEqual(3, next.value!, "");
    }

    func testErrorPropagation() {
        let try = Try<String, ErrorType2>.failure(Error.Error1);
        let next = try.flatMap( {
            return Try.success(count($0))
            }
        )
        
        XCTAssertNil(next.value, "")
        if let error = next.error as? Error {
            switch error {
            case .Error1:
                XCTAssertTrue(true, "");
                break;
            default:
                XCTAssertTrue(false, "");
            }
        }
    }
    
    func testRecoverWith() {
        let try = Try<String, ErrorType2>.failure(Error.Error1);
        let next = try.flatMap( {
            return Try.success(count($0))
            }
            ).recoverWith({
                return Try.success(10);
            })
        
        
        XCTAssertEqual(10, next.value!, "")
        
    }
    
    func testOperator() {
        let try = Try<String, NSError>.success("123");
        let next = try >>- {
            return Try.success(count($0))
        }
        
        XCTAssertEqual(next.value!, 3, "");
    }

}
