//
//  Scheduler.swift
//  SmackEmMole
//
//  Created by Dima Gimburg on 4/10/17.
//  Copyright © 2017 Dima Gimburg. All rights reserved.
//
//  ----------------------------------------------------
//  This module is a small self built abstraction for 
//  handling with Swift 3 queues, it was initially built 
//  for a small game I've built where I had to handle 
//  some that were delayed and had to be concurrent.

import Foundation

protocol ProtocolTaskDispatcher {
    func getUniqueId() -> Int
    func addTask(task: Task)
}

protocol ProtocolTask {
    func invoke()
}

class ConcurrentDelayedTaskDispatcher : ProtocolTaskDispatcher {
    
    private let queueLabelPrefix = "com.taskdispatcher.cuncurentDelayed_"
    private var concurrentDelayedQueue: DispatchQueue?
    
    internal func getUniqueId() -> Int {
        return ObjectIdentifier(self).hashValue
    }
    
    func addTask(task: Task) {
        guard let delayedTask = task as? DelayedTask else {
            return
        }
        
        if concurrentDelayedQueue == nil {
            concurrentDelayedQueue = DispatchQueue(
                label: queueLabelPrefix + String(getUniqueId()),
                qos: .userInitiated,
                attributes: [.concurrent, .initiallyInactive]
            )
        }
        
        concurrentDelayedQueue!.asyncAfter(deadline: .now() + delayedTask.delay, execute: {
            task.invoke()
        })
        
    }
    
    func dispatch() {
        guard (concurrentDelayedQueue != nil) else {
            return
        }
        print(Date())
        concurrentDelayedQueue!.activate()
    }
}

class Task: ProtocolTask {
    var task: () -> Void // the task itself
    
    init(task: @escaping () -> Void){
        self.task = task
    }
    
    func invoke(){
        task()
    }
    
}

class DelayedTask: Task {
    
    var delay: Double = 0 // number of seconds after start the task would be invoked
    
    init(task: @escaping () -> Void, delay: Double){
        super.init(task: task)
        self.delay = delay
    }
}
