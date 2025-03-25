//
//  EditCarView.swift
//  DriveShare
//
//  Created by Christopher Woods on 3/25/25.
//

import SwiftUI
import FirebaseFirestore

struct EditCarView: View {
    @EnvironmentObject var firestoreManager: FirestoreManager
    @Environment(\.presentationMode) var presentationMode
    @State var car: Car
    
    var body: some View {
        Form {
            TextField("Car Model", text: $car.CarModel)
            TextField("Mileage", value: $car.Mileage, formatter: NumberFormatter())
            TextField("Pricing", value: $car.Pricing, formatter: NumberFormatter())
            TextField("Year", value: $car.Year, formatter: NumberFormatter())
            
            Section(header: Text("Availability")) {
                ForEach(car.Availability.indices, id: \.self) { index in
                    TextField("Date", text: $car.Availability[index])
                }
                Button("Add Date") {
                    car.Availability.append("")
                }
            }
            
            Button("Save Changes") {
                firestoreManager.editCar(
                    id: car.id ?? "",
                    CarModel: car.CarModel,
                    Availability: car.Availability,
                    Mileage: car.Mileage,
                    PickUpLocation: car.PickUpLocation,
                    Pricing: car.Pricing,
                    Year: car.Year,
                    userId: car.userId ?? ""
                )
                presentationMode.wrappedValue.dismiss()
            }
        }
        .navigationTitle("Edit Car")
    }
}
