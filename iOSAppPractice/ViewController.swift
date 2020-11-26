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
//    let musicList = [MusicList(songName: "Daft Punk", songImage: "Daft Punk"),
//                     MusicList(songName: "Hallelujah", songImage: "Hallelujah"),
//                     MusicList(songName: "La La Latch", songImage: "La La Latch"),
//                     MusicList(songName: "Papaoutai", songImage: "Papaoutai"),
//                     MusicList(songName: "Pretender", songImage: "Pretender")]
    var playIndex = 0
    let player = AVPlayer()
    var playerItem: AVPlayerItem?
    var musicArray: [MusicList]! = [MusicList]()
    let playIcon = UIImage(systemName: "play.fill")
    let pauseIcon = UIImage(systemName: "pause.fill")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        player.volume = 0.5
//        defaultTypeLoading()
        //音樂資料庫
        musicArray.append(MusicList(songName: "Daft Punk", songImage: "Daft Punk"))
        musicArray.append(MusicList(songName: "Hallelujah", songImage: "Hallelujah"))
        musicArray.append(MusicList(songName: "La La Latch", songImage: "La La Latch"))
        musicArray.append(MusicList(songName: "Papaoutai", songImage: "Papaoutai"))
        musicArray.append(MusicList(songName: "Pretender", songImage: "Pretender"))
        musicArray.shuffle()
        //播放音樂
        //播完繼續播下一首
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) { (_) in
            self.playIndex = self.playIndex + 1
            self.playMusic()
//            self.player.removeTimeObserver(self.currentTime())
        }
    }
    
    @IBAction func playNPauseButton(_ sender: UIButton) {
//        player.replaceCurrentItem(with: playerItem)
        //暫停的情況
        if player.rate == 0 {
            //當歌曲不是從一開始的地方播放
            if playingSlider.value != 0 {
                let seconds = Int64(playingSlider.value)
                let targetTime = CMTimeMake(value: seconds, timescale: 1)
                player.seek(to: targetTime)
                player.play()
                playNPause.setImage(pauseIcon, for: UIControl.State.normal)
            } else {
                playMusic()
                playNPause.setImage(pauseIcon, for: UIControl.State.normal)
            }
        } else if player.rate == 1 {
            player.pause()
            playNPause.setImage(playIcon, for: UIControl.State.normal)
        }
    }
    @IBAction func playNextButton(_ sender: UIButton) {
        playIndex = playIndex + 1
        playMusic()
    }
    @IBAction func playPreviousButton(_ sender: UIButton) {
        playIndex = playIndex - 1
        playMusic()
    }
    //拖曳slider，來設定player播放軌道
    @IBAction func playSliderChanged(_ sender: UISlider) {
        //slider移動的位置
        let seconds = Int64(playingSlider.value)
        //計算秒數
        let targetTime = CMTimeMake(value: seconds, timescale: 1)
        //將player播放進度移至slider的位置
        player.seek(to: targetTime)
    }
    //拖曳slider來設定聲音的大小
    @IBAction func volumeSliderChanged(_ sender: UISlider) {
        player.volume = sender.value
    }
    
    func playMusic() {
        if playIndex < musicArray.count {
            if playIndex < 0 {
                playIndex = musicArray.count - 1
            }
            let musicImage = musicArray[playIndex].songImage
            let musicName = musicArray[playIndex].songName
            let musicArtist = musicArray[playIndex].artistName
            //載入歌曲檔案
            let fileUrl = Bundle.main.url(forResource: musicName, withExtension: "mp3")
            playerItem = AVPlayerItem(url: fileUrl!)
            self.player.replaceCurrentItem(with: playerItem)
            self.player.play()
            //設定按鈕圖案，按下play圖案變成pause
            playNPause.setImage(pauseIcon, for: UIControl.State.normal)
            //設定coverImage圖示
            coverImage.image = UIImage(named: musicImage!)
            //設定歌曲及作家顯示
            songLabel.text = musicName!
            artistLabel.text = musicArtist!
            //更新進度條播放時的狀態
            currentTime()
            //更新進度條在不同歌曲的狀態
            updatePlayerUI()
        } else {
            playIndex = 0
            let musicImage = musicArray[playIndex].songImage
            let musicName = musicArray[playIndex].songName
            let musicArtist = musicArray[playIndex].artistName
            let fileUrl = Bundle.main.url(forResource: musicName, withExtension: "mp3")
            playerItem = AVPlayerItem(url: fileUrl!)
            self.player.replaceCurrentItem(with: playerItem)
            self.player.play()
            playNPause.setImage(pauseIcon, for: UIControl.State.normal)
            coverImage.image = UIImage(named: musicImage!)
            songLabel.text = musicName!
            artistLabel.text = musicArtist!
            currentTime()
            updatePlayerUI()
        }
    }
    //監聽現在播放時間&Slider Value
    func currentTime() {
        player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 1), queue: DispatchQueue.main, using: { (CMTime) in
            if self.player.currentItem?.status == .readyToPlay {
                //已跑秒數
                let currentTime = CMTimeGetSeconds(self.player.currentTime())
                //進度條跟著currentTime更新
                self.playingSlider.value = Float(currentTime)
                //currentTimeLabel跟著currentTime變換顯示
                self.currentTimeLabel.text = self.formatConversion(time: currentTime)
                let normal = UIImage(named: "12")
                self.playingSlider.setThumbImage(normal, for: UIControl.State.normal)
                let highlighted = UIImage(named: "24")
                self.playingSlider.setThumbImage(highlighted, for: UIControl.State.highlighted)
            }
        })
    }
    //更新歌曲的總時間&Slider Value
    func updatePlayerUI() {
        let duration = playerItem?.asset.duration
        let seconds = CMTimeGetSeconds(duration!)
        remainTimeLabel.text = "-" + formatConversion(time: seconds)
        playingSlider.minimumValue = 0
        playingSlider.maximumValue = Float(seconds)
        playingSlider.isContinuous = true
    }
    //時間秒數轉換
    func formatConversion(time: Double) -> String {
        let answer = Int(time).quotientAndRemainder(dividingBy: 60)
        let returnStr = String(answer.quotient) + ":" + String(format: "%.02d", answer.remainder)
        return returnStr
    }
//    func defaultTypeLoading() {
//        coverImage.image = UIImage(named: musicList[0].songName)
//        playNPause.setImage(playIcon, for: UIControl.State.normal)
//        songLabel.text = musicList[0].songName
//        artistLabel.text = musicList[0].artistName
//        currentTimeLabel.text = "0:00"
//        remainTimeLabel.text = "0:00"
//        playingSlider.value = 0
//        playingSlider.minimumValue = 0
//        playingSlider.maximumValue = 0
//    }
}

