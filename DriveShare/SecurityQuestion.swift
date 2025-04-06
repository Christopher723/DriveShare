//
//  SecurityQuestion.swift
//  DriveShare
//
//  Created by Christopher Woods on 4/6/25.
//
import FirebaseFirestore
import SwiftUI

struct SecurityQuestion: Codable, Identifiable {
    @DocumentID var id: String?
    var userId: String
    var questionIndex: Int
    var question: String
    var answer: String
}

struct PasswordRecoveryAttempt: Codable, Identifiable {
    @DocumentID var id: String?
    var email: String
    var timestamp: Date
    var isSuccessful: Bool
    var ipAddress: String?
}
