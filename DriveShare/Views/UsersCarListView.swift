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
        VStack {
            Text("Your Cars")
            ScrollView {
                LazyVGrid(columns: gridItems, spacing: 20) {
                    ForEach(firestoreManager.Cars, id: \.id) { Car in
                        NavigationLink {
                            EditCarView(car: Car).environmentObject(firestoreManager)
                        } label: {
                            VStack(alignment: .leading) {
                                Text(Car.CarModel).font(.headline)
                                Text("$\(Car.Pricing)/day")
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }
                }
                .padding()
                .onAppear {
                    if let currentUser {
                        firestoreManager.setupRealTimeListener(email: currentUser, isUserCars: true)
                    }
                }.onDisappear {
                    firestoreManager.removeListener()
                }
                
            }
        }
    }
}
#Preview {
    UsersCarListView()
}
