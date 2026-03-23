//
//  AvatarStore.swift
//  habittracker
//
//  Created by OpenAI Codex on 21/3/26.
//

import UIKit

final class AvatarStore {
    static let shared = AvatarStore()

    private let fileURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("profile_avatar.jpg")

    func loadImage() -> UIImage? {
        guard let data = try? Data(contentsOf: fileURL) else {
            return nil
        }
        return UIImage(data: data)
    }

    func saveImage(_ image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.85) else { return }
        try? data.write(to: fileURL, options: [.atomic])
    }

    func removeImage() {
        try? FileManager.default.removeItem(at: fileURL)
    }
}
