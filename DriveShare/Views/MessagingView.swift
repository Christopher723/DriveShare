//
//  MessagingView.swift
//  DriveShare
//
//  Created by Christopher Woods on 3/27/25.
//
import SwiftUI

struct MessagingView: View {
    @EnvironmentObject var firestoreManager: FirestoreManager
    @State private var conversations: [Conversation] = []
    @State private var isLoading = true
    
    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    ProgressView()
                } else if conversations.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "message.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("No conversations yet")
                            .font(.headline)
                        
                        Text("Your conversations with car owners and renters will appear here")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(conversations) { conversation in
                            NavigationLink(destination: ChatView(conversation: conversation)) {
                                ConversationRow(conversation: conversation)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                    .refreshable {
                        loadConversations()
                    }
                }
            }
            .navigationTitle("Messages")
            .onAppear {
                loadConversations()
            }
        }
    }
    
    private func loadConversations() {
        isLoading = true
        firestoreManager.getConversations { conversations in
            self.conversations = conversations
            isLoading = false
        }
    }
}

struct ConversationRow: View {
    let conversation: Conversation
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar placeholder
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(getInitials())
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.blue)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(getOtherParticipantName())
                        .font(.headline)
                    
                    Spacer()
                    
                    Text(formatDate(conversation.lastMessageTimestamp))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Text(conversation.lastMessage)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if conversation.unreadCount > 0 {
                        Text("\(conversation.unreadCount)")
                            .font(.caption)
                            .padding(6)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                }
                
                if let carModel = conversation.carModel {
                    Text("Re: \(carModel)")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private func getOtherParticipantName() -> String {
        guard let currentUser = try? AuthenticationManager.shared.getAuthUser().email else { return "Unknown" }
        
        if let otherUser = conversation.participants.first(where: { $0 != currentUser }) {
            return otherUser
        }
        
        return "Unknown"
    }
    
    private func getInitials() -> String {
        let name = getOtherParticipantName()
        return String(name.prefix(1)).uppercased()
    }
    
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yy"
            return formatter.string(from: date)
        }
    }
}

struct ChatView: View {
    let conversation: Conversation
    @EnvironmentObject var firestoreManager: FirestoreManager
    @State private var messages: [Message] = []
    @State private var newMessage = ""
    @State private var isLoading = true
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else {
                ScrollViewReader { scrollView in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                    .onAppear {
                        if let lastMessage = messages.last {
                            scrollView.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Message input field
            HStack {
                TextField("Type a message...", text: $newMessage)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.blue)
                        .padding(8)
                }
                .disabled(newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
        }
        .navigationTitle(getOtherParticipantName())
        .onAppear {
            loadMessages()
        }
    }
    
    private func loadMessages() {
        isLoading = true
        firestoreManager.getMessages(for: conversation.id ?? "") { messages in
            self.messages = messages
            isLoading = false
        }
    }
    
    private func sendMessage() {
        guard let receiverId = getOtherParticipantId(), !newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        firestoreManager.sendMessage(
            to: receiverId,
            content: newMessage,
            relatedCarId: conversation.relatedCarId
        )
        
        newMessage = ""
    }
    
    private func getOtherParticipantName() -> String {
        guard let currentUser = try? AuthenticationManager.shared.getAuthUser().email else { return "Chat" }
        
        if let otherUser = conversation.participants.first(where: { $0 != currentUser }) {
            return otherUser
        }
        
        return "Chat"
    }
    
    private func getOtherParticipantId() -> String? {
        guard let currentUser = try? AuthenticationManager.shared.getAuthUser().email else { return nil }
        return conversation.participants.first(where: { $0 != currentUser })
    }
}

struct MessageBubble: View {
    let message: Message
    
    var isCurrentUser: Bool {
        guard let currentUser = try? AuthenticationManager.shared.getAuthUser().email else { return false }
        return message.senderId == currentUser
    }
    
    var body: some View {
        HStack {
            if isCurrentUser { Spacer() }
            
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(12)
                    .background(isCurrentUser ? Color.blue : Color(.systemGray5))
                    .foregroundColor(isCurrentUser ? .white : .primary)
                    .cornerRadius(16)
                
                Text(message.formattedTime)
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 4)
            }
            
            if !isCurrentUser { Spacer() }
        }
    }
}
