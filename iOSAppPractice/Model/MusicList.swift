//
//  MusicList.swift
//  iOSAppPractice
//
//  Created by Tai Chin Huang on 2020/11/25.
//

import Foundation

struct Music: Codable, Equatable {
    // Local
    var artistName: String? = "Pentatonix"
    var trackName: String?
    var trackType: String? = "mp3"
    var songImage: String?
    var getFileUrl: URL? {
        let url = Bundle.main.url(forResource: trackName, withExtension: trackType)
        return url
    }
    // Online
    var artworkUrl100: String?
    var previewUrl: String?
    var getPreviewUrl: URL? {
        URL(string: previewUrl!)
    }
}

//struct Music: Codable {
//    let artistName: String?
//    let trackName: String?
//    let artworkUrl100: String?
//    let previewUrl: String?
//    var getPreviewUrl: URL? {
//        URL(string: previewUrl!)
//    }
//}

var musicLocal: [Music] = [Music(artistName: "Pentatonix",trackName: "Daft Punk",trackType: "mp3", songImage: "Daft Punk"),
                           Music(artistName: "Pentatonix",trackName: "Hallelujah",trackType: "mp3", songImage: "Hallelujah"),
                           Music(artistName: "Pentatonix",trackName: "La La Latch",trackType: "mp3", songImage: "La La Latch"),
                           Music(artistName: "Pentatonix",trackName: "Papaoutai",trackType: "mp3", songImage: "Papaoutai"),
                           Music(artistName: "Pentatonix",trackName: "Pretender",trackType: "mp3", songImage: "Pretender")
]

struct MusicOnline: Codable {
    let resultCount: Int
    let results: [Music]
}
// 分為不重播/全部重播/單首重播
enum RepeatType {
    case none
    case whole
    case one
}
// 分為不隨機播放/隨機播放
enum ShuffleType {
    case no
    case yes
}
