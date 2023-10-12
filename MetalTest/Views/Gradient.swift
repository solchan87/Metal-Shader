//
//  Gradient.swift
//  MetalTest
//
//  Created by Tom on 10/13/23.
//

import SwiftUI

struct Gradient: View {
  private var date = Date()
  
  var body: some View {
    VStack {
      TimelineView(.animation) { context in
        Color.pink
          .frame(width: 350, height: 350)
          .colorEffect(
            ShaderLibrary.gradientify(
              .boundingRect,
              .float(
                context.date.timeIntervalSince1970
                - date.timeIntervalSince1970
              )
            )
          )
          .clipShape(RoundedRectangle(cornerRadius: 16))
      }
    }
    .padding()
  }
}

#Preview {
  ContentView()
}
