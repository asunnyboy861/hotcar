//
//  ShareView.swift
//  hotcar
//
//  HotCar Sharing - Share View
//  Social sharing interface for statistics
//

import SwiftUI

/// Share view for social sharing
/// Responsibility: Display sharing options and preview
struct ShareView: View {
    
    // MARK: - Properties
    
    @StateObject private var viewModel = ShareViewModel()
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: HotCarSpacing.large) {
                    // Period Selector
                    periodSelectorSection
                    
                    // Share Preview
                    sharePreviewSection
                    
                    // Share Options
                    shareOptionsSection
                    
                    // Share Text Preview
                    shareTextSection
                }
                .padding(HotCarLayout.screenMargin)
            }
            .background(Color.backgroundPrimary)
            .navigationTitle(NSLocalizedString("share_title", tableName: "Localizable", comment: "Share page title"))
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
            .onAppear {
                viewModel.updateShareData()
            }
        }
    }
    
    // MARK: - Period Selector Section
    
    private var periodSelectorSection: some View {
        VStack(alignment: .leading, spacing: HotCarSpacing.small) {
            Text(NSLocalizedString("share_select_period", tableName: "Localizable", comment: "Select period label"))
                .font(.hotCarCaption)
                .foregroundColor(.textSecondary)
            
            Picker("Period", selection: $viewModel.selectedPeriod) {
                Text(ShareData.SharePeriod.weekly.displayName)
                    .tag(ShareData.SharePeriod.weekly)
                Text(ShareData.SharePeriod.monthly.displayName)
                    .tag(ShareData.SharePeriod.monthly)
                Text(ShareData.SharePeriod.allTime.displayName)
                    .tag(ShareData.SharePeriod.allTime)
            }
            .pickerStyle(.segmented)
            .onChange(of: viewModel.selectedPeriod) { _ in
                viewModel.updateShareData()
            }
        }
    }
    
    // MARK: - Share Preview Section
    
    private var sharePreviewSection: some View {
        VStack(spacing: HotCarSpacing.medium) {
            Text(NSLocalizedString("share_preview", tableName: "Localizable", comment: "Preview label"))
                .font(.hotCarHeadline)
                .foregroundColor(.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Scaled down preview
            if let shareData = viewModel.shareData {
                ShareImageGenerator(data: shareData)
                    .frame(height: 400)
                    .clipShape(RoundedRectangle(cornerRadius: HotCarRadius.medium))
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)
            }
        }
    }
    
    // MARK: - Share Options Section
    
    private var shareOptionsSection: some View {
        VStack(spacing: HotCarSpacing.medium) {
            Text(NSLocalizedString("share_options", tableName: "Localizable", comment: "Share options label"))
                .font(.hotCarHeadline)
                .foregroundColor(.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: HotCarSpacing.small) {
                ShareButton(
                    icon: "square.and.arrow.up",
                    title: NSLocalizedString("share_system", tableName: "Localizable", comment: "System share"),
                    color: .hotCarPrimary
                ) {
                    viewModel.shareUsingSystem()
                }
                
                ShareButton(
                    icon: "doc.on.doc",
                    title: NSLocalizedString("share_copy_text", tableName: "Localizable", comment: "Copy text"),
                    color: .hotCarSecondary
                ) {
                    viewModel.copyShareText()
                }
                
                ShareButton(
                    icon: "photo",
                    title: NSLocalizedString("share_save_image", tableName: "Localizable", comment: "Save image"),
                    color: .warmUpReady
                ) {
                    viewModel.saveShareImage()
                }
            }
        }
    }
    
    // MARK: - Share Text Section
    
    private var shareTextSection: some View {
        VStack(alignment: .leading, spacing: HotCarSpacing.small) {
            Text(NSLocalizedString("share_text_preview", tableName: "Localizable", comment: "Text preview label"))
                .font(.hotCarCaption)
                .foregroundColor(.textSecondary)
            
            if let shareData = viewModel.shareData {
                Text(shareData.shareText)
                    .font(.hotCarBody)
                    .foregroundColor(.textPrimary)
                    .padding(HotCarSpacing.medium)
                    .background(
                        RoundedRectangle(cornerRadius: HotCarRadius.medium)
                            .fill(Color.backgroundSecondary)
                    )
            }
        }
    }
}

// MARK: - Share Button

struct ShareButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .frame(width: 32)
                
                Text(title)
                    .font(.hotCarHeadline)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.textMuted)
            }
            .foregroundColor(color)
            .padding(HotCarSpacing.medium)
            .background(
                RoundedRectangle(cornerRadius: HotCarRadius.medium)
                    .fill(Color.backgroundSecondary)
            )
        }
    }
}

// MARK: - View Model

@MainActor
final class ShareViewModel: ObservableObject {
    
    @Published var selectedPeriod: ShareData.SharePeriod = .weekly
    @Published var shareData: ShareData?
    @Published var showCopiedAlert = false
    @Published var showSavedAlert = false
    
    private let shareService = ShareService.shared
    
    func updateShareData() {
        shareData = shareService.generateShareData(for: selectedPeriod)
    }
    
    func shareUsingSystem() {
        guard let shareData = shareData else { return }
        
        // Get the root view controller
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return
        }
        
        shareService.share(data: shareData, from: rootViewController)
    }
    
    func copyShareText() {
        guard let shareData = shareData else { return }
        UIPasteboard.general.string = shareData.shareText
        showCopiedAlert = true
    }
    
    func saveShareImage() {
        guard let shareData = shareData,
              let image = shareService.generateShareImage(from: shareData) else {
            return
        }
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        showSavedAlert = true
    }
}

// MARK: - Preview

#Preview {
    ShareView()
}
