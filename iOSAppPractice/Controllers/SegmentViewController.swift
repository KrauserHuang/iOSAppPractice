//
//  SegmentViewController.swift
//  iOSAppPractice
//
//  Created by Tai Chin Huang on 2021/4/7.
//

import UIKit

class SegmentViewController: UIViewController {
    // 儲存本地音樂
    var showFile: [Music] = musicLocal
    // 儲存線上音樂
    var showOnlineFile: [Music]?
    // 建立UISegmentedControl/UITableView
    let segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Local", "Online Preview"])
        sc.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        sc.selectedSegmentIndex = 0
        return sc
    }()
    let tableView = UITableView(frame: .zero, style: .plain)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "電台播放"
        // 將tableView的delegate/dataSource指定為自己(SegmentViewController)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SongTableViewCell.self, forCellReuseIdentifier: "TableCell")
        // 將segmentedControl/tableView整併在一個stackView上
        let stackView = UIStackView(arrangedSubviews: [segmentedControl, tableView])
        stackView.axis = .vertical
        view.addSubview(stackView)
        // AutoLayout
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        fetchMusic()
    }
    
    @objc func segmentChanged() {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            showFile = musicLocal
            tableView.reloadData()
        case 1:
            guard let showOnlineFile = showOnlineFile else { return }
            showFile = showOnlineFile
            tableView.reloadData()
        default:
            break
        }
    }
    // 先從網路抓資料
    func fetchMusic() {
        if let urlStr = "https://itunes.apple.com/search?term=宇多田光&media=music&country=JP".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            if let url = URL(string: urlStr) {
                URLSession.shared.dataTask(with: url) { (data, response, error) in
                    if let data = data {
                        let decoder = JSONDecoder()
                        do {
                            let result = try decoder.decode(MusicOnline.self, from: data)
                            self.showOnlineFile = result.results
                        } catch {
                            print(error)
                        }
                    }
                }.resume()
            }
        }
    }
}
//MARK: - Table View Data Source
extension SegmentViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showFile.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath) as! SongTableViewCell
        cell.nameLabel.text = showFile[indexPath.row].trackName
        print(showFile[indexPath.row].trackName!)
//        print(segmentedControl.selectedSegmentIndex)
        return cell
    }
}
//MARK: - Table View Delegate
extension SegmentViewController: UITableViewDelegate {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPlayer" {
            if let controller = segue.destination as? ViewController,
               let row = tableView.indexPathForSelectedRow?.row {
                controller.songs = showFile
                controller.songPlayed = showFile[row]
            }
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowPlayer", sender: self)
    }
}
