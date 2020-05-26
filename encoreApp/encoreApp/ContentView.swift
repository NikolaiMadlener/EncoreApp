//
//  ContentView.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 26.05.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var username: String
    var body: some View {
            VStack {
                TextField("enter username", text: self.$username)
                Button(action: { createSession(username: self.username) }) {
                    Text("Create Session").padding(15).background(Color("babyblue")).foregroundColor(Color.white).cornerRadius(15)
                }
        }
    }
}

func createSession(username: String) {
    guard let url = URL(string: "https://api.encore-fm.com/admin/"+"\(username)"+"/createSession") else {
        print("Invalid URL")
        return
    }
    var request = URLRequest(url: url)
    
    request.httpMethod = "POST"
     
    // HTTP Request Parameters which will be sent in HTTP Request Body
    //let postString = "userId=300&title=My urgent task&completed=false";
    // Set HTTP Request Body
    //request.httpBody = postString.data(using: String.Encoding.utf8);
    // Perform HTTP Request
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // Check for Error
            if let error = error {
                print("Error took place \(error)")
                return
            }
     
            // Convert HTTP Response Data to a String
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("Response data string:\n \(dataString)")
            }
    }
    task.resume()
}

struct ContentView_Previews: PreviewProvider {
    @State static var username = "Hans"
    static var previews: some View {
        ContentView(username: self.username)
    }
}
