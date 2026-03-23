//
//  ProfileViewModel.swift
//  habittracker
//
//  Created by OpenAI Codex on 21/3/26.
//

import UIKit
import Combine

final class ProfileViewModel: ObservableObject {
    @Published private(set) var stats: UsageStats = .empty
    @Published private(set) var avatarImage: UIImage?

    private let store: HabitStore
    private let avatarStore: AvatarStore
    private var cancellables: Set<AnyCancellable> = []

    init(store: HabitStore, avatarStore: AvatarStore = .shared) {
        self.store = store
        self.avatarStore = avatarStore
        self.avatarImage = avatarStore.loadImage()
        self.stats = store.usageStats()

        store.objectWillChange
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.refreshStats()
                }
            }
            .store(in: &cancellables)
    }

    func saveAvatar(_ image: UIImage) {
        avatarStore.saveImage(image)
        avatarImage = avatarStore.loadImage()
    }

    func removeAvatar() {
        avatarStore.removeImage()
        avatarImage = nil
    }

    private func refreshStats() {
        stats = store.usageStats()
    }
}
