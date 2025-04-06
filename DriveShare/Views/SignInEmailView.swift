//
//  SignInEmailView.swift
//  StickerShop
//
//  Created by Christopher Woods on 12/2/24.
//

import SwiftUI


final class SignInEmaiLViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    
    enum MyError: Error {
        case invalidField(String)
    }
    func signIn() async throws -> Bool{
        guard !email.isEmpty, !password.isEmpty else{
            print("No email or password found")
            return true
        }


        try await AuthenticationManager.shared.signInUser(email: email, password: password)
        return false
      
    }
    func signUp() async throws -> Bool{
        guard !email.isEmpty, !password.isEmpty else{
            throw MyError.invalidField("Invalid Email or Password")
        }


        try await AuthenticationManager.shared.createUser(email: email, password: password)
        return true
      
    }
}
struct SignInEmailView: View {
    @EnvironmentObject var firestoreManager: FirestoreManager
    @EnvironmentObject private var viewModel: SignInEmaiLViewModel
    @Binding var showSignInView: Bool
    
    var body: some View {
        VStack{
            Text("Sign In")
                .bold()
                .font(.title)
            Spacer()
            TextField("Email...", text: $viewModel.email)
                .padding()
                .background(.gray.opacity(0.4))
                .cornerRadius(10)
            
            SecureField("Password",text: $viewModel.password)
                .padding()
                .background(.gray.opacity(0.4))
                .cornerRadius(10)
            HStack{
                Button{
                    Task{
                        do{
                            showSignInView = try await viewModel.signIn()
                            
                        }
                        catch {
                            print(error)
                        }
                    }
                    
                    
                }label: {
                    Text("Sign In")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(height: 55)
                        .padding(.horizontal, 20)
                        .background(.blue)
                        .cornerRadius(10)
                        .padding()
                }
        
                
                
            }
            
            Spacer()
            
            NavigationLink(destination: ForgotPasswordView().environmentObject(firestoreManager)) {
                Text("Forgot Password?")
                    .foregroundColor(.blue)
                    .font(.subheadline)
            }
            .padding(.top, 8)
            
            
            
            
        }
        .padding()
        .navigationTitle("")
    }
}

#Preview {
    SignInEmailView(showSignInView: .constant(false))
}
