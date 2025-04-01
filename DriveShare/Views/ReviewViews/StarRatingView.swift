//
//  StarRatingView.swift
//  DriveShare
//
//  Created by Christopher Woods on 4/1/25.
//

import SwiftUI

struct StarRatingView: View {
    @Binding var rating: Int
    var maxRating: Int = 5
    var size: CGFloat = 30
    var isEditable: Bool = true
    
    var body: some View {
        HStack(spacing: 5) {
            ForEach(1...maxRating, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
                    .foregroundColor(star <= rating ? .yellow : .gray)
                    .onTapGesture {
                        if isEditable {
                            rating = star
                        }
                    }
            }
        }
    }
}
