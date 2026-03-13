//
//  ContactSupportView.swift
//  hotcar
//
//  HotCar Settings - Contact Support / Feedback Form
//  User feedback submission with topic selection
//  Optimized for US/Canada/Nordic markets
//

import SwiftUI

/// Contact support view for user feedback
/// Responsibility: Display feedback form with topic selection and submit to backend
struct ContactSupportView: View {
    
    // MARK: - Properties
    
    @StateObject private var viewModel = ContactSupportViewModel()
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: HotCarSpacing.large) {
                    // Topic Selection
                    topicSection
                    
                    // Contact Information
                    contactInfoSection
                    
                    // Feedback Content
                    feedbackContentSection
                    
                    // Submit Button
                    submitButtonSection
                }
                .padding(HotCarLayout.screenMargin)
            }
            .background(Color.backgroundPrimary)
            .navigationTitle(NSLocalizedString("contact_support_title", tableName: "Localizable", comment: "Contact support page title"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.textSecondary)
                    }
                }
            }
            .alert(NSLocalizedString("feedback_alert_title", tableName: "Localizable", comment: "Feedback alert title"), isPresented: $viewModel.showAlert) {
                Button(NSLocalizedString("button_ok", tableName: "Localizable", comment: "OK button"), role: .cancel) {
                    if viewModel.submitSuccess {
                        dismiss()
                    }
                }
            } message: {
                Text(viewModel.alertMessage)
            }
        }
    }
    
    // MARK: - Topic Section
    
    private var topicSection: some View {
        VStack(alignment: .leading, spacing: HotCarSpacing.medium) {
            Text(NSLocalizedString("feedback_topic_label", tableName: "Localizable", comment: "Topic selection label"))
                .font(.hotCarHeadline)
                .foregroundColor(.textPrimary)
            
            // Topic selection grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: HotCarSpacing.medium) {
                ForEach(FeedbackTopic.allCases) { topic in
                    TopicButton(
                        topic: topic,
                        isSelected: viewModel.selectedTopic == topic,
                        action: { viewModel.selectedTopic = topic }
                    )
                }
            }
        }
    }
    
    // MARK: - Contact Info Section
    
    private var contactInfoSection: some View {
        VStack(alignment: .leading, spacing: HotCarSpacing.medium) {
            Text(NSLocalizedString("feedback_contact_label", tableName: "Localizable", comment: "Contact info label"))
                .font(.hotCarHeadline)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: HotCarSpacing.medium) {
                // Name field
                FormTextField(
                    title: NSLocalizedString("feedback_name_placeholder", tableName: "Localizable", comment: "Name placeholder"),
                    text: $viewModel.name,
                    icon: "person.fill"
                )
                
                // Email field
                FormTextField(
                    title: NSLocalizedString("feedback_email_placeholder", tableName: "Localizable", comment: "Email placeholder"),
                    text: $viewModel.email,
                    icon: "envelope.fill",
                    keyboardType: .emailAddress
                )
            }
        }
    }
    
    // MARK: - Feedback Content Section
    
    private var feedbackContentSection: some View {
        VStack(alignment: .leading, spacing: HotCarSpacing.medium) {
            Text(NSLocalizedString("feedback_message_label", tableName: "Localizable", comment: "Message label"))
                .font(.hotCarHeadline)
                .foregroundColor(.textPrimary)
            
            ZStack(alignment: .topLeading) {
                TextEditor(text: $viewModel.message)
                    .font(.hotCarBody)
                    .foregroundColor(.textPrimary)
                    .padding(HotCarSpacing.small)
                    .frame(minHeight: 150)
                    .background(Color.backgroundSecondary)
                    .cornerRadius(HotCarRadius.medium)
                    .overlay(
                        RoundedRectangle(cornerRadius: HotCarRadius.medium)
                            .stroke(Color.hotCarPrimary.opacity(viewModel.message.isEmpty ? 0.3 : 0.8), lineWidth: 1)
                    )
                
                if viewModel.message.isEmpty {
                    Text(NSLocalizedString("feedback_message_placeholder", tableName: "Localizable", comment: "Message placeholder"))
                        .font(.hotCarBody)
                        .foregroundColor(.textMuted)
                        .padding(.horizontal, HotCarSpacing.medium)
                        .padding(.vertical, HotCarSpacing.medium + 8)
                        .allowsHitTesting(false)
                }
            }
            
            // Character count
            HStack {
                Spacer()
                Text("\(viewModel.message.count) / 1000")
                    .font(.hotCarCaption)
                    .foregroundColor(viewModel.message.count > 1000 ? .warmUpActive : .textMuted)
            }
        }
    }
    
    // MARK: - Submit Button Section
    
    private var submitButtonSection: some View {
        Button(action: { viewModel.submitFeedback() }) {
            HStack {
                if viewModel.isSubmitting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "paperplane.fill")
                }
                
                Text(NSLocalizedString("feedback_submit_button", tableName: "Localizable", comment: "Submit button"))
                    .font(.hotCarHeadline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, HotCarSpacing.medium)
            .background(
                RoundedRectangle(cornerRadius: HotCarRadius.medium)
                    .fill(viewModel.canSubmit ? Color.hotCarPrimary : Color.hotCarPrimary.opacity(0.5))
            )
        }
        .disabled(!viewModel.canSubmit || viewModel.isSubmitting)
        .padding(.top, HotCarSpacing.medium)
    }
}

// MARK: - Topic Button

struct TopicButton: View {
    let topic: FeedbackTopic
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: HotCarSpacing.small) {
                Image(systemName: topic.icon)
                    .font(.system(size: 28))
                    .foregroundColor(isSelected ? .white : topic.color)
                
                Text(topic.displayName)
                    .font(.hotCarCaption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .white : .textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, HotCarSpacing.medium)
            .background(
                RoundedRectangle(cornerRadius: HotCarRadius.medium)
                    .fill(isSelected ? topic.color : Color.backgroundSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: HotCarRadius.medium)
                            .stroke(topic.color.opacity(isSelected ? 1 : 0.3), lineWidth: 2)
                    )
            )
        }
    }
}

// MARK: - Form Text Field

struct FormTextField: View {
    let title: String
    @Binding var text: String
    let icon: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        HStack(spacing: HotCarSpacing.small) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.textSecondary)
                .frame(width: 24)
            
            TextField(title, text: $text)
                .font(.hotCarBody)
                .foregroundColor(.textPrimary)
                .keyboardType(keyboardType)
                .autocapitalization(keyboardType == .emailAddress ? .none : .words)
                .disableAutocorrection(keyboardType == .emailAddress)
        }
        .padding(HotCarSpacing.medium)
        .background(
            RoundedRectangle(cornerRadius: HotCarRadius.medium)
                .fill(Color.backgroundSecondary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: HotCarRadius.medium)
                .stroke(Color.hotCarPrimary.opacity(text.isEmpty ? 0.3 : 0.8), lineWidth: 1)
        )
    }
}

// MARK: - Feedback Topic Enum

enum FeedbackTopic: String, CaseIterable, Identifiable {
    case bugReport = "bug"
    case featureRequest = "feature"
    case generalFeedback = "general"
    case support = "support"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .bugReport:
            return NSLocalizedString("topic_bug_report", tableName: "Localizable", comment: "Bug report topic")
        case .featureRequest:
            return NSLocalizedString("topic_feature_request", tableName: "Localizable", comment: "Feature request topic")
        case .generalFeedback:
            return NSLocalizedString("topic_general", tableName: "Localizable", comment: "General feedback topic")
        case .support:
            return NSLocalizedString("topic_support", tableName: "Localizable", comment: "Support topic")
        }
    }
    
    var icon: String {
        switch self {
        case .bugReport:
            return "ant.fill"
        case .featureRequest:
            return "lightbulb.fill"
        case .generalFeedback:
            return "message.fill"
        case .support:
            return "lifepreserver.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .bugReport:
            return .warmUpActive
        case .featureRequest:
            return .warmUpReady
        case .generalFeedback:
            return .hotCarPrimary
        case .support:
            return .hotCarSecondary
        }
    }
}

// MARK: - Preview

#Preview {
    ContactSupportView()
}
