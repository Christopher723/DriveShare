//
//  SettingsView.swift
//  StickerShop
//
//  Created by Christopher Woods on 12/2/24.
//

import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    func logout() throws{
        try AuthenticationManager.shared.signOut()
    }
}

struct SettingsView: View {
    @Binding var showSignInView: Bool
    @StateObject private var viewModel = SettingsViewModel()
    var body: some View {
        VStack{
            List{
                Button("Log Out"){
                    Task{
                        do{
                            try viewModel.logout()
                            
                            showSignInView = true
                        }
                        catch{
                            print(error)
                        }
                    }
                    
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView(showSignInView: .constant(false))
}
