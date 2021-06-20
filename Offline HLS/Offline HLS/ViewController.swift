import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var progress: UIProgressView!
    
    @IBOutlet weak var download: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var assetDownloadTask: AVAssetDownloadTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progress.progress = 0
    }

    @IBAction func downloadAction(_ sender: Any) {
        showDownloadActivity()
        createBackgroundDownloadSession()
    }
    
    private func createBackgroundDownloadSession() {
        let url = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!
        
        let hlsAsset = AVURLAsset(url: url)
        
        let backgroundConfiguration = URLSessionConfiguration.background(withIdentifier: "assetDownloadConfigurationIdentifier \(Date().timeIntervalSince1970)")
        let assetURLSession = AVAssetDownloadURLSession(
            configuration: backgroundConfiguration,
            assetDownloadDelegate: self,
            delegateQueue: OperationQueue.main
        )
     
        assetDownloadTask = assetURLSession.makeAssetDownloadTask(
            asset: hlsAsset,
            assetTitle: "Clappr iOS Sample",
            assetArtworkData: nil,
            options: [AVAssetDownloadTaskMinimumRequiredMediaBitrateKey: 2_000_000]
        )!
        assetDownloadTask?.resume()
    }
    
    private func showDownloadActivity() {
        showActivityIndicator()
        deactivateDownloadButton()
    }
    
    private func stopDownloadActivity() {
        hideActivityIndicator()
        activateDownloadButton()
    }
    
    private func activateDownloadButton() {
        download.setTitle("DOWNLOAD FROM MASTER PLAYLIST", for: .normal)
        download.backgroundColor = download.backgroundColor?.withAlphaComponent(1)
        download.isEnabled = true
    }
    
    private func deactivateDownloadButton() {
        download.setTitle("", for: .normal)
        download.backgroundColor = download.backgroundColor?.withAlphaComponent(0.6)
        download.isEnabled = false
    }
    
    private func showActivityIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.alpha = 1
        activityIndicator.startAnimating()
    }
    
    private func hideActivityIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.alpha = 0
        activityIndicator.stopAnimating()
    }
    
    private func onSuccess() {
        showDialog(title: "Download Completed", content: "You can now play the HLS video while in offline.") { [weak self] in
            self?.stopDownloadActivity()
            self?.performSegue(withIdentifier: "playVideo", sender: self)
        }
    }
    
    private func onError() {
        showDialog(title: "Download Error", content: "Could not complete the download.") { [weak self] in
            self?.stopDownloadActivity()
        }
    }
    
    private func showDialog(title: String, content: String, onDissmis: @escaping ()-> Void) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        
        guard let controller = storyboard.instantiateViewController(identifier: "DialogViewController") as? DialogViewController else { return }
        
        controller.dialogTitle = title
        controller.dialogContent = content
        controller.onDissmis = onDissmis
        
        controller.attachTo(self.navigationController!)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "playVideo", let controller = segue.destination as? PlayVideoViewController else { return }
        
        guard let urlAsset = assetDownloadTask?.urlAsset else { return }
        
        controller.playerItem = AVPlayerItem(asset: urlAsset)
    }
}

extension ViewController: AVAssetDownloadDelegate {
    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didLoad timeRange: CMTimeRange, totalTimeRangesLoaded loadedTimeRanges: [NSValue], timeRangeExpectedToLoad: CMTimeRange) {
     
        var percenteComplete = 0.0
        for value in loadedTimeRanges {
            let loadedTimeRange: CMTimeRange = value.timeRangeValue
            percenteComplete += CMTimeGetSeconds(loadedTimeRange.duration) / CMTimeGetSeconds(timeRangeExpectedToLoad.duration)
        }
        
        progress.progress = Float(percenteComplete)
    }
    
    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didFinishDownloadingTo location: URL) {
        print("[Offline HLS] didFinishDownloadingTo: \(location)")
    }
    
    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didResolve resolvedMediaSelection: AVMediaSelection) {
        print()
    }
    
    func urlSession(_ session: URLSession, aggregateAssetDownloadTask: AVAggregateAssetDownloadTask, willDownloadTo location: URL) {
        print()
    }
    
    func urlSession(_ session: URLSession, aggregateAssetDownloadTask: AVAggregateAssetDownloadTask, didCompleteFor mediaSelection: AVMediaSelection) {
        print()
    }
    
    func urlSession(_ session: URLSession, aggregateAssetDownloadTask: AVAggregateAssetDownloadTask, didLoad timeRange: CMTimeRange, totalTimeRangesLoaded loadedTimeRanges: [NSValue], timeRangeExpectedToLoad: CMTimeRange, for mediaSelection: AVMediaSelection) {
        print()
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        stopDownloadActivity()
        
        if let _ = error {
            onError()
        } else {
            onSuccess()
        }
    }
}

