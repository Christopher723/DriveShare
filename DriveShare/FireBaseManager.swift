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
struct Message: Identifiable, Codable {
    @DocumentID var id: String?
    var senderId: String
    var receiverId: String
    var content: String
    var timestamp: Date
    var isRead: Bool
    var relatedCarId: String?
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
}

struct Conversation: Identifiable, Codable {
    @DocumentID var id: String?
    var participants: [String]
    var lastMessage: String
    var lastMessageTimestamp: Date
    var unreadCount: Int
    var relatedCarId: String?
    var carModel: String?
}

struct Notification: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String
    var title: String
    var body: String
    var type: NotificationType
    var relatedId: String?
    var timestamp: Date
    var isRead: Bool
    
    enum NotificationType: String, Codable {
        case bookingRequest
        case bookingConfirmation
        case bookingCancellation
        case message
        case paymentReceived
        case system
    }
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
    // Caching System
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
extension FirestoreManager {
    // MARK: - Messaging Functions
    
    func sendMessage(to receiverId: String, content: String, relatedCarId: String? = nil) {
        guard let currentUser = try? AuthenticationManager.shared.getAuthUser().email else { return }
        
        // Create a new message
        let message = [
            "senderId": currentUser,
            "receiverId": receiverId,
            "content": content,
            "timestamp": FieldValue.serverTimestamp(),
            "isRead": false,
            "relatedCarId": relatedCarId ?? NSNull()
        ] as [String: Any]
        
        // Add message to Firestore
        db.collection("messages").addDocument(data: message) { error in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
            } else {
                // Update or create conversation
                self.updateConversation(with: currentUser, receiverId: receiverId, lastMessage: content, relatedCarId: relatedCarId)
            }
        }
    }

    private func updateConversation(with senderId: String, receiverId: String, lastMessage: String, relatedCarId: String?) {
        // Create a unique conversation ID based on participants (sorted to ensure consistency)
        let participants = [senderId, receiverId].sorted()
        let conversationId = participants.joined(separator: "_")
        
        // Check if conversation exists
        let conversationRef = db.collection("conversations").document(conversationId)
        
        conversationRef.getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            
            if let document = document, document.exists {
                // Update existing conversation
                conversationRef.updateData([
                    "lastMessage": lastMessage,
                    "lastMessageTimestamp": FieldValue.serverTimestamp(),
                    "unreadCount": FieldValue.increment(Int64(1))
                ])
            } else {
                // Create new conversation
                var conversationData: [String: Any] = [
                    "participants": participants,
                    "lastMessage": lastMessage,
                    "lastMessageTimestamp": FieldValue.serverTimestamp(),
                    "unreadCount": 1
                ]
                
                if let carId = relatedCarId {
                    conversationData["relatedCarId"] = carId
                    
                    // Get car model for display
                    self.db.collection("carList").document(carId).getDocument { (carDoc, error) in
                        if let car = try? carDoc?.data(as: Car.self) {
                            conversationRef.updateData(["carModel": car.CarModel])
                        }
                    }
                }
                
                conversationRef.setData(conversationData)
            }
        }
    }

    func getConversations(completion: @escaping ([Conversation]) -> Void) {
        guard let currentUser = try? AuthenticationManager.shared.getAuthUser().email else {
            completion([])
            return
        }
        
        db.collection("conversations")
            .whereField("participants", arrayContains: currentUser)
            .order(by: "lastMessageTimestamp", descending: true)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error getting conversations: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                let conversations = snapshot?.documents.compactMap { document -> Conversation? in
                    try? document.data(as: Conversation.self)
                } ?? []
                
                completion(conversations)
            }
    }

    func getMessages(for conversationId: String, completion: @escaping ([Message]) -> Void) {
        db.collection("messages")
            .whereField("conversationId", isEqualTo: conversationId)
            .order(by: "timestamp", descending: false)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error getting messages: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                let messages = snapshot?.documents.compactMap { document -> Message? in
                    try? document.data(as: Message.self)
                } ?? []
                
                completion(messages)
            }
    }
}
