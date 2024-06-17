//
//  ContentView.swift
//  TaskManager
//
//  Created by Emir Rassulov on 17/06/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView{
            Home()
                .navigationBarTitle("Task Manager")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ContentView()
}

