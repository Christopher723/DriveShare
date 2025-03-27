import SwiftUI
import Firebase
import FirebaseFirestore

struct Car: Codable, Identifiable {
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
    private let db: Firestore
    private var listenerRegistration: ListenerRegistration?
    
    init() {
        // Enable offline persistence
        let settings = FirestoreSettings()
        settings.cacheSettings = PersistentCacheSettings(sizeBytes: 100 * 1024 * 1024 as NSNumber)
        
        let db = Firestore.firestore()
        db.settings = settings
        self.db = db
    }
    
    func setupRealTimeListener(email: String, isUserCars: Bool) {
        // Remove any existing listener
        removeListener()
        
        let query = db.collection("carList")
        
        listenerRegistration = query.addSnapshotListener { [weak self] (snapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error listening for updates: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No documents in snapshot")
                return
            }
            
            self.Cars = documents.compactMap { document in
                do {
                    let car = try document.data(as: Car.self)
                    if isUserCars {
                        return car.userId == email ? car : nil
                    } else {
                        return car.userId != email ? car : nil
                    }
                } catch {
                    print("Error decoding car: \(error)")
                    return nil
                }
            }
        }
    }
    
    func removeListener() {
        listenerRegistration?.remove()
        listenerRegistration = nil
    }
    
    func addCar(CarModel: String, Availability: [String], Mileage: Int, PickUpLocation: GeoPoint, Pricing: Int, Year: Int, userId: String) {
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
    
    func editCar(id: String, CarModel: String, Availability: [String], Mileage: Int, PickUpLocation: GeoPoint, Pricing: Int, Year: Int, userId: String) {
        let docRef = db.collection("carList").document(id)
        docRef.updateData([
            "CarModel": CarModel,
            "Availability": Availability,
            "Mileage": Mileage,
            "PickUpLocation": PickUpLocation,
            "Pricing": Pricing,
            "Year": Year,
            "userId": userId
        ])
    }
    
    deinit {
        removeListener()
    }
}
