//
//  AdvancedTimingRainbow.swift
//  animationTest
//
//  Created by Франчук Андрей on 16.05.2020.
//  Copyright © 2020 Франчук Андрей. All rights reserved.
//

import SwiftUI
struct WaveGeometry{
    var topRadius: CGFloat
    var bottomRadius: CGFloat
    var gradientLength: CGFloat
    var height: CGFloat? = nil
}

class AnimationHandler: ObservableObject{
    @Published var isStarted: Bool = true
    @Published var isShown: Bool = false
    let rainbowColors: [Color] = [.red, .green, .blue]
    var currentAnimationPosition: CGFloat = 0
    var currentWaveBaseColor: Color
    var currentTransitionInBaseColor: Color = .clear
    var currentTransitionOutBaseColor: Color = .clear
    var waveGeometry: WaveGeometry
    init(topRadius: CGFloat = 7, bottomRadius: CGFloat = 18, gradientLength: CGFloat = 8){
        self.waveGeometry = WaveGeometry(topRadius: topRadius, bottomRadius: bottomRadius, gradientLength: gradientLength)
        self.currentWaveBaseColor = .clear
    }
}

struct AdvancedTimingRainbow: View {
    let height: CGFloat = 40
    let middleSpacer: CGFloat = 0.4//whole width = 1
    @ObservedObject var animationHandler = AnimationHandler()
    var body: some View {
        VStack{
            SharpRainbowView(animationHandler: self.animationHandler)
                .frame(height: self.height)
            Button(action: {
                self.animationHandler.isStarted.toggle()
            }){
                Text(self.animationHandler.isStarted ? "stop" : "start")
            }
        }
        .frame(width: 250)
        .border(Color.black, width: 2)
    }
}



struct SharpRainbowView: View{
    let waves: [SharpGradientBorder]
    var animation: Animation = Animation.linear(duration: 1).repeatForever(autoreverses: false)
    //@ObservedObject
    var animationHandler: AnimationHandler
    @State var rainbowPosition: CGFloat = 0
    init(animationHandler: AnimationHandler,
        backgroundColor: Color = .clear
    ){
        self.animationHandler = animationHandler
        let bottomRadius = animationHandler.waveGeometry.bottomRadius
        let topRadius = animationHandler.waveGeometry.topRadius
        let gradientLength = animationHandler.waveGeometry.gradientLength
        let rainbowColors = animationHandler.rainbowColors
        guard var lastColor = rainbowColors.last else {fatalError("no colors to display in rainbow")}
        var allWaves = [SharpGradientBorder]()
        for color in rainbowColors{
            let view = SharpGradientBorder(start: color,
                                      end: lastColor,
                                      bottomRadius: bottomRadius,
                                      topRadius: topRadius,
                                      gradientLength: gradientLength)
            allWaves.append(view)
            lastColor = color
        }
        self.waves = allWaves
    }
    var body: some View{
        GeometryReader{geometry in
            VStack{
                ZStack{
                    ForEach(self.waves.indices, id: \.self){ind in
                        self.waves[ind]
                            .positionOfSharp(wave: WaveDescription(ind: ind,
                                                    totalWavesCount: self.waves.count,
                                                    width: geometry.size.width,
                                                    baseColor: self.waves[ind].end,
                                                    gradientLength: self.waves[ind].bottomRadius + self.waves[ind].topRadius),
                                             inTime: self.rainbowPosition,
                                             animationHandler: self.animationHandler)
                            .animation(self.animationHandler.isStarted ? self.animation : .linear(duration: 0))
                    }
                }
                .clipped()
            }

        }
        .onAppear(){
  //          if self.animationHandler.isStarted{
                self.rainbowPosition = 1
  //          }
        }
        .onReceive(animationHandler.objectWillChange){
             let newValue = self.animationHandler.isStarted
             if newValue == false{
                let newPosition = self.animationHandler.currentAnimationPosition
                print("animated from \(self.rainbowPosition - 1) to \(self.rainbowPosition) stopped at \(newPosition)")
               //  withAnimation(.none){//not working:(((
                    self.rainbowPosition = newPosition
               //  }
             }else {
               //   self.startTime = Date()
//                withAnimation{
                  self.rainbowPosition += 1
//                }
            }
        }

    }
}

struct AdvancedTimingRainbow_Previews: PreviewProvider {
    static var previews: some View {
        AdvancedTimingRainbow()
    }
}
