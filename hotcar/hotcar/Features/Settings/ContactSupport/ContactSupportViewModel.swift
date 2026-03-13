//
//  ContactSupportViewModel.swift
//  hotcar
//
//  HotCar Settings - Contact Support ViewModel
//  Manages feedback submission to backend
//

import Foundation
import Combine

/// ViewModel for contact support / feedback form
/// Responsibility: Handle form validation and API submission
@MainActor
final class ContactSupportViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var selectedTopic: FeedbackTopic = .generalFeedback
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var message: String = ""
    @Published var isSubmitting: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var submitSuccess: Bool = false
    
    // MARK: - Constants
    
    private let feedbackAPIURL = "https://feedback-board.iocompile67692.workers.dev/api/feedback"
    private let appName = "HotCar"
    
    // MARK: - Computed Properties
    
    var canSubmit: Bool {
        !name.trimmed.isEmpty &&
        !email.trimmed.isEmpty &&
        email.isValidEmail &&
        !message.trimmed.isEmpty &&
        message.count <= 1000 &&
        !isSubmitting
    }
    
    // MARK: - Public Methods
    
    func submitFeedback() {
        guard canSubmit else { return }
        
        isSubmitting = true
        
        Task {
            do {
                try await sendFeedback()
                submitSuccess = true
                alertMessage = NSLocalizedString("feedback_success_message", tableName: "Localizable", comment: "Feedback success message")
            } catch {
                submitSuccess = false
                alertMessage = NSLocalizedString("feedback_error_message", tableName: "Localizable", comment: "Feedback error message")
            }
            
            isSubmitting = false
            showAlert = true
        }
    }
    
    // MARK: - Private Methods
    
    private func sendFeedback() async throws {
        guard let url = URL(string: feedbackAPIURL) else {
            throw FeedbackError.invalidURL
        }
        
        let feedbackData = FeedbackRequest(
            name: name.trimmed,
            email: email.trimmed,
            subject: selectedTopic.displayName,
            message: message.trimmed,
            app_name: appName
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(feedbackData)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw FeedbackError.serverError
        }
    }
}

// MARK: - Feedback Request Model

struct FeedbackRequest: Codable {
    let name: String
    let email: String
    let subject: String
    let message: String
    let app_name: String
}

// MARK: - Feedback Error

enum FeedbackError: Error {
    case invalidURL
    case serverError
    case networkError
}

// MARK: - String Extensions

extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
}
