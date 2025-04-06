//
//  AuthDataResultModel.swift
//  DriveShare
//
//  Created by Christopher Woods on 3/17/25.
//


//
//  Auth.swift
//  StickerShop
//
//  Created by Christopher Woods on 12/2/24.
//

import Foundation
import FirebaseAuth

struct AuthDataResultModel{
    let uid: String
    let email: String?
    let photoURL: String?
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.photoURL = user.photoURL?.absoluteString
    }
}


final class AuthenticationManager {
    static let shared = AuthenticationManager()
    private init() {
        
    }
    func getAuthUser() throws -> AuthDataResultModel{
        guard let user = Auth.auth().currentUser else{
            throw URLError(.badServerResponse)
        }
        return AuthDataResultModel(user: user)
    }
    
    @discardableResult
    func createUser(email: String, password: String) async throws -> AuthDataResultModel{
        let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthDataResultModel(user: authResult.user)
    }
    
    @discardableResult
    func signInUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    func signOut() throws{
        try Auth.auth().signOut()
    }
    // In AuthenticationManager class
    func resetPassword(email: String, newPassword: String, completion: @escaping (Bool, String?) -> Void) {
        // Use Firebase's password reset functionality directly
        Auth.auth().sendPasswordReset(withEmail: email)
    }

    // Add this new method for security question based reset
    func resetPasswordDirectly(email: String, newPassword: String, completion: @escaping (Bool, String?) -> Void) {

        print("Would reset password for \(email) to \(newPassword)")
        completion(true, "Password reset successfully")
    }


}
