//
//  ReviewsListView.swift
//  DriveShare
//
//  Created by Christopher Woods on 4/1/25.
//

import SwiftUI

struct ReviewsListView: View {
    let carId: String?
    let userId: String?
    let isOwnerReviews: Bool
    
    @EnvironmentObject var firestoreManager: FirestoreManager
    @State private var reviews: [Review] = []
    @State private var isLoading = true
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            } else if reviews.isEmpty {
                Text("No reviews yet")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List(reviews) { review in
                    ReviewRow(review: review)
                }
            }
        }
        .navigationTitle("Reviews")
        .onAppear {
            loadReviews()
        }
    }
    
    private func loadReviews() {
        isLoading = true
        
        if let carId = carId {
            firestoreManager.getReviewsForCar(carId: carId) { fetchedReviews in
                self.reviews = fetchedReviews
                self.isLoading = false
            }
        } else if let userId = userId {
            firestoreManager.getReviewsForUser(userId: userId, isOwnerReviews: isOwnerReviews) { fetchedReviews in
                self.reviews = fetchedReviews
                self.isLoading = false
            }
        } else {
            self.isLoading = false
        }
    }
}

struct ReviewRow: View {
    let review: Review
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(review.reviewerName)
                    .font(.headline)
                Spacer()
                Text(review.timestamp, style: .date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            HStack {
                StarRatingView(rating: .constant(review.rating), size: 15, isEditable: false)
                Spacer()
                Text(review.title)
                    .font(.subheadline)
                    .bold()
            }
            
            Text(review.comment)
                .font(.body)
                .padding(.top, 4)
        }
        .padding(.vertical, 8)
    }
}
