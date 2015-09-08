//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"


var op = Optional.Some(2)
let non = Optional<Int>.None

let res = op.map { $0 + 1 }
res



let n = non.flatMap { $0 + 1 }
n


let n2 = non.flatMap { $0 == nil ? 1 : 1 }
n2


let arr = [1, 2, 3]

//let arr2 = arr.map { $0.first! + 1}
//arr2

let arr3 = arr.flatMap({ [$0] })
arr3
