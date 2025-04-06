//
//  PasswordRecoveryProxy.swift
//  DriveShare
//
//  Created by Christopher Woods on 4/6/25.
//


class PasswordRecoveryProxy {
    private let firestoreManager: FirestoreManager
    private let authManager: AuthenticationManager
    private var recoveryAttempts: [String: Int] = [:]
    private let maxAttempts = 3
    
    init(firestoreManager: FirestoreManager, authManager: AuthenticationManager) {
        self.firestoreManager = firestoreManager
        self.authManager = authManager
    }
    
    func initiatePasswordRecovery(email: String, completion: @escaping (Bool, [String]) -> Void) {

            
            // Check for too many attempts
            if let attempts = self.recoveryAttempts[email], attempts >= self.maxAttempts {
                completion(false, [])
                return
            }
            
            // Get security questions
            self.firestoreManager.getSecurityQuestions(forEmail: email) { questions in
                completion(!questions.isEmpty, questions)
            }
        }
    
    func verifyAnswersAndResetPassword(email: String, answers: [(question: String, answer: String)], 
                                      newPassword: String, completion: @escaping (Bool, String) -> Void) {
        // Increment attempt counter
        recoveryAttempts[email] = (recoveryAttempts[email] ?? 0) + 1
        
        firestoreManager.verifySecurityAnswers(email: email, answers: answers) { isVerified in
            guard isVerified else {
                completion(false, "Security answers do not match our records.")
                return
            }
            
            // Reset password if verified
            self.authManager.resetPassword(email: email, newPassword: newPassword) { success, error in
                if success {
                    // Clear attempt counter on success
                    self.recoveryAttempts.removeValue(forKey: email)
                    completion(true, "Password has been reset successfully.")
                } else {
                    completion(false, error ?? "Failed to reset password.")
                }
            }
        }
    }
}
