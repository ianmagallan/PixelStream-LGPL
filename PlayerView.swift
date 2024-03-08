//
//  PlayerView.swift
//  VisionIPTV
//
//  Created by Ian Magallan Bosch on 21.02.24.
//

import KSPlayer
import SwiftUI
import StoreKit

struct PlayerView: View {
    
    @Environment(\.dismissWindow) 
    private var dismiss
    
    @Environment(\.scenePhase)
    private var scenePhase
    
    @State
    private var coordinator: KSVideoPlayer.Coordinator = .init()
    
    @State
    private var isInvalidated = false
    
    @Binding
    var url: URL?
    
    @Binding
    var title: String
    
    @Binding
    var isPlayable: Bool
    
    init(
        url: Binding<URL?>,
        title: Binding<String>,
        isPlayable: Binding<Bool>
    ) {
        self._url = url
        self._title = title
        self._isPlayable = isPlayable
    }

    var body: some View {
        Group {
            // Workaround to playerLayer not being deallocated. Without this, the audio is duplicated when the new URL binding is updated.
            if !isInvalidated, isPlayable {
                KSVideoPlayerView(
                    coordinator: coordinator,
                    url: $url,
                    title: $title
                )
                .onChange(of: scenePhase) { oldPhase, phase in
                    if phase == .background {
                        cleanUp()
                    }
                }
            }
            else if !isPlayable {
                StoreView()
                    .onChange(of: scenePhase) { oldPhase, phase in
                        if phase == .background {
                            cleanUp()
                        }
                    }
            }
            else {
                EmptyView()
            }
        }
        .onDisappear {
            url = nil
        }
    }
}

// MARK: Helpers

private extension PlayerView {
    
    func cleanUp() {
        coordinator.playerLayer?.player.shutdown()
        coordinator.resetPlayer()
        isInvalidated = true
        url = nil
    }
}
