//
//  ContentView.swift
//  Sunset
//
//  Created by Hamon Parvizi on 5/2/20.
//  Copyright © 2020 Hamon Parvizi. All rights reserved.
//

import SwiftUI
import Solar
import CoreLocation
struct ContentView: View {
   
    @ObservedObject var sunsetLabel: SunsetString
    var body: some View {
        ZStack {
            Color.black
            .edgesIgnoringSafeArea(.all)
            HStack {
                Image("MainViewIcon")
                ZStack<Text> {
                    return Text(self.sunsetLabel.label).foregroundColor(Color.white)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(sunsetLabel: SolarManager.instance.sunsetString)
    }
}
