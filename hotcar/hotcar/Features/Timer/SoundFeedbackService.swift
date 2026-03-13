//
//  SoundFeedbackService.swift
//  hotcar
//
//  HotCar Service - Sound Feedback Service
//  Provides audio feedback for warm-up events
//

import Foundation
import AVFoundation
import Combine

@MainActor
final class SoundFeedbackService: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = SoundFeedbackService()
    
    // MARK: - Audio Player
    
    private var audioPlayer: AVAudioPlayer?
    private var audioSession: AVAudioSession
    
    // MARK: - Published Properties
    
    @Published var isSoundEnabled: Bool = true
    @Published var isPlaying: Bool = false
    
    // MARK: - Sound Types
    
    enum SoundType: String, CaseIterable {
        case warmUpComplete = "warmup_complete"
        case timerStarted = "timer_started"
        case timerPaused = "timer_paused"
        case timerStopped = "timer_stopped"
        case timerWarning = "timer_warning"
        
        var systemSoundID: SystemSoundID {
            switch self {
            case .warmUpComplete:
                return 1025  // Complete sound
            case .timerStarted:
                return 1057  // Tweet sound
            case .timerPaused:
                return 1053  // Tock sound
            case .timerStopped:
                return 1054  // Tock sound
            case .timerWarning:
                return 1007  // Alert sound
            }
        }
        
        var displayName: String {
            switch self {
            case .warmUpComplete:
                return "Warm-up Complete"
            case .timerStarted:
                return "Timer Started"
            case .timerPaused:
                return "Timer Paused"
            case .timerStopped:
                return "Timer Stopped"
            case .timerWarning:
                return "Warning"
            }
        }
    }
    
    // MARK: - Initialization
    
    private init() {
        audioSession = AVAudioSession.sharedInstance()
        setupAudioSession()
        loadSettings()
    }
    
    // MARK: - Audio Session Setup
    
    private func setupAudioSession() {
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    // MARK: - Settings
    
    private func loadSettings() {
        isSoundEnabled = SettingsService.shared.settings.showNotifications
    }
    
    // MARK: - Play System Sound
    
    func playSound(_ soundType: SoundType) {
        guard isSoundEnabled else { return }
        
        AudioServicesPlaySystemSound(soundType.systemSoundID)
        isPlaying = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isPlaying = false
        }
    }
    
    // MARK: - Play Custom Sound
    
    func playCustomSound(named fileName: String, withExtension ext: String = "mp3") {
        guard isSoundEnabled else { return }
        
        guard let url = Bundle.main.url(forResource: fileName, withExtension: ext) else {
            playSound(.warmUpComplete)
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            isPlaying = true
        } catch {
            print("Failed to play custom sound: \(error)")
            playSound(.warmUpComplete)
        }
    }
    
    // MARK: - Play Sound with Haptic
    
    func playSoundWithHaptic(_ soundType: SoundType) {
        playSound(soundType)
        HapticFeedbackService.shared.timerComplete()
    }
    
    // MARK: - Stop Sound
    
    func stopSound() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
    }
    
    // MARK: - Integration with Timer Events
    
    func onTimerComplete() {
        playSoundWithHaptic(.warmUpComplete)
    }
    
    func onTimerStart() {
        playSound(.timerStarted)
    }
    
    func onTimerPause() {
        playSound(.timerPaused)
    }
    
    func onTimerStop() {
        playSound(.timerStopped)
    }
    
    func onTimerWarning() {
        playSound(.timerWarning)
    }
    
    // MARK: - Settings Update
    
    func refreshSettings() {
        loadSettings()
    }
}
