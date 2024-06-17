//
//  DynamicFilteredView.swift
//  TaskManager
//
//  Created by Emir Rassulov on 17/06/2024.
//

import SwiftUI
import CoreData

struct FilteredView<Content: View, T>: View where T: NSManagedObject {
    @FetchRequest var request: FetchedResults<T>
    let content: (T) -> Content
    
    init(currentTab: String, @ViewBuilder content: @escaping (T) -> Content) {
        let calendar = Calendar.current
        var predicate: NSPredicate!
        
        if currentTab == "Today" {
            let today = calendar.startOfDay(for: Date())
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
            predicate = NSPredicate(format: "deadline >= %@ AND deadline < %@ AND isCompleted == %i", argumentArray: [today, tomorrow, 0])
        } else if currentTab == "Upcoming" {
            let tomorrow = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: Date())!)
            predicate = NSPredicate(format: "deadline >= %@ AND isCompleted == %i", argumentArray: [tomorrow, 0])
        } else if currentTab == "Failed" {
            let today = calendar.startOfDay(for: Date())
            predicate = NSPredicate(format: "deadline < %@ AND isCompleted == %i", argumentArray: [today, 0])
        } else {
            predicate = NSPredicate(format: "isCompleted == %i", argumentArray: [1])
        }
        
        _request = FetchRequest(entity: T.entity(), sortDescriptors: [.init(keyPath: \Task.deadline, ascending: false)], predicate: predicate)
        self.content = content
    }
    
    var body: some View {
        Group {
            if request.isEmpty {
                Text("No tasks found!!!")
                    .font(.system(size: 16))
                    .fontWeight(.light)
                    .offset(y: 100)
            } else {
                ForEach(request, id: \.objectID) { object in
                    self.content(object)
                }
            }
        }
    }
}
