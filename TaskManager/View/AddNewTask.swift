//
//  AddNewTask.swift
//  TaskManager
//
//  Created by Emir Rassulov on 17/06/2024.
//

import SwiftUI

struct AddNewTask: View {
    @EnvironmentObject var taskModel: TaskViewModel
    @Environment(\.self) var env
    @Namespace var animation
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Edit Task")
                .font(.title3.bold())
                .frame(maxWidth: .infinity)
                .overlay(alignment: .leading) {
                    Button {
                        env.dismiss()
                    } label: {
                        Image(systemName: "arrow.left")
                            .font(.title3)
                            .foregroundColor(.black)
                    }
                }
                .overlay(alignment: .trailing) {
                    Button {
                        if let editTask = taskModel.editTask {
                            env.managedObjectContext.delete(editTask)
                            try? env.managedObjectContext.save()
                            env.dismiss()
                        }
                    } label: {
                        Image(systemName: "trash")
                            .font(.title3)
                            .foregroundColor(.red)
                    }
                    .opacity(taskModel.editTask == nil ? 0 : 1)
                }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Task Color")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                let colors: [String] = ["Yellow", "Green", "Blue", "Purple", "Red", "Orange"]
                
                HStack(spacing: 15) {
                    ForEach(colors, id: \.self) { color in
                        Circle()
                            .fill(Color(color))
                            .frame(width: 30, height: 30)
                            .background {
                                if taskModel.taskColor == color {
                                    Circle()
                                        .strokeBorder(.gray)
                                        .padding(-3)
                                }
                            }
                            .contentShape(Circle())
                            .onTapGesture {
                                taskModel.taskColor = color
                            }
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.top, 10)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 30)
            
            Divider()
                .padding(.vertical, 10)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Task Deadline")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(taskModel.taskDeadline.formatted(date: .abbreviated, time: .omitted) + ", " + taskModel.taskDeadline.formatted(date: .omitted, time: .shortened))
                    .font(.callout)
                    .fontWeight(.semibold)
                    .padding(.top, 8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(alignment: .bottomTrailing) {
                Button {
                    taskModel.showDatePicker.toggle()
                } label: {
                    Image(systemName: "calendar")
                        .foregroundColor(.black)
                }
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Task Title")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                TextField("", text: $taskModel.taskTitle)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
            }
            .padding(.top, 10)
            
            Divider()
            
            let taskTypes: [String] = ["Basic", "Urgent", "Important"]
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Task Type")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                HStack(spacing: 12) {
                    ForEach(taskTypes, id: \.self) { type in
                        Text(type)
                            .font(.callout)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(taskModel.taskType == type ? .white : .black)
                            .background {
                                if taskModel.taskType == type {
                                    Capsule()
                                        .fill(.black)
                                        .matchedGeometryEffect(id: "TYPE", in: animation)
                                } else {
                                    Capsule()
                                        .strokeBorder(.black)
                                }
                            }
                            .contentShape(Capsule())
                            .onTapGesture {
                                withAnimation { taskModel.taskType = type }
                            }
                    }
                }
                .padding(.top, 8)
            }
            .padding(.vertical, 10)
            
            Divider()
            
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Reminder")
                            .fontWeight(.semibold)
                        
                        Text("Just notification")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Toggle(isOn: $taskModel.isReminderOn) { }
                        .labelsHidden()
                }
                
                HStack(spacing: 12) {
                    Label {
                        Text(taskModel.reminderDate.formatted(date: .omitted, time: .shortened))
                    } icon: {
                        Image(systemName: "clock")
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    .background(Color("Col").opacity(0.4), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                    .onTapGesture {
                        withAnimation {
                            taskModel.showTimePicker.toggle()
                        }
                    }
                    
                    TextField("Reminder Text", text: $taskModel.reminderText)
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .background(Color("Col").opacity(0.4), in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                }
                .frame(height: taskModel.isReminderOn ? nil : 0)
                .opacity(taskModel.isReminderOn ? 1 : 0)
            }
            .animation(.easeInOut, value: taskModel.isReminderOn)
            
            Divider()
            
            Button {
                if taskModel.addTask(context: env.managedObjectContext) {
                    env.dismiss()
                }
            } label: {
                Text("Save Task")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundColor(.white)
                    .background {
                        Capsule()
                            .fill(.black)
                    }
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, 10)
            .disabled(taskModel.taskTitle == "")
            .opacity(taskModel.taskTitle == "" ? 0.6 : 1)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding()
        .background(
            ZStack {
                if taskModel.showDatePicker || taskModel.showTimePicker {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            taskModel.showDatePicker = false
                            taskModel.showTimePicker = false
                        }
                }
            }
        )
        .overlay {
            if taskModel.showDatePicker {
                ZStack {
                    Color.clear
                        .background(.ultraThinMaterial)
                        .ignoresSafeArea()
                        .onTapGesture { // Dismiss when tapping outside the picker
                            taskModel.showDatePicker = false
                        }
                    
                    VStack {
                        DatePicker("", selection: $taskModel.taskDeadline, in: Date.now...Date.distantFuture)
                            .datePickerStyle(.graphical)
                            .labelsHidden()
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
                    }
                    .padding()
                }
                .animation(.easeInOut, value: taskModel.showDatePicker)
            }
            
            if taskModel.showTimePicker {
                ZStack {
                    Color.clear
                        .background(.ultraThinMaterial)
                        .ignoresSafeArea()
                        .onTapGesture { // Dismiss when tapping outside the picker
                            taskModel.showTimePicker = false
                        }
                    
                    VStack {
                        DatePicker("", selection: $taskModel.reminderDate, displayedComponents: [.hourAndMinute])
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                    }
                    .padding()
                }
                .animation(.easeInOut, value: taskModel.showTimePicker)
            }
        }
    }
}

#Preview {
    AddNewTask()
        .environmentObject(TaskViewModel())
}
