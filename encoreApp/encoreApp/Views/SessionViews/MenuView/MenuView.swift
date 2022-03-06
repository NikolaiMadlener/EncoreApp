//
//  MenuView.swift
//  encoreApp
//
//  Created by Nikolai Madlener on 29.05.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI

struct MenuView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: ViewModel
    
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                topBar
                sessionTitle
                qrCode.modifier(BlueCardModifier(color: Color.white))
                VStack {
                    membersList
                    Spacer()
                }.modifier(BlueCardModifier())
                if viewModel.isUserAdmin {
                    deleteButton
                } else {
                    leaveButton
                }
            }.background(Color(uiColor: UIColor.systemGray6))
                .sheet(isPresented: self.$viewModel.showShareSheet) {
                    ActivityViewController(activityItems: ["encoreApp://\(self.viewModel.sessionID)"] as [Any], applicationActivities: nil)
                }.onAppear{
                    self.viewModel.getMembers()
                }
            
            if self.viewModel.showPopupQRCode {
                popupQRView
            }
        }
    }
    
    var topBar: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.secondary)
                .frame(width: 60, height: 4)
        }.padding()
    }
    
    var sessionTitle: some View {
        Text("\(viewModel.members.first(where: { $0.is_admin })?.username ?? "Host")'s session")
            .font(.system(size: 25, weight: .bold))
            .padding(.bottom, 10)
    }
    
    var qrCode: some View {
        Button(action: {
            withAnimation { self.viewModel.showPopupQRCode.toggle() }
        }) {
            QRCodeView(url: "encoreApp://\(self.viewModel.sessionID)", size: 150).padding(10)
        }.buttonStyle(PlainButtonStyle())
            .alert(isPresented: self.$viewModel.showSessionExpiredAlert) {
                Alert(title: Text("Session expired"),
                      message: Text("The Host has ended the Session."),
                      dismissButton: .destructive(Text("Leave"), action: {
                    self.viewModel.currentlyInSession = false
                }))
            }
    }
    
    var membersList: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Text("Leaderboard")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(Color("purpleblue"))
                    .padding(10)
                Spacer()
            }
            ScrollView {
                VStack {
                    ForEach(viewModel.members.sorted(by: { $0.score > $1.score }), id: \.self) { member in
                        HStack {
                            Text("\((self.viewModel.members.sorted(by: { $0.score > $1.score }).firstIndex(of: member) ?? -1) + 1)")
                                .font(.system(size: 17, weight: .light))
                            if member.username == self.viewModel.currentUser {
                                Text("\(member.username)").font(.system(size: 17, weight: .semibold))
                            } else {
                                Text("\(member.username)").font(.system(size: 17, weight: .medium))
                            }
                            Spacer()
                            Text("\(member.score)").font(.system(size: 17, weight: .semibold))
                            Image(systemName: "heart")
                                .font(.system(size: 15, weight: .semibold))
                        }.foregroundColor(self.colorScheme == .dark ? Color.white : Color.black)
                        Divider()
                    }
                    Spacer().frame(height: 10)
                }.padding(.horizontal, 30)
            }
        }
    }
    
    var deleteButton: some View {
        Button(action: { viewModel.showAlert() }) {
            Text("Delete Session")
                .modifier(ButtonHeavyModifier(isDisabled: false, backgroundColor: Color.red, foregroundColor: Color.white))
        }.padding(.bottom)
            .alert(isPresented: self.$viewModel.showDeleteAlert) {
                Alert(title: Text("Delete Session"),
                      message: Text("By deleting the current session all members will be kicked."),
                      primaryButton: .destructive(Text("Delete"), action: {
                    //                    self.playerStateVM.playerPause()
                    self.viewModel.deleteSession()
                }),
                      secondaryButton: .cancel(Text("Cancel"), action: {
                    self.viewModel.showDeleteAlert = false
                }))}
    }
    
    var leaveButton: some View {
        Button(action: { viewModel.showAlert() }) {
            Text("Leave Session")
                .modifier(ButtonHeavyModifier(isDisabled: false, backgroundColor: Color.red, foregroundColor: Color.white))
        }.padding(.bottom)
            .alert(isPresented: self.$viewModel.showLeaveAlert) {
                Alert(title: Text("Leave Session"),
                      message: Text("Are you sure you want to leave this session?"),
                      primaryButton: .destructive(Text("Leave"), action: {
                    //                    self.playerStateVM.playerPause()
                    self.viewModel.leaveSession()
                }),
                      secondaryButton: .cancel(Text("Cancel"), action: {
                    self.viewModel.showLeaveAlert = false
                }))
            }
    }
    
    var popupQRView: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                PopupQRCodeView(viewModel: .init(showPopupQRCode: $viewModel.showPopupQRCode))
            }.frame(width: geo.size.width,
                    height: geo.size.height,
                    alignment: .center)
        }.background(
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    self.viewModel.showPopupQRCode.toggle()
                }
        )
    }
}

struct MenuView_Previews: PreviewProvider {
    
    static var previews: some View {
        MenuView(viewModel: .init())
    }
}
