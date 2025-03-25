//
//  rootview.swift
//  StickerShop
//
//  Created by Christopher Woods on 12/2/24.
//

import SwiftUI

struct RootView: View {
    @State private var showSignInView: Bool = false
    @EnvironmentObject private var viewModel: SignInEmaiLViewModel
    var body: some View {
        ZStack{
            NavigationStack{
                ContentView(showSignInView: $showSignInView).environmentObject(viewModel)

            }
            

            
        }
        .onAppear(){
            let authUser = try? AuthenticationManager.shared.getAuthUser()
            self.showSignInView = authUser == nil
        }
        .fullScreenCover(isPresented: $showSignInView){
            NavigationStack{
                AuthView(showSignInView: $showSignInView)
            }
        }
    }
}

#Preview {
    RootView()
}
