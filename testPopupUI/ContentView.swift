//
//  ContentView.swift
//  testPopupUI
//
//  Created by Steve Myers on 7/14/21.
//

import SwiftUI
import LNPopupUI

struct ContentView: View {
    @State var isPopupOpen = true
    @State var isPopupBarPresented = true
    @State var showDocPicker = false
    
    @State var tabSelected = 0
    
    @State private var username: String = ""
    @State private var isEditing = false
    
    var tab: some View {
        ZStack {
            Color.red
            Button {
                showDocPicker = true
            } label: {
                Text("DOCUMENT PICKER")
            }
            
        }
        .background(Color.red)
    }
    
    var body: some View {
        ZStack {
            TabView(selection: $tabSelected) {
                tab
                    .tabItem {
                        Image(systemName: "play.circle.fill")
                        Text("Listen Now")
                    }
                    .tag(0)
                tab
                    .tabItem {
                        Image(systemName: "music.note.list")
                        Text("Playlists")
                    }
                    .tag(1)
                tab
                    .tabItem {
                        Image(systemName: "play.circle.fill")
                        Text("Library")
                    }
                    .tag(2)
            }
            .popup(isBarPresented: $isPopupBarPresented, isPopupOpen: $isPopupOpen) {
                VStack {
                    ForEach(0..<30) {
                        Text("\($0) IN POPUP")
                    }
                }
            }
            .popupBarCustomView {
                ZStack {
                    Text("TITLE")
                        .frame(height: 70)
                    
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
            }
            .popupInteractionStyle(.drag)
            
        }
        .sheet(isPresented: $showDocPicker) {
            NavigationView {
                VStack {
                    TextField(
                        "User name (email address)",
                        text: $username
                    ) { isEditing in
                        self.isEditing = isEditing
                    } onCommit: {
                        print(username)
                    }
                    .padding(32)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Close") {
                            showDocPicker = false
                        }
                    }
                }
            }
        }
    }
}
