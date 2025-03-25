//
//  carList.swift
//  DriveShare
//
//  Created by Christopher Woods on 3/25/25.
//

import SwiftUI

struct UsersCarListView: View {
    @EnvironmentObject var firestoreManager: FirestoreManager
    let gridItems = [GridItem(.flexible()), GridItem(.flexible())]
    let currentUser = try? AuthenticationManager.shared.getAuthUser().email ?? "No User"
    var body: some View {
        
        VStack{
            Text("Your Cars")
            ScrollView{
                LazyVGrid(columns: gridItems, spacing: 20) {
                    ForEach(firestoreManager.Cars, id: \.id) { Car in
                        VStack(alignment: .leading) {
                            Text(Car.CarModel).font(.headline)
                            Text("\(Car.Pricing)")
                        }
                    }
                }.onAppear {
                    if let currentUser{
                        firestoreManager.fetchUserCars(email: currentUser)
                    }

                }
            }
        }
    }
}

#Preview {
    UsersCarListView()
}
