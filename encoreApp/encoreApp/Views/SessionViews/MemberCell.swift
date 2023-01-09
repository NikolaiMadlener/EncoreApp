//
//  MenuViewCell.swift
//  encoreApp
//
//  Created by Etienne Köhler on 19.12.20.
//  Copyright © 2020 NikolaiEtienne. All rights reserved.
//

import SwiftUI

struct MemberCell: View {
    @ObservedObject var userVM: UserVM
    @State var rank: Int
    @State var pointColor: Color = .white
    var member: UserListElement
    var isAdmin: Bool
    
    func findPointColor() -> Color {
        switch member.score {
        case ...0:
            return Color.red
        case 0:
            return Color.white
        default:
            return Color.green
        }
    }

    var body: some View {
        HStack {
            Text("\(rank)")
                .font(.system(size: 18, weight: .light))
            
                Text("\(member.username)").font(.system(size: 18, weight: .semibold))
            if member.username == self.userVM.username {
                Text("you.")
                    .foregroundColor(Color("purpleblue"))
                    .font(.system(size: 18, weight: .semibold))
            } else if isAdmin {
                Text("admin.")
                    .foregroundColor(Color("orange2"))
                    .font(.system(size: 18, weight: .semibold))
            }
            Spacer()
            Text("\(member.score)")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(findPointColor())
            Image(systemName: "heart.fill")
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(findPointColor())
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 20)
        .frame(minWidth: 0, maxWidth: .infinity)
        .background(Color("mediumdarkgray"))
        .foregroundColor(Color.white)
        .cornerRadius(15)
        .padding(.horizontal, 20)
        .padding(.vertical, 1)
    }
}

struct MemberCell_Previews: PreviewProvider {
    static var previews: some View {
        MemberCell(userVM: UserVM(), rank: 3, member: UserListElement(username: "Felix", is_admin: false, score: 2, spotify_synchronized: false), isAdmin: true)
    }
}
