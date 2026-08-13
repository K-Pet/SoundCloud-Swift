//
//  StreamInfo.swift
//
//
//  Created by Ryan Forsyth on 2023-10-03.
//

/// Response from API containing URLs which the authenticated client can use to stream.
///
/// - Important: The MP3 and Opus transcodings were removed by SoundCloud on 2025-11-15.
/// Clients must use the AAC HLS transcodings, preferring ``hlsAAC160URL`` over ``hlsAAC96URL``.
/// Some older tracks may not have AAC transcodings available.
/// See the [deprecation notice on the SoundCloud API repo](https://github.com/soundcloud/api/issues/441).
public struct StreamInfo: Decodable {
    @available(*, deprecated, message: "Use AAC transcodings.")
    public let httpMp3128URL: String?

    @available(*, deprecated, message: "Use AAC transcodings.")
    public let hlsMp3128URL: String?

    /// "Optional, depending on availability"
    public let hlsAAC96URL: String?

    public let hlsAAC160URL: String?

    /// A 30 second snippet, returned in place of the full transcodings when the
    /// authenticated client isn't entitled to stream the track (Go+ / paid-only content).
    public let previewMp3128URL: String?
}

extension StreamInfo {
    internal enum CodingKeys: String, CodingKey {
        case httpMp3128URL = "httpMp3128Url"
        case hlsMp3128URL = "hlsMp3128Url"
        case hlsAAC96URL = "hlsAac96Url"
        case hlsAAC160URL = "hlsAac160Url"
        case previewMp3128URL = "previewMp3128Url"
    }
}

public extension StreamInfo {
    /// URLs for streaming the track in full, best quality first.
    ///
    /// Excludes preview snippets, and excludes the transcodings SoundCloud removed in 2025.
    var fullStreamURLs: [String] {
        [hlsAAC160URL, hlsAAC96URL].compactMap { $0 }
    }

    /// `true` when SoundCloud only offered a snippet, meaning the track can't be played in full.
    var isPreviewOnly: Bool {
        fullStreamURLs.isEmpty && previewMp3128URL != nil
    }
}
