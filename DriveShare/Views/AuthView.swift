//
//  AuthView.swift
//  StickerShop
//
//  Created by Christopher Woods on 12/2/24.
//

import Foundation
import SwiftUI

struct AuthView: View{
    @Binding var showSignInView: Bool
    @EnvironmentObject var firestoreManager: FirestoreManager
    var body: some View{
        NavigationView {
            VStack{
                Text("Welcome to Drive Share")
                    .font(.title)
                    .bold()
                Spacer()
                
                NavigationLink{
                    CreateAccountView(showSignInView: $showSignInView).environmentObject(firestoreManager)
                } label:{
                    Text("Create Account")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(.gray.opacity(0.7))
                        .cornerRadius(10)
                    
                }
                NavigationLink{
                    SignInEmailView(showSignInView: $showSignInView).environmentObject(firestoreManager)
                } label:{
                    Text("Sign in with Email")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(.blue)
                        .cornerRadius(10)
                    
                }
                Spacer()

            }
            .padding()
            .navigationTitle("")
            
        }
    }
}

#Preview{
    AuthView(showSignInView: .constant(false))
}
