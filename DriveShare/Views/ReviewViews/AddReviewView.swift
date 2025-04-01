//
//  AddReviewView.swift
//  DriveShare
//
//  Created by Christopher Woods on 4/1/25.
//

import SwiftUI
struct AddReviewView: View {
    let car: Car
    let recipientId: String
    let isOwnerReview: Bool
    let onComplete: () -> Void
    
    @EnvironmentObject var firestoreManager: FirestoreManager
    @State private var rating: Int = 0
    @State private var title: String = ""
    @State private var comment: String = ""
    @State private var isSubmitting = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Rating")) {
                    VStack(alignment: .center, spacing: 10) {
                        Text("Tap to rate")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        StarRatingView(rating: $rating)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                }
                
                Section(header: Text("Review Title")) {
                    TextField("Enter a title for your review", text: $title)
                }
                
                Section(header: Text("Review")) {
                    TextEditor(text: $comment)
                        .frame(minHeight: 100)
                }
                
                Section {
                    Button(action: submitReview) {
                        if isSubmitting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Text("Submit Review")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(rating == 0 || title.isEmpty || comment.isEmpty || isSubmitting)
                }
            }
            .navigationTitle(isOwnerReview ? "Review Renter" : "Review Car")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func submitReview() {
        isSubmitting = true
        
        firestoreManager.addReview(
            carId: car.id ?? "",
            recipientId: recipientId,
            rating: rating,
            title: title,
            comment: comment,
            isOwnerReview: isOwnerReview
        )
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isSubmitting = false
            onComplete()
            dismiss()
        }
    }
}
