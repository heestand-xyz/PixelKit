//
//  Peer.swift
//  Pixel Nodes
//
//  Created by Hexagons on 2018-01-03.
//  Copyright © 2018 Hexagons. All rights reserved.
//

#if os(iOS)

import UIKit
import MultipeerConnectivity

enum PeerState {
    case dissconnected
    case connecting
    case connected
}

class Peer: NSObject, MCSessionDelegate, MCBrowserViewControllerDelegate {
    
    var peerID: MCPeerID!
    var mcSession: MCSession!
    var mcAdvertiserAssistant: MCAdvertiserAssistant!
    
    var imgInIndex: Int = 0
    var imgOutIndex: Int = 0
    
    var sendCallback: (() -> ())?
    
    let gotImg: ((UIImage) -> ())?
    let peer: (PeerState, String) -> ()
    let disconnect: (() -> ())?
    
    init(gotImg: ((UIImage) -> ())? = nil, peer: @escaping (PeerState, String) -> (), disconnect: (() -> ())? = nil) {
        
        self.peerID = MCPeerID(displayName: UIDevice.current.name)
        self.mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        
        self.gotImg = gotImg
        self.peer = peer
        self.disconnect = disconnect
        
        super.init()

        self.mcSession.delegate = self
        
    }
    
    func startHosting() {
        self.mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "pxn-stream", discoveryInfo: nil, session: mcSession)
        self.mcAdvertiserAssistant.start()
        imgInIndex = 0
        imgOutIndex = 0
    }
    
    func joinSession() {
        let mcBrowser = MCBrowserViewController(serviceType: "pxn-stream", session: mcSession)
        mcBrowser.delegate = self
        guard let vc = UIApplication.shared.keyWindow?.rootViewController else {
            PixelKit.main.logger.log(.warning, .connection, "Can't join stream session. No View Controller found.")
            return
        }
        vc.present(mcBrowser, animated: true)
        imgInIndex = 0
        imgOutIndex = 0
    }
    
    func sendImg(img: UIImage, quality: CGFloat) {
        sendCheck(index: imgOutIndex) {
            if !self.mcSession.connectedPeers.isEmpty {
                if let imageData = img.jpegData(compressionQuality: quality) {
                    do {
                        try self.mcSession.send(imageData, toPeers: self.mcSession.connectedPeers, with: .reliable)
                        self.imgOutIndex += 1
                    } catch let error as NSError {
                        PixelKit.main.logger.log(.error, .connection, "StreamPeer: Send Img.", e: error)
                    }
                }
            }
        }
    }
    
    func sendCheck(index: Int, callback: @escaping () -> ()) {
        sendCallback = callback
        if !mcSession.connectedPeers.isEmpty {
            do {
                try mcSession.send("check:\(index)".data(using: .utf8)!, toPeers: mcSession.connectedPeers, with: .reliable)
            } catch let error as NSError {
                PixelKit.main.logger.log(.error, .connection, "StreamPeer: Send Check.", e: error)
            }
        }
    }
    
    func sendChecked() {
        if !mcSession.connectedPeers.isEmpty {
            do {
                try mcSession.send("checked".data(using: .utf8)!, toPeers: mcSession.connectedPeers, with: .reliable)
            } catch let error as NSError {
                PixelKit.main.logger.log(.error, .connection, "StreamPeer: Send Checked.", e: error)
            }
        }
    }
    
    func sendDisconnect() {
        do {
            try mcSession.send("disconnect".data(using: .utf8)!, toPeers: mcSession.connectedPeers, with: .reliable)
        } catch let error as NSError {
            PixelKit.main.logger.log(.error, .connection, "StreamPeer: Send dissconnect.", e: error)
        }
        imgOutIndex = 0
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            switch state {
            case .connected:
                self.peer(.connected, peerID.displayName)
            case .connecting:
                self.peer(.connecting, peerID.displayName)
            case .notConnected:
                self.peer(.dissconnected, peerID.displayName)
            @unknown default:
                break
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let image = UIImage(data: data) {
            if self.gotImg != nil {
                DispatchQueue.main.async {
                    self.imgInIndex += 1
                    self.gotImg!(image)
                }
            }
        } else if let msg = String(data: data, encoding: .utf8) {
            if msg == "checked" {
                self.sendCallback?()
                self.sendCallback = nil
            } else if msg.starts(with: "check") {
                let index = Int(msg.split(separator: ":").last!)!
                ioCheck(index: index)
            } else if msg == "disconnect" {
                if self.disconnect != nil {
                    DispatchQueue.main.async {
                        self.disconnect!()
                        self.imgInIndex = 0
                    }
                }
            }
        }
    }
    
    func ioCheck(index: Int) {
        if index == imgInIndex {
            sendChecked()
        } else {
            PixelKit.main.logger.log(.warning, .connection, "StreamPeer: Waiting.")
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true, completion: nil)
    }
    
}

#endif
