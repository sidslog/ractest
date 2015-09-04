//
//  TestSignal.swift
//  RCTest
//
//  Created by Sergey Sedov on 04/09/15.
//  Copyright (c) 2015 Sergey Sedov. All rights reserved.
//

import UIKit
import ReactiveCocoa


class TestObject: NSObject {
    
    var text = "";
    
}


class LongRunningTask {

    let (signal, sink) = Signal<String, NoError>.pipe();
    
    
    var queue = dispatch_get_global_queue(0, 0);
    let group = dispatch_group_create();
    
    func execute() {
        
        dispatch_async(queue, { () -> Void in
            for i in 1...10 {
                
                let time = dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Double(i) * Double(NSEC_PER_SEC) ));
                
                dispatch_group_enter(self.group);
                
                dispatch_after(time, self.queue, { () -> Void in
                    sendNext(self.sink, "\(i)");
                    dispatch_group_leave(self.group);
                })
                
            }
            
            dispatch_group_wait(self.group, DISPATCH_TIME_FOREVER);
            sendCompleted(self.sink)
        })
        
    }
    
    
}

class ProducerSubscriber {
    let producer: SignalProducer<String, NoError>;
    
    init(producer: SignalProducer<String, NoError>, name: String) {
        self.producer = producer;
        
        self.producer |> start(next: { println("\(name): \($0)") } , completed: { println("Completed: \(name)")})
    }
    
}

class TestSignal: NSObject {
   
    let (testSignal, testSink) = Signal<String, NoError>.pipe();
    let longTask = LongRunningTask()
    let (testProducerVar, testProducerSink) = SignalProducer<String, NoError>.buffer(5)
    
    // simple test
    func test() {
        testSignal
            |> map {  $0.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) }
            |> observe(next: println, completed: { println("Completed") })
        
        
        sendNext(testSink, "е");
        sendNext(testSink, "2");
        sendCompleted(testSink);
    }

    // test long running task
    func testLongRunning() {
        longTask.signal
            |> observe(next: println, completed: { println("Completed") })
        
        longTask.execute()
    }
    
    // test kvo
    func testObserve() {
        var object = TestObject();
        object.rac_valuesAndChangesForKeyPath("text", options: NSKeyValueObservingOptions.New, observer: self).subscribeNext({ println("\($0)") }, completed: { println("Completed") })
        object.text = "4"
    }
    
    // test producer
    func testProducer() {
        self.testProducerVar |> start(next: println, completed: { println("Completed")})
        
        let s1 = ProducerSubscriber(producer: self.testProducerVar, name: "Subscriber1");
        let s2 = ProducerSubscriber(producer: self.testProducerVar, name: "Subscriber2");
        
        sendNext(self.testProducerSink, "123");
        sendCompleted(self.testProducerSink);
    }
    
}



