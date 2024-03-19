//
//  ContentView.swift
//  ChatBot
//
//  Created by SHHH!! private on 19/03/24.
//

import SwiftUI

struct ChatView: View {
    @State private var messageText = ""
    @State private var messages: [String] = ["Welcome to PetalPixxie"]
    
    let apiKey = ""
    let endpoint = "https://api.openai.com/v1/chat/completions"

    var body: some View {
        VStack {
            HStack {
                Text("Paudha")
                    .font(.largeTitle)
                    .bold()
            }

            ScrollView {
                ForEach(messages, id: \.self) { message in
                    MessageView(message: message)
                }
                .rotationEffect(.degrees(180))
            }
            .rotationEffect(.degrees(180))

            HStack {
                TextField("Type something", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button(action: {
                    sendMessage()
                }) {
                    Image(systemName: "paperplane.fill")
                }
                .font(.system(size: 26))
                .padding(.horizontal, 10)
            }
            .padding()
        }
    }

    func sendMessage() {
        let userMessage = messageText
        messages.append("[USER] " + userMessage)
        self.messageText = "" // Clear the input field

        fetchBotResponse(message: userMessage) { response in
            DispatchQueue.main.async {
                withAnimation {
                    messages.append(response)
                }
            }
        }
    }

    func fetchBotResponse(message: String, completion: @escaping (String) -> Void) {
        guard let url = URL(string: endpoint) else {
            completion("Error: Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        struct ChatLog: Codable {
            let model: String
            let messages: [Message]
        }

        struct Message: Codable {
            let role: String
            let content: String
        }
        
        let message1 = Message(role: "user", content: message)
        let chatLog = ChatLog(model: "gpt-3.5-turbo", messages: [message1])
        
        let chatLogDictionary: NSDictionary = [
            "model": chatLog.model,
            "messages": chatLog.messages.map { message in
                return [
                    "role": message.role,
                    "content": message.content
                ]
            } as NSArray
        ]


        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: chatLogDictionary, options: [])
        } catch {
            completion("Error: Failed to serialize request data")
            return
        }

        let session = URLSession.shared

        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion("Error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                completion("Error: No data received")
                return
            }

            do {
            
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    
                    if let choices = jsonResponse?["choices"] as? [[String: Any]], !choices.isEmpty,
                       let firstChoice = choices.first,
                       let message = firstChoice["message"] as? [String: Any],
                       let content = message["content"] as? String {
                        completion(content)
                    } else {
                        // Handle the case when choices array is empty or when parsing fails
                        completion("Error parsing schema") // You might want to handle this case differently based on your requirements
                    }
            } catch {
                completion("Error: \(error.localizedDescription)")
            }
        }

        task.resume()
    }

    struct MessageView: View {
        let message: String

        var body: some View {
            HStack {
                if message.contains("[USER]") {
                    let newMessage = message.replacingOccurrences(of: "[USER]", with: "")
                    Spacer()
                    Text(newMessage)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue.opacity(0.8))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 10)
                } else {
                    Text(message)
                        .padding()
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 10)
                    Spacer()
                }
            }
        }
    }


}


 import SwiftUI

struct ContentView: View {
   
    @State private var pageIndex = 0
    private let pages: [Page] = Page.samplePages
    private let dotAppearance = UIPageControl.appearance()
    
    var body: some View {
        ChatView()
    }
    
    func incrementPage() {
        pageIndex += 1
    }
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
import Foundation

struct Page: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var description: String
    var imageUrl: String
    var tag: Int
    
    static var samplePage = Page(name: "Title Example", description: "This is a sample description for the purpose of debugging", imageUrl: "work", tag: 0)
    static var samplePages: [Page] = [
        Page(name: "Welcome to Paudha!", description: "Make your plants smile....", imageUrl: "logo", tag: 0),
        Page(name: "Green Guardian", description: "Identify your plants,Diagnose their health,Keep them happy", imageUrl: "ob2", tag: 1),
        Page(name: "Care Reminders", description: "Keep your plant care schedule in check!", imageUrl: "ob1", tag: 2),
    ]
}
