//
//  CRT.swift
//  MetalTest
//
//  Created by Tom on 10/12/23.
//

import SwiftUI

struct CRT: View {
  @State private var strength: CGFloat = 0
  private let startDate = Date()
  
  var body: some View {
    VStack {
      TimelineView(.animation) { context in
        ShaderImage("crt")
          .frame(width: 370, height: 320)
          .layerEffect(
            ShaderLibrary.crt(
              .boundingRect,
              .float(
                context.date.timeIntervalSince1970
                - startDate.timeIntervalSince1970
              )
            ),
            maxSampleOffset: .zero
          )
      }
    }
    .padding()
  }
}
