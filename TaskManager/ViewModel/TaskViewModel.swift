//
//  TaskViewModel.swift
//  TaskManager
//
//  Created by Emir Rassulov on 17/06/2024.
//

import UserNotifications
import SwiftUI
import CoreData

class TaskViewModel: ObservableObject {
    @Published var currentTab: String = "Today"
    @Published var openEditTask: Bool = false
    @Published var taskTitle: String = ""
    @Published var taskColor: String = "Yellow"
    @Published var isReminderOn: Bool = false
    @Published var reminderDate: Date = Date()
    @Published var reminderText: String = ""
    @Published var taskDeadline: Date = Date()
    @Published var taskType: String = "Basic"
    @Published var showDatePicker: Bool = false
    @Published var editTask: Task?
    @Published var showTimePicker: Bool = false
    @Published var notificationAccess: Bool = false
    
    init() {
        requestNotificationPermission()
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                self.notificationAccess = granted
                if let error = error {
                    print("Notification permission error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func scheduleNotification(for task: Task) {
        if task.isReminderOn {
            let content = UNMutableNotificationContent()
            content.title = task.title ?? "No Title"
            content.body = task.reminderText ?? ""
            content.sound = UNNotificationSound.default

            let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: task.reminderDate ?? Date())
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

            let request = UNNotificationRequest(identifier: task.objectID.uriRepresentation().absoluteString, content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Notification scheduling error: \(error.localizedDescription)")
                }
            }
        } else {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [task.objectID.uriRepresentation().absoluteString])
        }
    }
    
    func addTask(context: NSManagedObjectContext) -> Bool {
        var task: Task!
        if let editTask = editTask {
            task = editTask
        } else {
            task = Task(context: context)
        }
        
        task.title = taskTitle
        task.color = taskColor
        task.deadline = taskDeadline
        task.type = taskType
        task.isCompleted = false
        task.isReminderOn = isReminderOn
        task.reminderText = reminderText
        task.reminderDate = reminderDate

        do {
            try context.save()
            scheduleNotification(for: task)
            return true
        } catch {
            print("Failed to save task: \(error.localizedDescription)")
            return false
        }
    }
    
    func resetTaskData() {
        taskType = "Basic"
        taskColor = "Yellow"
        taskTitle = ""
        taskDeadline = Date()
        editTask = nil
        isReminderOn = false
        reminderText = ""
    }
    
    func setupTask() {
        if let editTask = editTask {
            taskType = editTask.type ?? "Basic"
            taskColor = editTask.color ?? "Yellow"
            taskTitle = editTask.title ?? ""
            taskDeadline = editTask.deadline ?? Date()
            reminderText = editTask.reminderText ?? ""
            isReminderOn = editTask.isReminderOn
            reminderDate = editTask.reminderDate ?? Date()
        } else {
            isReminderOn = false
            reminderText = ""
        }
    }
}

