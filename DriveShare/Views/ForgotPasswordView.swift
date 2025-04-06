//
//  ForgotPasswordView.swift
//  DriveShare
//
//  Created by Christopher Woods on 4/6/25.
//
import SwiftUI
struct ForgotPasswordView: View {
    @State private var email = ""
    @State private var securityQuestions: [String] = []
    @State private var answers: [String] = ["", "", ""]
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var message = ""
    @State private var isSuccess = false
    @State private var isVerifying = false
    
    @EnvironmentObject var firestoreManager: FirestoreManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Password Recovery")
                    .font(.title)
                    .bold()
                
                if !isVerifying {
                    // Email input stage
                    TextField("Enter your email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    Button("Continue") {
                        loadSecurityQuestions()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(email.isEmpty)
                    
                } else if !securityQuestions.isEmpty {
                    // Security questions stage
                    Text("Please answer your security questions")
                        .font(.headline)
                    
                    ForEach(0..<min(3, securityQuestions.count), id: \.self) { index in
                        VStack(alignment: .leading) {
                            Text(securityQuestions[index])
                                .font(.subheadline)
                            
                            TextField("Answer", text: $answers[index])
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                    
                    // New password fields
                    TextField("New Password", text: $newPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Confirm Password", text: $confirmPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("Reset Password") {
                        verifyAndResetPassword()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(answers.contains("") || newPassword.isEmpty || newPassword != confirmPassword)
                }
                
                if !message.isEmpty {
                    Text(message)
                        .foregroundColor(isSuccess ? .green : .red)
                        .padding()
                }
            }
            .padding()
        }
        .navigationTitle("Reset Password")
    }
    
    private func loadSecurityQuestions() {
        firestoreManager.getSecurityQuestions(forEmail: email) { questions in
            if questions.isEmpty {
                message = "No account found with this email."
                isSuccess = false
            } else {
                securityQuestions = questions
                isVerifying = true
            }
        }
    }
    
    private func verifyAndResetPassword() {
        guard newPassword == confirmPassword else {
            message = "Passwords don't match"
            isSuccess = false
            return
        }
        
        let qaArray = zip(securityQuestions, answers).map { (question: $0.0, answer: $0.1) }
        
        firestoreManager.verifySecurityAnswers(email: email, answers: qaArray) { verified in
            if verified {
                // Direct password reset (simplified but less secure)
                AuthenticationManager.shared.resetPasswordDirectly(email: email, newPassword: newPassword) { success, resultMessage in
                    self.message = resultMessage ?? "Password reset successful!"
                    self.isSuccess = success
                }
            } else {
                self.message = "Security answers do not match our records."
                self.isSuccess = false
            }
        }
    }
}
