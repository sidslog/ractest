//
//  Monads.swift
//  RCTest
//
//  Created by Sergey Sedov on 08/09/15.
//  Copyright (c) 2015 Sergey Sedov. All rights reserved.
//

import Foundation
import Box


public enum Try<T, Error> {
    
    case Success(Box<T>)
    case Failure(Box<Error>)
    
    public var value: T? {
        return analize({ $0 }, ifFailure: { _ in nil });
    }
    
    public var error: Error? {
        return analize({ _ in nil }, ifFailure: { $0 });
    }
    
    public init(value: T) {
        self = .Success(Box(value))
    }
    
    public init(error: Error) {
        self = .Failure(Box(error))
    }
    
    public static func success(value: T) -> Try {
        return Try(value: value);
    }
    
    public static func failure(error: Error) -> Try {
        return Try(error: error);
    }
    
    func analize<R>(@noescape ifSuccess: ((T) -> (R)), @noescape ifFailure: ((Error) -> (R))) -> R {
        switch self {
        case let .Success(value):
            return ifSuccess(value.value);
        case let .Failure(error):
            return ifFailure(error.value);
        }
    }
    
    public func flatMap<U>(@noescape transform: T -> Try<U, Error>) -> Try<U, Error> {
        return  analize(transform, ifFailure: { (error) -> (Try<U, Error>) in
            return Try<U, Error>.failure(error);
        })
    }
    
    public func recover(@noescape value: (() -> T)) -> T {
        return self.value ?? value();
    }
    
    public func recoverWith(@noescape result: (() -> (Try<T, Error>))) -> Try<T, Error> {
        return analize({ _ in self
            }, ifFailure: { _ in result() })
    }
}

infix operator >>- {
// Left-associativity so that chaining works like you’d expect, and for consistency with Haskell, Runes, swiftz, etc.
associativity left

// Higher precedence than function application, but lower than function composition.
precedence 100
}

public func >>- <T, U, Error> (result: Try<T, Error>, @noescape transform: T -> Try<U, Error>) -> Try<U, Error> {
    return result.flatMap(transform);
}

