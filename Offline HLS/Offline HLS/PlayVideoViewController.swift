import UIKit
import AVFoundation

class PlayVideoViewController: UIViewController {
    
    @IBOutlet weak var playerView: UIView!
    
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var muteButton: UIButton!
    
    @IBOutlet weak var fullscreenButton: UIButton!
    
    @IBOutlet weak var mediaControlView: UIView!
    
    var playerItem: AVPlayerItem?
    
    private var player: AVPlayer?
    
    private var playerLayer: AVPlayerLayer?
    
    private var observers = [NSKeyValueObservation]()
    
    private var isReadyToPlay: Bool {
        return player?.currentItem?.status == .readyToPlay
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        preparePlayer()
    }
    
    private func preparePlayer() {
        player = AVPlayer(playerItem: playerItem)
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = playerView.bounds
        playerView.layer.addSublayer(playerLayer!)
    }
    
    @IBAction func playPlauseAction(_ sender: Any) {
        guard let player = player else { return }
        
        if player.rate <= 0.0 {
            player.play()
            playButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        } else {
            player.pause()
            playButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        }
    }
    
    @IBAction func muteAction(_ sender: Any) {
        guard let player = player else { return }
        
        if player.volume <= 0.0 {
            player.volume = 1.0
            muteButton.setImage(#imageLiteral(resourceName: "mute_off"), for: .normal)
        } else {
            player.volume = 0.0
            muteButton.setImage(#imageLiteral(resourceName: "mute_on"), for: .normal)
        }
    }
    
    @IBAction func fullscreenAction(_ sender: Any) {
    }
    
    private func observe(player: AVPlayer) {
        observers += [
            view.observe(\.bounds) { [weak self] view, _ in
                self?.maximizePlayer(within: view)
            },
        ]
    }
    
    private func maximizePlayer(within view: UIView) {
        guard let playerLayer = playerLayer else { return }
        
        playerLayer.frame = view.bounds
    }

    private func removePlayerObservers() {
        observers.forEach { $0.invalidate() }
        observers.removeAll()
    }
    
    deinit {
        removePlayerObservers()
        NotificationCenter.default.removeObserver(self)
    }
}

