//
//  ContentView.swift
//  MetalTest
//
//  Created by Tom on 10/1/23.
//

import SwiftUI

struct ContentView: View {
  var body: some View {
    NavigationStack {
      List {
        NavigationLink(destination: Wave()) {
          Text("Wave")
        }
        NavigationLink(destination: Gradient()) {
          Text("Gradientify")
        }
        NavigationLink(destination: CRT()) {
          Text("Remove Red")
        }
        NavigationLink(destination: CRT2()) {
          Text("Gradient Subtract")
        }
        NavigationLink(destination: RainDrop()) {
          Text("Pixel Peep")
        }
      }
      .navigationTitle("Shader")
    }
  }
}

#Preview {
  ContentView()
}
