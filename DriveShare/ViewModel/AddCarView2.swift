////
////  AddCarView.swift
////  DriveShare
////
////  Created by Christopher Woods on 4/1/25.
////
//
//
//import SwiftUI
//import FirebaseFirestore
//struct AddCarView: View {
//    @EnvironmentObject var firestoreManager: FirestoreManager
//    @State var CarModel: String = ""
//    @State var Availability: [String] = [""]
//    @State var Mileage: Int = 0
//    @State var PickUpLocation: GeoPoint = GeoPoint(latitude: 0, longitude: 0)
//    @State var Pricing: Int = 0
//    @State var Year: Int = 0
//    @State var newAvailability: String = ""
//    let mediator = CarMediator()
//    var body: some View {
//        VStack {
//            TextField("Car Model"
//                      , text: $CarModel)
//            .padding()
//            TextField("Availability"
//                      , text: $newAvailability)
//            .padding()
//            TextField("Mileage"
//                      , value: $Mileage, formatter: numberFormatter)
//            .keyboardType(.numberPad)
//            .padding()
//            TextField("Pick Up Location"
//                      , text: Binding(
//                        get: { "\(PickUpLocation.latitude), \(PickUpLocation.longitude)" },
//                        set: { newValue in
//                            let parts = newValue.split(separator: "
//                                                       ,
//")
//                                                       if parts.count == 2,
//                                                       let lat = Double(parts[0].trimmingCharacters(in: .whitespaces)),
//                                                       let lon = Double(parts[1].trimmingCharacters(in: .whitespaces)) {
//                                self.PickUpLocation = GeoPoint(latitude: lat, longitude: lon)
//                            }
//                                                       }
//                            ))
//                                .padding()
//                            TextField("Pricing"
//                                      , value: $Pricing, formatter: numberFormatter)
//                            .keyboardType(.numberPad)
//                            .padding()
//                            TextField("Year"
//                                      , value: $Year, formatter: numberFormatter)
//                            .keyboardType(.numberPad)
//                            .padding()
//                            Button(action: {
//                                Availability.append(newAvailability)
//                                mediator.addCar(CarModel: CarModel, Availability: Availability, Mileage: Mileage,
//                                                PickUpLocation: PickUpLocation, Pricing: Pricing, Year: Year, userId: "userEmail")
//                            }, label: {
//                                Text("Add Car")
//                            })
//                        }
//                            .padding()
//                        }
//                        private var numberFormatter: NumberFormatter {
//                            let formatter = NumberFormatter()
//                            formatter.numberStyle =
//                                .decimal
//                            formatter.zeroSymbol = ""
//                            return formatter
//                        }
//                        }
//                        class CarMediator {
//                            var firestoreManager = FirestoreManager()
//                            func addCar(CarModel: String, Availability: [String], Mileage: Int, PickUpLocation: GeoPoint,
//                                        Pricing: Int, Year: Int, userId: String) {
//                                firestoreManager.addCar(CarModel: CarModel, Availability: Availability, Mileage: Mileage,
//                                                        PickUpLocation: PickUpLocation, Pricing: Pricing, Year: Year, userId: userId)
//                            }
//                        }
//                        class FirestoreManager {
//                            func addCar(CarModel: String, Availability: [String], Mileage: Int, PickUpLocation: GeoPoint,
//                                        Pricing: Int, Year: Int, userId: String) {
//                                // Implementation for adding the car to Firestore
//                            }
//                        }
