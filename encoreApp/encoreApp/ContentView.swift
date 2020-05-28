//
//  ContentView.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 26.05.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var username: String = ""
    @Binding var signInSuccess: Bool

    var body: some View {
        ZStack {
            
            //LinearGradient(gradient: Gradient(colors: [Color("lax"), Color("purple")]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all)
            VStack {
                Spacer().frame(height: 150)
                Text("encore.").font(.largeTitle).bold()
                Spacer().frame(height: 200)
                TextField("Enter your Name", text: self.$username).padding(5).background(Color("lightgray")).cornerRadius(5).padding()
                Button(action: { self.createSession(username: self.username) }) {
                    Text("Create Session").padding(15).background( username == "" ? Color("buttonDisabledGray") : Color("darkgray") ).foregroundColor(username == "" ? Color("lightgray") : Color.white).cornerRadius(15)//.shadow(radius: 5)
                }.disabled(username == "")
                Spacer()
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
            
            self.signInSuccess = true
        }
        task.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    @State static var signInSuccess = false
    
    static var previews: some View {
        ContentView(signInSuccess: $signInSuccess)
    }
}
