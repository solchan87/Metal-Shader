//
//  Wave.swift
//  MetalTest
//
//  Created by Tom on 10/13/23.
//

import SwiftUI

struct Wave: View {
  @State private var text: String = "AAAA"
  
  private var date = Date()
  
  var body: some View {
    TimelineView(.animation) { context in
      VStack(spacing: 40) {
        Text(self.text)
          .font(.system(size: 50, weight: .heavy, design: .rounded))
          .foregroundStyle(.white)
          .distortionEffect(
            ShaderLibrary.wave(
              .float(
                context.date.timeIntervalSince1970
                - date.timeIntervalSince1970
              )
            ),
            maxSampleOffset: .init(width: 350, height: 350)
          )
        
        Button {
          self.text += "A"
        } label: {
          Text("Add Text")
            .font(.system(size: 25, weight: .semibold, design: .rounded))
            .foregroundStyle(.white)
        }
      }
    }
  }
}

