//
//  SmartReminderView.swift
//  hotcar
//
//  HotCar View - Smart Reminder Management
//  Allows users to set departure schedules
//

import SwiftUI

struct SmartReminderView: View {
    @StateObject private var viewModel = SmartReminderViewModel()
    @State private var showingAddSheet = false
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.schedules.isEmpty {
                    EmptyStateView(
                        icon: "clock.badge.checkmark",
                        title: "No Reminders",
                        message: "Set up smart reminders for your daily commute"
                    )
                } else {
                    List {
                        ForEach(viewModel.schedules) { schedule in
                            ReminderCard(
                                schedule: schedule,
                                onToggle: {
                                    Task {
                                        await viewModel.toggleSchedule(schedule.id)
                                    }
                                },
                                onDelete: {
                                    Task {
                                        await viewModel.deleteSchedule(schedule.id)
                                    }
                                }
                            )
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                Task {
                                    await viewModel.deleteSchedule(viewModel.schedules[index].id)
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Smart Reminders")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddReminderSheet(viewModel: viewModel)
            }
            .task {
                await viewModel.loadSchedules()
            }
        }
    }
}

struct ReminderCard: View {
    let schedule: ReminderSchedule
    let onToggle: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(formatTime(schedule.departureTime))
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(formatDays(schedule.repeatDays))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Toggle("", isOn: .init(
                    get: { schedule.isEnabled },
                    set: { _ in onToggle() }
                ))
            }
            
            HStack {
                Label("Advance: \(schedule.advanceNoticeMinutes) min", systemImage: "clock")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if let _ = schedule.vehicleId {
                    Label("Vehicle", systemImage: "car")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.backgroundCard)
        .cornerRadius(12)
        .contextMenu {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    func formatDays(_ days: Set<Weekday>) -> String {
        days.map { $0.displayName }.joined(separator: ", ")
    }
}

struct AddReminderSheet: View {
    @ObservedObject var viewModel: SmartReminderViewModel
    @Environment(\.dismiss) var dismiss
    @State private var departureTime = Date()
    @State private var selectedDays: Set<Weekday> = [.monday, .tuesday, .wednesday, .thursday, .friday]
    @State private var advanceNotice = 15
    @State private var selectedVehicleId: String?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Departure Time")) {
                    DatePicker("Time", selection: $departureTime, displayedComponents: .hourAndMinute)
                }
                
                Section(header: Text("Repeat")) {
                    ForEach(Weekday.allCases, id: \.self) { day in
                        Button(action: {
                            if selectedDays.contains(day) {
                                selectedDays.remove(day)
                            } else {
                                selectedDays.insert(day)
                            }
                        }) {
                            HStack {
                                Text(day.displayName)
                                Spacer()
                                if selectedDays.contains(day) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.accentColor)
                                }
                            }
                        }
                    }
                }
                
                Section(header: Text("Advance Notice")) {
                    Stepper("\(advanceNotice) minutes", value: $advanceNotice, in: 5...60, step: 5)
                }
                
                Section(header: Text("Vehicle (Optional)")) {
                    Picker("Vehicle", selection: $selectedVehicleId) {
                        Text("Any Vehicle").tag(nil as String?)
                        ForEach(viewModel.vehicles, id: \.id) { vehicle in
                            Text(vehicle.name).tag(vehicle.id as String?)
                        }
                    }
                }
            }
            .navigationTitle("Add Reminder")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            await viewModel.addSchedule(
                                departureTime: departureTime,
                                repeatDays: selectedDays,
                                advanceNotice: advanceNotice,
                                vehicleId: selectedVehicleId
                            )
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}

@MainActor
final class SmartReminderViewModel: ObservableObject {
    @Published var schedules: [ReminderSchedule] = []
    @Published var vehicles: [Vehicle] = []
    
    private let reminderService = SmartReminderService.shared
    private let vehicleService = VehicleService.shared
    
    func loadSchedules() async {
        await reminderService.loadSchedules()
        schedules = reminderService.schedules
        
        await vehicleService.loadVehicles()
        vehicles = vehicleService.vehicles
    }
    
    func addSchedule(
        departureTime: Date,
        repeatDays: Set<Weekday>,
        advanceNotice: Int,
        vehicleId: String?
    ) async {
        let schedule = ReminderSchedule(
            id: UUID().uuidString,
            departureTime: departureTime,
            isEnabled: true,
            repeatDays: repeatDays,
            vehicleId: vehicleId,
            customWarmUpTime: nil,
            advanceNoticeMinutes: advanceNotice,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        await reminderService.saveSchedule(schedule)
        schedules = reminderService.schedules
    }
    
    func toggleSchedule(_ scheduleId: String) async {
        await reminderService.toggleSchedule(scheduleId)
        schedules = reminderService.schedules
    }
    
    func deleteSchedule(_ scheduleId: String) async {
        await reminderService.deleteSchedule(scheduleId)
        schedules = reminderService.schedules
    }
}

#Preview {
    SmartReminderView()
}
