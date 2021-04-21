//
//  ViewController.swift
//  iOSAppPractice
//
//  Created by Tai Chin Huang on 2020/11/23.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var playingSlider: UISlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var remainTimeLabel: UILabel!
    @IBOutlet weak var playNPause: UIButton!
    @IBOutlet weak var playNext: UIButton!
    @IBOutlet weak var playPrevious: UIButton!
    @IBOutlet weak var playShuffle: UIButton!
    @IBOutlet weak var playRepeat: UIButton!
    
    var songPlayed: Music?
    var songs: [Music]!
    var songDefault: [Music]?
    var songURL: URL {
        if let previewUrl = songPlayed?.previewUrl {
            return (songPlayed?.getPreviewUrl)!
        } else {
            return (songPlayed?.getFileUrl)!
        }
    }
    var playingIndex: Int!
    var repeatType = RepeatType.none
    var shuffleType = ShuffleType.no
    var playerItem: AVPlayerItem?
    var playerLooper: AVPlayerLooper?
    // 建立共用player
    var player = AVPlayerController.shared.player
    
    override func viewDidLoad() {
        super.viewDidLoad()
        defaultSetup()
        /*
         循環播放設定，當音樂播完時開始判斷
         .none:播放整個list完中斷
         .whole:一直播一直播一直循環list不中斷
         .one:一直播一直播一直循環同一首歌
         */
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) { (_) in
            self.repeatStateCheck()
//            switch self.repeatType {
//            case .none:
//                self.playingIndex = self.songs.firstIndex(of: self.songPlayed!)
//                self.playingIndex += 1
//                if self.playingIndex == self.songs.count {
//                    self.player.pause()
//                    self.playNPause.setImage(UIImage(systemName: SystemName.playFill), for: .normal)
//                } else {
//                    self.songPlayed = self.songs![self.playingIndex]
//                    self.playerItem = AVPlayerItem(url: self.songURL)
//                    self.playerLooper = AVPlayerLooper(player: self.player, templateItem: self.playerItem!)
//                    self.configurePlayer(song: self.songPlayed!)
//                    self.player.play()
//                }
//            case .whole:
//                self.playingIndex = self.songs.firstIndex(of: self.songPlayed!)
//                print(self.playingIndex!)
//                self.playingIndex += 1
//                if self.playingIndex == self.songs.count {
//                    self.playingIndex = 0
//                }
//                self.songPlayed = self.songs![self.playingIndex]
//                self.playerItem = AVPlayerItem(url: self.songURL)
//                self.playerLooper = AVPlayerLooper(player: self.player, templateItem: self.playerItem!)
//                self.configurePlayer(song: self.songPlayed!)
//                self.player.play()
//            case .one:
//                self.playerItem = AVPlayerItem(url: self.songURL)
//                self.playerLooper = AVPlayerLooper(player: self.player, templateItem: self.playerItem!)
//                self.player.play()
//            }
        }
    }
    func defaultSetup() {
        /*
         1.載入所選音樂(包括歌曲、作家、封面)
         2.所選音樂時間長度
         3.按鈕圖面預設
         4.音量預設
         */
        configurePlayer(song: songPlayed!)
        currentTime()
        playNPause.setImage(UIImage(systemName: SystemName.pauseFill), for: .normal)
        playShuffle.setImage(UIImage(systemName: SystemName.shuffleCircle), for: .normal)
        playRepeat.setImage(UIImage(systemName: SystemName.repeatCircle), for: .normal)
        player.volume = 0.5
        player.play()
    }
    // 初始player，包括載入音樂、設定時間長度、顯示歌曲、作者、封面
    func configurePlayer(song: Music) {
        playerItem = AVPlayerItem(url: songURL)
        player.replaceCurrentItem(with: playerItem)
        let duration = playerItem?.asset.duration
        let seconds = CMTimeGetSeconds(duration!)
        playingSlider.minimumValue = 0
        playingSlider.maximumValue = Float(seconds)
        songLabel.text = songPlayed?.trackName
        artistLabel.text = songPlayed?.artistName
        if let urlStr = songPlayed?.artworkUrl100,
           let url = URL(string: urlStr) {
            fetchImage(url: url) { (image) in
                DispatchQueue.main.async {
                    self.coverImage.image = image
                    print("Fetch online image success")
                }
            }
        } else {
            coverImage.image = UIImage(named: (songPlayed?.songImage)!)
            print("Fetch local imgae success")
        }
    }
    
    //MARK: - All About Player(play/pause/next/previous/shuffle/repeat)
    // 播放與暫停
    @IBAction func playNPausePressed(_ sender: UIButton) {
        switch player.timeControlStatus {
        // 暫停的情況，點下去開始播放
        case .paused:
            playNPause.setImage(UIImage(systemName: SystemName.pauseFill), for: .normal)
            player.play()
        // 播放的情況，點下去暫停
        case .playing:
            playNPause.setImage(UIImage(systemName: SystemName.playFill), for: .normal)
            player.pause()
        default:
            break
        }
    }
    // 播放下一首，當是暫停的點選，介面也還要是暫停的，再點選播放才播下一首
    func playNextSong() {
        switch player.timeControlStatus {
        case .paused:
            playNPause.setImage(UIImage(systemName: SystemName.playFill), for: .normal)
            player.pause()
            let time = CMTime(value: 0, timescale: 1)
            player.seek(to: time)
            playingIndex = songs.firstIndex(of: songPlayed!)
            playingIndex += 1
            if playingIndex == songs?.count {
                playingIndex = 0
            }
            songPlayed = songs![playingIndex]
            configurePlayer(song: songPlayed!)
        case .playing:
            playingIndex = songs.firstIndex(of: songPlayed!)
            print("first: List\(playingIndex!)")
            playingIndex += 1
            if playingIndex == songs?.count {
                playingIndex = 0
            }
            songPlayed = songs![playingIndex]
            configurePlayer(song: songPlayed!)
            player.play()
            print("second: List\(playingIndex!)")
        default:
            break
        }
    }
    @IBAction func playNextPressed(_ sender: UIButton) {
        playNextSong()
    }
    // 播放上一首，當repeatType為單首，則必須一樣播放同一首
    @IBAction func playPreviousPressed(_ sender: UIButton) {
        if repeatType == .one {
            playingIndex = songs.firstIndex(of: songPlayed!)
            songPlayed = songs![playingIndex]
            configurePlayer(song: songPlayed!)
            player.play()
        } else {
            playingIndex = songs.firstIndex(of: songPlayed!)
            print("first: List\(playingIndex!)")
            playingIndex -= 1
            if playingIndex == -1 {
                playingIndex = songs!.count - 1
            }
            songPlayed = songs![playingIndex]
            configurePlayer(song: songPlayed!)
            player.play()
            print("second: List\(playingIndex!)")
        }
    }
    // 隨機播放，預設無，點選變成有
    @IBAction func playShufflePressed(_ sender: UIButton) {
        switch shuffleType {
        case .no:
            shuffleType = .yes
            playShuffle.setImage(UIImage(systemName: SystemName.shuffleCircleFill), for: .normal)
            songs?.shuffle()
        case .yes:
            shuffleType = .no
            playShuffle.setImage(UIImage(systemName: SystemName.shuffleCircle), for: .normal)
            // 將歌單改回預設
            songs = songDefault
        }
    }
    // 重複播放，預設無，順序無>全部>單首，這邊的按鈕只關注改圖示，功能部分應該由AVPlayerItemDidPlayToEndTime判斷
    @IBAction func playRepeatPressed(_ sender: UIButton) {
        switch repeatType {
        case .none:
            repeatType = .whole
            playRepeat.setImage(UIImage(systemName: SystemName.repeatCircleFill), for: .normal)
        case .whole:
            repeatType = .one
            playRepeat.setImage(UIImage(systemName: SystemName.repeat1CircleFill), for: .normal)
        case .one:
            repeatType = .none
            playRepeat.setImage(UIImage(systemName: SystemName.repeatCircle), for: .normal)
        }
    }
    
    //MARK: - All About Slider(player/volume)
    //拖曳slider，來設定player播放軌道
    @IBAction func playSliderChanged(_ sender: UISlider) {
        //slider移動的位置
        let seconds = Int64(sender.value)
        //計算秒數
        let targetTime = CMTimeMake(value: seconds, timescale: 1)
        //將player播放進度移至slider的位置所換算的秒數位置
        player.seek(to: targetTime)
        // true:滑動的時候音樂會中斷，false:滑動時音樂不中斷
        playingSlider.isContinuous = false
        // 設定slider移動後的圖示，normal為自動跑的時候，highlighted為使用者拖拉時的變化
        let normal = UIImage(named: "12")
        playingSlider.setThumbImage(normal, for: UIControl.State.normal)
        let highlighted = UIImage(named: "24")
        playingSlider.setThumbImage(highlighted, for: UIControl.State.highlighted)
    }
    //拖曳slider來設定聲音的大小
    @IBAction func volumeSliderChanged(_ sender: UISlider) {
        player.volume = sender.value
    }
    
    //MARK: - Other functions(TimeObserver/formatConvert/fetchImage)
    // 設定通知中心接收現在播放時間/剩餘播放時間&Slider Value
    func currentTime() {
        player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 1), queue: DispatchQueue.main, using: { (CMTime) in
            if self.player.currentItem?.status == .readyToPlay {
                //已跑秒數
                let currentTime = CMTimeGetSeconds(self.player.currentTime())
                //進度條跟著currentTime更新
                self.playingSlider.value = Float(currentTime)
                /*
                 currentTimeLabel跟著currentTime變換顯示
                 remainTimeLabel由slider最大值減去經過時間前方再加個負號
                 ex: 經過時間：30秒，整首4分30秒
                 max = 270, 270 - 30 = 240, formatConversion(240) = 4分鐘
                 remainTimeLabel = -formatConversion(240) = -4分鐘
                 */
                self.currentTimeLabel.text = self.formatConversion(time: currentTime)
                self.remainTimeLabel.text = "-\(self.formatConversion(time: Double(self.playingSlider.maximumValue) - currentTime))"
            }
        })
    }
    // 時間秒數轉換
    func formatConversion(time: Double) -> String {
        // quotient為商數，remainder為餘數，returnStr回傳“幾分：幾秒”
        let answer = Int(time).quotientAndRemainder(dividingBy: 60)
        let returnStr = "\(answer.quotient):\(String(format: "%.2d", answer.remainder))"
        return returnStr
    }
    // 抓圖，還搞不懂
    func fetchImage(url: URL, completionHandler: @escaping (UIImage?) -> ()) {
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data,
               let image = UIImage(data: data) {
                completionHandler(image)
            } else {
                completionHandler(nil)
            }
        }.resume()
    }
    /*
     1.設定playingIndex
     2.判斷3種repeatType
     2-1. .none代表只輪播一次list，所以當playingIndex來到最後一首歌後播完就停止
     2-2. .whole一直循環播放（等同於播完一首就撥下一首，playingIndex超出就歸0）
     2-3. .one循環同一首，所以不用設定playingIndex，透過點選下一首才會更新playingIndex
     3.再設定要播放的songPlayed
     4.設定對應的作家、歌曲、封面、時間
     5.設定playerItem（要替換的歌曲）
     6.設定循環播放（其實只有在.one這個設定有效），但為了播放使用（當AVPlayer()用）
     7.player.play()
     */
    func repeatStateCheck() {
        switch repeatType {
        case .none:
            playingIndex = songs.firstIndex(of: songPlayed!)
            playingIndex += 1
            if playingIndex == songs.count {
                player.pause()
                playNPause.setImage(UIImage(systemName: SystemName.playFill), for: .normal)
            } else {
                songPlayed = songs[playingIndex]
                configurePlayer(song: songPlayed!)
                playerItem = AVPlayerItem(url: songURL)
                playerLooper = AVPlayerLooper(player: player, templateItem: playerItem!)
                player.play()
            }
        case .whole:
            playingIndex = songs.firstIndex(of: songPlayed!)
            playingIndex += 1
            if playingIndex == songs.count {
                playingIndex = 0
            }
            songPlayed = songs[playingIndex]
            configurePlayer(song: songPlayed!)
            playerItem = AVPlayerItem(url: songURL)
            playerLooper = AVPlayerLooper(player: player, templateItem: playerItem!)
            player.play()
        case .one:
            playerItem = AVPlayerItem(url: songURL)
            playerLooper = AVPlayerLooper(player: player, templateItem: playerItem!)
            player.play()
        }
    }
}
