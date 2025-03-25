//
//  FireBaseManager.swift
//  DriveShare
//
//  Created by Christopher Woods on 3/17/25.
//

import Firebase
import FirebaseFirestore

struct Car: Codable,Identifiable{
    @DocumentID var id: String?
    var CarModel: String
    var Availability: [String]
    var Mileage: Int
    var PickUpLocation: GeoPoint
    var Pricing: Int
    var Year: Int
    var userId: String?
}

class FirestoreManager: ObservableObject {
    @Published var Cars: [Car] = []
    private let db = Firestore.firestore()
    
    func fetchData(email: String) {
        self.Cars = []
        //THIS DOESNT FETCH CARS THAT BELONG TO THE USER
        let docRef = db.collection("carList")
        docRef.getDocuments { (snapshot, error) in
            guard error == nil else {
                print("Error fetching documents: \(error?.localizedDescription ?? "")")
                return
            }
            if let snapshot = snapshot, !snapshot.isEmpty {
                for document in snapshot.documents {
                    do{
                        let car = try document.data(as: Car.self)
//                        print("car", car)
//                        print("data", document.data())
                        if car.userId != email{
                            self.Cars.append(car)
                        }
                    }
                    catch{
                        print(error)
                    }
//                    print("Document ID: \(document.documentID)")
//                    print("Data: \(document.data())")
                }
            } else {
                print("No documents found.")
            }
        }
    }
    func fetchUserCars(email: String){
        self.Cars = []
        let docRef = db.collection("carList")
        docRef.getDocuments { (snapshot, error) in
            guard error == nil else {
                print("Error fetching documents: \(error?.localizedDescription ?? "")")
                return
            }
            if let snapshot = snapshot, !snapshot.isEmpty {
                for document in snapshot.documents {
                    do{
                        let car = try document.data(as: Car.self)
                        if car.userId! == email{
                            self.Cars.append(car)
                        }
                    }
                    catch{
                        print(error)
                    }
                }
            } else {
                print("No documents found.")
            }
        }
    }
    
    func addCar(CarModel: String,Availability: [String],Mileage: Int,PickUpLocation: GeoPoint,Pricing: Int,Year: Int,userId: String){
        let docRef = db.collection("carList")
        docRef.addDocument(data: [
            "CarModel": CarModel,
            "Availability": Availability,
            "Mileage": Mileage,
            "PickUpLocation": PickUpLocation,
            "Pricing": Pricing,
            "Year": Year,
            "userId": userId
        ])
    }
}
