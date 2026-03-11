//
//  TeslaAuthView.swift
//  hotcar
//
//  HotCar Feature - Tesla Authentication View
//  Login form for Tesla account
//

import SwiftUI

struct TeslaAuthView: View {
    
    // MARK: - Properties
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = RemoteStartViewModel()
    @State private var email = ""
    @State private var password = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Tesla Account")) {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $password)
                        .textContentType(.password)
                }
                
                Section {
                    Text("Your Tesla credentials are used only to authenticate with Tesla's API. They are stored securely on your device and never shared.")
                        .font(.hotCarCaption)
                        .foregroundColor(.textSecondary)
                }
                
                Section {
                    Button(action: authenticate) {
                        HStack {
                            Spacer()
                            
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Sign In")
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                    .disabled(email.isEmpty || password.isEmpty || viewModel.isLoading)
                }
            }
            .navigationTitle("Tesla Login")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Authentication Error", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Methods
    
    private func authenticate() {
        Task {
            let success = await viewModel.authenticate(email: email, password: password)
            
            if success {
                dismiss()
            } else {
                errorMessage = viewModel.errorMessage ?? "Authentication failed"
                showingError = true
            }
        }
    }
}

// MARK: - Preview

#Preview {
    TeslaAuthView()
}
