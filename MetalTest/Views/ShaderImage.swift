//
//  ShaderImage.swift
//  MetalTest
//
//  Created by Tom on 10/12/23.
//

import SwiftUI

public struct ShaderImage: View {
  let image: String
  let contentMode: ContentMode
  
  public init(_ image: String, contentMode: ContentMode = .fill) {
    self.image = image
    self.contentMode = contentMode
  }
  
  public var body: some View {
    Color.clear
      .overlay {
        Image(self.image, bundle: nil)
          .resizable()
          .aspectRatio(contentMode: self.contentMode)
      }
      .contentShape(Rectangle())
      .clipShape(Rectangle())
  }
}
