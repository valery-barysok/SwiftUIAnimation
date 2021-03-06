//
//  SharpPositionModifier.swift
//  animationTest
//
//  Created by Франчук Андрей on 17.05.2020.
//  Copyright © 2020 Франчук Андрей. All rights reserved.
//

import SwiftUI

struct WaveDescription{
    var ind: Int
    var totalWavesCount: Int
    var width: CGFloat
    var baseColor: Color
    var gradientLength: CGFloat
}


struct SharpWavePosition: AnimatableModifier {
    let wave: WaveDescription
    let animationHandler: AnimationHandler
    var time: CGFloat
    var currentPosition: CGFloat
//    var startTime = Date()
    private let timing: TimingCurve
    public var animatableData: CGFloat {
        get { time}
        set {
            if animationHandler.isStarted{
                self.time = newValue
                if self.time != self.animationHandler.currentAnimationPosition{
                    self.animationHandler.currentAnimationPosition = self.time
                }
            }
            let currentTime = newValue - CGFloat(Int(newValue))
            self.currentPosition = SharpWavePosition.calculate(forWave: wave.ind, ofWaves: wave.totalWavesCount, overTime: currentTime)
            if currentPosition < 0.01{
                animationHandler.currentWaveBaseColor = wave.baseColor
            }
        }
    }
    init(wave: WaveDescription, time: CGFloat, animationHandler: AnimationHandler){
        self.wave = wave
        self.time = time
        self.timing = TimingCurve.superEaseIn(duration: 1)
        self.animationHandler = animationHandler
        self.currentPosition = 0
    }
    
    static func calculate(forWave: Int, ofWaves: Int, overTime: CGFloat) -> CGFloat{

        let time = overTime - CGFloat(Int(overTime))
        let oneWaveWidth = CGFloat(1) / CGFloat(ofWaves)
        let initialPosition = oneWaveWidth * CGFloat(forWave)
        let currentPosition = initialPosition + time
        let fullRounds = Int(currentPosition)
        var result = currentPosition - CGFloat(fullRounds)
        if fullRounds > 0 && result == 0{
            // at the end of the round it should be 1, not 0
            result = 1
        }
 //       print("wave \(forWave) in time \(overTime) was at position \(result)")
        return result
    }

    func body(content: Content) -> some View {
        let oneWaveWidth = CGFloat(1) / CGFloat(wave.totalWavesCount)
        var thisIsFirstWave = false
        if currentPosition < oneWaveWidth{
            thisIsFirstWave = true
        }
        //recalculate position using timing curve just like the built in animation do
        let animatedPosition = timing.getY(onX: currentPosition)
        
//        if wave.ind == 0{
//            print("current animation position \(currentTime)")
//        }
        return
            Group{
                content
                    .offset(x: -wave.width + animatedPosition * (wave.width +  wave.gradientLength),
//                            .offset(x: -wave.width + currentPosition * (wave.width +  wave.gradientLength),
                            //to watch how waves move uncoment this
//                                y: CGFloat(self.wave.ind * 20))
                                           y:0)
//                    .zIndex(-Double(animatedPosition))
                    .zIndex(-Double(currentPosition))
                    //.transition(.identity)
                       .animation(nil)

                if thisIsFirstWave{
                    content
                        .offset(x: wave.gradientLength + animatedPosition * (wave.width +  wave.gradientLength),
//                        .offset(x: wave.gradientLength + currentPosition * (wave.width +  wave.gradientLength),
                                y: 0)
//                               y: -20)
                        .zIndex(-2)
                       // .transition(.identity)
                        .animation(nil)
                }
            }
    }
}

extension View{
    func positionOfSharp(wave: WaveDescription, inTime: CGFloat, animationHandler: AnimationHandler) -> some View {
        return self.modifier(SharpWavePosition(wave: wave, time: inTime, animationHandler: animationHandler))
    }
}


struct SharpPositionModifier_Previews: PreviewProvider {
    static var previews: some View {
        AdvancedTimingRainbow()
    }
}
