//
//  SignInEmailView.swift
//  StickerShop
//
//  Created by Christopher Woods on 12/2/24.
//

import SwiftUI


struct CreateAccountView: View {
    @StateObject private var viewModel = SignInEmaiLViewModel()
    @Binding var showSignInView: Bool
    @State var errorMessage = ""
    @State private var selectedQuestion1: String = ""
    @State private var selectedQuestion2: String = ""
    @State private var selectedQuestion3: String = ""
    @State private var securityAnswer1: String = ""
    @State private var securityAnswer2: String = ""
    @State private var securityAnswer3: String = ""
    
    var body: some View {
        VStack {
            Text("Create Account")
                .bold()
                .font(.title)
            Spacer()
            
            TextField("Email...", text: $viewModel.email)
                .padding()
                .background(.gray.opacity(0.4))
                .cornerRadius(10)
            
            SecureField("Password", text: $viewModel.password)
                .padding()
                .background(.gray.opacity(0.4))
                .cornerRadius(10)
            
            SecurityQuestionView(number: 1, selectedQuestion: $selectedQuestion1, securityAnswer: $securityAnswer1)
            SecurityQuestionView(number: 2, selectedQuestion: $selectedQuestion2, securityAnswer: $securityAnswer2)
            SecurityQuestionView(number: 3, selectedQuestion: $selectedQuestion3, securityAnswer: $securityAnswer3)
            
           
            

            
            Button{
                Task{
                    do{
                        showSignInView =
                        try await viewModel.signUp()
                        
                    }
                    catch {
                        errorMessage = "\(error)"
                    }
                }
            }label: {
                Text("Sign Up")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(height: 55)
                    .padding(.horizontal, 5)
                    .background(.blue)
                    .cornerRadius(10)
            }
            .padding(10)
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.title2)
                    .foregroundColor(.red)
                    .padding(.top, 10)
            }
            
            Spacer()
            
        }
        .padding()
        .navigationTitle("")
    }
}

#Preview {
    CreateAccountView(showSignInView: .constant(false))
}

struct SecurityQuestionView: View {
    var number: Int
    let securityQuestions = [
        "What is your mother's maiden name?",
        "What was the name of your first pet?",
        "What is the name of the city you were born in?",
    ]
    @Binding var selectedQuestion: String
    @Binding var securityAnswer: String
    var body: some View {
        Text("Question \(number)")
        Picker("Select Security Question \(number)", selection: $selectedQuestion) {
            ForEach(securityQuestions, id: \.self) { question in
                Text(question)
            }
        }

        .padding()
        .background(.gray.opacity(0.4))
        .cornerRadius(10)
        .pickerStyle(MenuPickerStyle())

        TextField("Your Answer", text: $securityAnswer)
            .frame(height: 10)
            .frame(maxWidth: .infinity)
            .padding()
            .background(.gray.opacity(0.4))
            .cornerRadius(10)

    }
}
