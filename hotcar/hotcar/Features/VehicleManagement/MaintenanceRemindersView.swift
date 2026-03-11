//
//  MaintenanceRemindersView.swift
//  hotcar
//
//  HotCar Vehicle Management - Maintenance Reminders View
//  Display and manage vehicle maintenance reminders
//

import SwiftUI

struct MaintenanceRemindersView: View {
    
    // MARK: - Properties
    
    @StateObject private var viewModel = MaintenanceRemindersViewModel()
    @State private var showingAddReminder = false
    let vehicleId: String
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.reminders.isEmpty {
                    emptyState
                } else {
                    reminderList
                }
            }
            .navigationTitle("Maintenance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddReminder = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddReminder) {
                AddMaintenanceReminderView(vehicleId: vehicleId)
            }
        }
        .onAppear {
            viewModel.loadReminders(for: vehicleId)
        }
    }
    
    // MARK: - Reminder List
    
    private var reminderList: some View {
        List {
            // Overdue Section
            if !viewModel.overdueReminders.isEmpty {
                Section(header: labelSection("Overdue", color: .warmUpActive)) {
                    ForEach(viewModel.overdueReminders) { reminder in
                        ReminderRow(reminder: reminder)
                    }
                }
            }
            
            // Upcoming Section
            if !viewModel.upcomingReminders.isEmpty {
                Section(header: labelSection("Upcoming", color: .hotCarSecondary)) {
                    ForEach(viewModel.upcomingReminders) { reminder in
                        ReminderRow(reminder: reminder)
                    }
                }
            }
            
            // Completed Section
            if !viewModel.completedReminders.isEmpty {
                Section(header: labelSection("Completed", color: .textMuted)) {
                    ForEach(viewModel.completedReminders) { reminder in
                        ReminderRow(reminder: reminder)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    private func labelSection(_ title: String, color: Color) -> some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(title)
                .font(.hotCarHeadline)
                .foregroundColor(.textPrimary)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "wrench")
                .font(.system(size: 64))
                .foregroundColor(.textMuted)
            
            Text("No Maintenance Reminders")
                .font(.hotCarTitle)
                .foregroundColor(.textPrimary)
            
            Text("Add reminders to keep track of your vehicle's maintenance schedule")
                .font(.hotCarBody)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
            
            Button(action: { showingAddReminder = true }) {
                Label("Add Reminder", systemImage: "plus")
                    .font(.hotCarButton)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background(Color.hotCarPrimary)
                    .foregroundColor(.white)
                    .cornerRadius(.hotCarRadiusMd)
            }
            .buttonStyle(PlainButtonStyle())
            
            Button(action: {
                Task {
                    await viewModel.generateStandardReminders()
                }
            }) {
                Text("Use Standard Schedule")
                    .font(.hotCarCaption)
                    .foregroundColor(.hotCarPrimary)
            }
        }
        .padding(.horizontal, 40)
    }
}

// MARK: - Reminder Row

struct ReminderRow: View {
    
    @StateObject private var viewModel = MaintenanceRemindersViewModel()
    let reminder: MaintenanceReminder
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: reminder.type.icon)
                .font(.system(size: 28))
                .foregroundColor(statusColor)
                .frame(width: 40)
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(reminder.title)
                    .font(.hotCarHeadline)
                    .foregroundColor(.textPrimary)
                
                Text(reminder.type.displayName)
                    .font(.hotCarCaption)
                    .foregroundColor(.textSecondary)
                
                if let dueDate = reminder.dueDate {
                    Text("Due: \(dueDate, style: .date)")
                        .font(.hotCarCaption)
                        .foregroundColor(.textSecondary)
                }
            }
            
            Spacer()
            
            // Status
            VStack(alignment: .trailing, spacing: 4) {
                Text(reminder.statusText)
                    .font(.hotCarCaption)
                    .foregroundColor(statusColor)
                
                if !reminder.isCompleted {
                    Button(action: {
                        Task {
                            await viewModel.completeReminder(reminder)
                        }
                    }) {
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(.warmUpReady)
                    }
                }
            }
        }
        .swipeActions(edge: .trailing) {
            if !reminder.isCompleted {
                Button(role: .destructive) {
                    Task {
                        await viewModel.deleteReminder(reminder)
                    }
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }
    
    private var statusColor: Color {
        if reminder.isCompleted {
            return .textMuted
        } else if reminder.isOverdue {
            return .warmUpActive
        } else {
            return .hotCarSecondary
        }
    }
}

// MARK: - Preview

#Preview {
    MaintenanceRemindersView(vehicleId: "1")
}
