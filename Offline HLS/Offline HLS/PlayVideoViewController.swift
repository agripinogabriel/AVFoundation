import UIKit
import AVFoundation

class PlayVideoViewController: UIViewController {
    @IBOutlet weak var playerView: UIView!
    
    @IBOutlet weak var playVideo: UIButton!
    
    var playerItem: AVPlayerItem?
    
    @IBAction func playAction(_ sender: Any) {
        let player = AVPlayer(playerItem: playerItem)

        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = playerView.bounds
        playerView.layer.addSublayer(playerLayer)
        
        player.play()
        
        playVideo.isEnabled = false
        playVideo.backgroundColor = playVideo.backgroundColor?.withAlphaComponent(0.6)
    }
}

