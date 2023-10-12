//
//  RainDrop.swift
//  MetalTest
//
//  Created by Tom on 10/13/23.
//

import SwiftUI


struct RainDrop: View {
  private let startDate = Date()

  var body: some View {
    VStack {
      TimelineView(.animation) { context in
        Rectangle()
          .frame(width: 350, height: 250)
          .colorEffect(
            ShaderLibrary.rainDrop(
              .image(Image("test", bundle: nil)),
              .boundingRect,
              .float(
                context.date.timeIntervalSince1970
                - startDate.timeIntervalSince1970
              )
            )
          )
      }
    }
    .padding()
  }
}

#Preview {
  ContentView()
}
