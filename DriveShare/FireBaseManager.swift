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
struct Review: Codable, Identifiable {
    @DocumentID var id: String?
    var carId: String
    var reviewerId: String
    var reviewerName: String
    var recipientId: String
    var rating: Int
    var title: String
    var comment: String
    var timestamp: Date
    var isOwnerReview: Bool // true if owner reviewing renter, false if renter reviewing owner/car
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
    public let db: Firestore
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
    
    func getUserRentalHistory(userId: String, completion: @escaping ([Booking]) -> Void) {
            // First get bookings where user is the renter
            db.collection("bookings")
                .whereField("renterId", isEqualTo: userId)
                .getDocuments { [weak self] snapshot, error in
                    guard let self = self else { return }
                    
                    if let error = error {
                        print("Error fetching rental history: \(error.localizedDescription)")
                        completion([])
                        return
                    }
                    
                    var bookings = snapshot?.documents.compactMap { document -> Booking? in
                        try? document.data(as: Booking.self)
                    } ?? []
                    
                    // Then get bookings where user is the car owner
                    self.db.collection("bookings")
                        .whereField("ownerId", isEqualTo: userId)
                        .getDocuments { snapshot, error in
                            if let error = error {
                                print("Error fetching owner history: \(error.localizedDescription)")
                                completion(bookings) // Return just the renter bookings
                                return
                            }
                            
                            let ownerBookings = snapshot?.documents.compactMap { document -> Booking? in
                                try? document.data(as: Booking.self)
                            } ?? []
                            
                            // Combine both sets of bookings and sort by date
                            bookings.append(contentsOf: ownerBookings)
                            bookings.sort { $0.timestamp > $1.timestamp } // Most recent first
                            
                            completion(bookings)
                        }
                }
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
    func saveSecurityQuestions(userId: String, questions: [(index: Int, question: String, answer: String)]) {
        let db = Firestore.firestore()
        let batch = db.batch()
        
        for questionData in questions {
            let docRef = db.collection("securityQuestions").document()
            
            let data: [String: Any] = [
                "userId": userId,
                "questionIndex": questionData.index,
                "question": questionData.question,
                "answer": questionData.answer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            ]
            
            batch.setData(data, forDocument: docRef)
        }
        
        batch.commit { error in
            if let error = error {
                print("Error saving security questions: \(error.localizedDescription)")
            } else {
                print("Security questions saved successfully")
            }
        }
    }

        
        func getSecurityQuestions(forEmail email: String, completion: @escaping ([String]) -> Void) {
            db.collection("securityQuestions")
                .whereField("userId", isEqualTo: email)
                .getDocuments { snapshot, error in
                    if let error = error {
                        print("Error fetching security questions: \(error.localizedDescription)")
                        completion([])
                        return
                    }
                    
                    let questions = snapshot?.documents.compactMap { document -> String? in
                        document.data()["question"] as? String
                    } ?? []
                    
                    completion(questions)
                }
        }
        
        func verifySecurityAnswers(email: String, answers: [(question: String, answer: String)],
                                  completion: @escaping (Bool) -> Void) {
            db.collection("securityQuestions")
                .whereField("userId", isEqualTo: email)
                .getDocuments { snapshot, error in
                    if let error = error {
                        print("Error verifying answers: \(error.localizedDescription)")
                        completion(false)
                        return
                    }
                    
                    guard let documents = snapshot?.documents, !documents.isEmpty else {
                        completion(false)
                        return
                    }
                    
                    // Create a dictionary of stored questions and answers
                    var storedQA: [String: String] = [:]
                    for doc in documents {
                        if let question = doc.data()["question"] as? String,
                           let answer = doc.data()["answer"] as? String {
                            storedQA[question] = answer
                        }
                    }
                    
                    // Check if provided answers match stored answers
                    var correctAnswers = 0
                    for qa in answers {
                        let normalizedAnswer = qa.answer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                        if storedQA[qa.question] == normalizedAnswer {
                            correctAnswers += 1
                        }
                    }
                    
                    // Require at least 2 correct answers for security
                    completion(correctAnswers >= 2)
                    
                    // Log recovery attempt
                    self.logPasswordRecoveryAttempt(email: email, isSuccessful: correctAnswers >= 2)
                }
        }
        
        private func logPasswordRecoveryAttempt(email: String, isSuccessful: Bool) {
            db.collection("passwordRecoveryAttempts").addDocument(data: [
                "email": email,
                "timestamp": FieldValue.serverTimestamp(),
                "isSuccessful": isSuccessful
            ])
        }
    func addReview(carId: String, recipientId: String, rating: Int, title: String, comment: String, isOwnerReview: Bool) {
        guard let currentUser = try? AuthenticationManager.shared.getAuthUser() else { return }
        
        let review = [
            "carId": carId,
            "reviewerId": currentUser.email ?? "",
            "reviewerName": currentUser.email ?? "Anonymous User",
            "recipientId": recipientId,
            "rating": rating,
            "title": title,
            "comment": comment,
            "timestamp": FieldValue.serverTimestamp(),
            "isOwnerReview": isOwnerReview
        ] as [String: Any]
        
        db.collection("reviews").addDocument(data: review) { error in
            if let error = error {
                print("Error adding review: \(error.localizedDescription)")
            } else {
                // Update average rating on car or user profile
                self.updateAverageRating(for: isOwnerReview ? recipientId : carId, isUserRating: isOwnerReview)
            }
        }
    }
    
    func getReviewsForCar(carId: String, completion: @escaping ([Review]) -> Void) {
        db.collection("reviews")
            .whereField("carId", isEqualTo: carId)
            .whereField("isOwnerReview", isEqualTo: false)
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error getting car reviews: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                let reviews = snapshot?.documents.compactMap { document -> Review? in
                    try? document.data(as: Review.self)
                } ?? []
                
                completion(reviews)
            }
    }
    
    func getReviewsForUser(userId: String, isOwnerReviews: Bool, completion: @escaping ([Review]) -> Void) {
        db.collection("reviews")
            .whereField(isOwnerReviews ? "recipientId" : "reviewerId", isEqualTo: userId)
            .whereField("isOwnerReview", isEqualTo: isOwnerReviews)
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error getting user reviews: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                let reviews = snapshot?.documents.compactMap { document -> Review? in
                    try? document.data(as: Review.self)
                } ?? []
                
                completion(reviews)
            }
    }
    
    private func updateAverageRating(for id: String, isUserRating: Bool) {
        // Query to get all reviews for this car or user
        let query = db.collection("reviews")
            .whereField(isUserRating ? "recipientId" : "carId", isEqualTo: id)
            .whereField("isOwnerReview", isEqualTo: isUserRating)
        
        query.getDocuments { snapshot, error in
            if let error = error {
                print("Error calculating average rating: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents, !documents.isEmpty else { return }
            
            // Calculate average rating
            let totalRating = documents.reduce(0) { sum, document in
                sum + (document.data()["rating"] as? Int ?? 0)
            }
            
            let averageRating = Double(totalRating) / Double(documents.count)
            
            // Update the average rating on the car or user profile
            if isUserRating {
                // Update user profile with average rating
                self.db.collection("users").document(id).updateData([
                    "averageRating": averageRating
                ])
            } else {
                // Update car with average rating
                self.db.collection("carList").document(id).updateData([
                    "averageRating": averageRating
                ])
            }
        }
    }
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
