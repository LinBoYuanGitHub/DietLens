//
//  CountDownTimer.swift
//  DietLens
//
//  Created by linby on 2018/10/23.
//  Copyright © 2018 NExT++. All rights reserved.
//

import Foundation

protocol CountDownDelegate: class {

    func onCountDownUpdate(displaySeconds: TimeInterval)
}

//Use CountDown timer to implement the global timeLimit counter
class CountDownTimer {
    private var lastRecordTime: TimeInterval!
    private var displaySeconds: TimeInterval = 60
    static var instance = CountDownTimer()
    private var timer: Timer!
    private var isCoolDown = true

    public var delegate: CountDownDelegate?

    private init() {
        lastRecordTime = TimeInterval()
    }

    //consider the case the user exitApp
    public func resume() {
        let diffTime = TimeInterval() - lastRecordTime
        if displaySeconds  - diffTime > 0 {
            displaySeconds -= diffTime
        } else {
            //time reach
            displaySeconds = 0
            isCoolDown  = true
        }
    }

    public func start() {
        timer = Timer.scheduledTimer(timeInterval: displaySeconds, target: self, selector: #selector(updateTime), userInfo: nil, repeats: false)
        isCoolDown = false
    }

    public func getCoolDownFlag() -> Bool {
        return isCoolDown
    }

    @objc func updateTime() {
        displaySeconds -= 1 // countDown function
        lastRecordTime = TimeInterval()
        if displaySeconds <= 0 {
            isCoolDown = true
        }
        //refresh timer UI recall
        if delegate != nil {
            delegate?.onCountDownUpdate(displaySeconds: displaySeconds)
        }
    }

    //receive failure info so fire timer
    public func fireTimer() {
        timer.fire()
        isCoolDown = true
    }

}
