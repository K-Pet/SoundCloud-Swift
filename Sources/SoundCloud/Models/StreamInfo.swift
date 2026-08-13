//
//  StreamInfo.swift
//
//
//  Created by Ryan Forsyth on 2023-10-03.
//

/// Response from API containing URLs which the authenticated client can use to stream.
///
/// - Important: SoundCloud is migrating to AAC, but the migration is *not* complete.
/// Prefer ``hlsAAC160URL``, then ``hlsAAC96URL``, then fall back to ``hlsMp3128URL``:
/// as of 2026-08-05 SoundCloud state that tracks which haven't been re-transcoded
/// "still being available on mp3 only for up to a year", and advise clients to
/// "look for AAC first and MP3 second", as their own clients do.
/// Opus has already been removed.
/// See the [deprecation notice on the SoundCloud API repo](https://github.com/soundcloud/api/issues/441).
public struct StreamInfo: Decodable {
    /// Progressive download.
    ///
    /// - Warning: Do not use for playback. SoundCloud is retiring this ahead of the
    /// other transcodings and have "moved [it] to preview for a bit", so it can serve
    /// a 30 second snippet in place of the full track.
    @available(*, deprecated, message: "Progressive download is being retired and may serve a preview snippet.")
    public let httpMp3128URL: String?

    /// Still required as a fallback for tracks with no AAC transcoding yet.
    ///
    /// Deliberately *not* deprecated, despite being on SoundCloud's eventual removal
    /// list: it remains the only way to play a large part of the back catalogue, and
    /// marking it deprecated would mean suppressing a warning on the one code path
    /// that has to use it. Revisit once AAC coverage is complete.
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
    /// AAC first, then HLS MP3 — SoundCloud's own guidance while the back catalogue is
    /// still being re-transcoded (soundcloud/api#441). Tracks that never got an AAC
    /// transcoding are expected to remain MP3-only into 2027.
    ///
    /// Excludes preview snippets, and excludes ``httpMp3128URL``: progressive download
    /// is being retired first and can serve a 30 second snippet rather than the track.
    var fullStreamURLs: [String] {
        [hlsAAC160URL, hlsAAC96URL, hlsMp3128URL].compactMap { $0 }
    }

    /// `true` when SoundCloud only offered a snippet, meaning the track can't be played in full.
    var isPreviewOnly: Bool {
        fullStreamURLs.isEmpty && previewMp3128URL != nil
    }
}
