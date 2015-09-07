//
//  TestSignal.swift
//  RCTest
//
//  Created by Sergey Sedov on 04/09/15.
//  Copyright (c) 2015 Sergey Sedov. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Result

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
        self.testProducerVar |> start()
        
        let s1 = ProducerSubscriber(producer: self.testProducerVar, name: "Subscriber1");
        let s2 = ProducerSubscriber(producer: self.testProducerVar, name: "Subscriber2");
        
        sendNext(self.testProducerSink, "123");
        sendCompleted(self.testProducerSink);
    }
    
    
    func testExternalProducer() {
        testExtProducer().start( next: println , completed: { println("completed") });
    }
    
    func testExternalProducer2() {
        testExtProducer2().start( next: println , completed: { println("completed") });
    }
    
    func testExternalProducer3() {
        testExtProducer3().start(
            next: { println("\($0). Is main thread: \(NSThread.isMainThread())") } ,
            completed: { println("completed") }
        );
    }
    
}


func testExtProducer() -> SignalProducer<String, NoError> {
    
    return SignalProducer { sink, disposable in
        switch job1() {
        case .Success(let value):
            sendNext(sink, value.value);
            sendCompleted(sink);
        case .Failure(let error):
            sendError(sink, error.value);
        }
        
    }
}


func testExtProducer2() -> SignalProducer<String, NoError> {
    return SignalProducer(result: job1());
}

func testExtProducer3() -> SignalProducer<Int, NoError> {
    let firstProducer = SignalProducer(result: job1());
    let secondProducer = SignalProducer<String, NoError> { sink, disposable in
        asyncJob({ (result) -> () in
            switch result {
            case .Success(let value):
                sendNext(sink, value.value)
                sendCompleted(sink)
            case .Failure(let error):
                sendError(sink, error.value)
            }
        })
    };
    
    return firstProducer |> concat(secondProducer) |> map(mapAsyncResult) |> map({ return $0 + 1 }) |> reduce(0) { $0 + $1 } ;
    
}

func job1() -> Result<String, NoError> {
    return Result.success("job1 done");
}

func job2() -> Result<String, NoError> {
    return Result.success("job2 done");
}

func asyncJob(completion: ((result: Result<String, NoError>) -> ())) {
    let url = NSURL(string: "https://google.com")!
    let task = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            completion(result: Result.success("async done"));
        })
    });
    
    task.resume();
}

func mapAsyncResult(result: String) -> Int {
    return count(result);
}
