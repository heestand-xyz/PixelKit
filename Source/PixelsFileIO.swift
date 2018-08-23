//
//  PixelsFileIO.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-22.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import Foundation

extension Pixels {
    
    struct Info: Encodable {
        let name: String
        let id: UUID
    }
    
    enum PixelsIOError: Error {
        case runtimeERROR(String)
    }
    
    struct PIXPack: Encodable {
        let id: UUID
        let type: PIX.Kind
        let pix: PIX
        let inPixId: UUID?
        let inPixAId: UUID?
        let inPixBId: UUID?
        let inPixsIds: [UUID]?
    }
    
    struct Pack: Encodable {
        let signature: Signature
        let info: Info
        let pixs: [PIXPack]
    }
    
    /* public */ func export(as name: String, id: UUID = UUID(), share: Bool = false) throws -> String {
        let info = Info(name: name, id: id)
        let pixPacks = try pixList.map { pix -> PIXPack in
            var inPixId: UUID? = nil
            var inPixAId: UUID? = nil
            var inPixBId: UUID? = nil
            var inPixsIds: [UUID]? = nil
            if let pixIn = pix as? PIX & PIXIn {
                if let pixInSingle = pixIn as? PIX & PIXInSingle {
                    inPixId = pixInSingle.inPix?.id
                } else if let pixInMerger = pixIn as? PIX & PIXInMerger {
                    inPixAId = pixInMerger.inPixA?.id
                    inPixBId = pixInMerger.inPixB?.id
                } else if let pixInMulti = pixIn as? PIX & PIXInMulti {
                    inPixsIds = pixInMulti.inPixs.map({ outPix -> UUID in return outPix.id })
                }
            }
            guard let pixKind = (pix as? PIXofaKind)?.kind else {
                throw PixelsIOError.runtimeERROR("PixelsFile: PIX is not able.")
            }
            return PIXPack(id: pix.id, type: pixKind, pix: pix, inPixId: inPixId, inPixAId: inPixAId, inPixBId: inPixBId, inPixsIds: inPixsIds)
        }
        let pack = Pack(signature: signature, info: info, pixs: pixPacks)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let packJsonData = try encoder.encode(pack)
        guard let packJsonString = String(data: packJsonData, encoding: .utf8) else {
            throw PixelsIOError.runtimeERROR("PixelsFile: JSON data to string conversion failed.")
        }
        return packJsonString
    }
    
    public struct PixelsFile {
        public let id: UUID
        public let name: String
        public let pixs: [PIX]
    }
    
    struct PIXWithInIds {
        let pix: PIX
        let inPixId: UUID?
        let inPixAId: UUID?
        let inPixBId: UUID?
        let inPixsIds: [UUID]?
    }
    
    /* public */ func create(from jsonString: String) throws -> PixelsFile {
        
        let decoder = JSONDecoder()
        
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw PixelsIOError.runtimeERROR("PixelsFile: JSON string to data conversion failed.")
        }
        
        let json = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)
        
        guard let jsonDict = json as? [String: Any] else {
            throw PixelsIOError.runtimeERROR("PixelsFile: JSON object to dict conversion failed.")
        }
        
        guard let hxhDict = jsonDict["hxh"] as? [String: Any] else {
            throw PixelsIOError.runtimeERROR("PixelsFile: HxH is not valid.")
        }
        guard let bundleId = hxhDict["id"] as? String else {
            throw PixelsIOError.runtimeERROR("PixelsFile: HxH ID is not valid.")
        }
        if bundleId != kBundleId {
            throw PixelsIOError.runtimeERROR("This JSON file is for another engine.")
        }
        
        guard let pixelsFileDict = jsonDict["pixels"] as? [String: Any] else {
            throw PixelsIOError.runtimeERROR("PixelsFile: PixelsFile is not valid.")
        }
        guard let idStr = pixelsFileDict["id"] as? String else {
            throw PixelsIOError.runtimeERROR("PixelsFile: PixelsFile ID is not valid.")
        }
        guard let id = UUID(uuidString: idStr) else {
            throw PixelsIOError.runtimeERROR("PixelsFile: PixelsFile ID is corrupt.")
        }
        guard let name = pixelsFileDict["name"] as? String else {
            throw PixelsIOError.runtimeERROR("PixelsFile: PixelsFile Name is not valid.")
        }
        
        guard let pixPackDictList = jsonDict["pixs"] as? [[String: Any]] else {
            throw PixelsIOError.runtimeERROR("PixelsFile: PIX List is corrupt.")
        }
        var pixsWithInIds: [PIXWithInIds] = []
        for pixPackDict in pixPackDictList {
            guard let idStr = pixPackDict["id"] as? String else {
                throw PixelsIOError.runtimeERROR("PixelsFile: PIX ID is not valid.")
            }
            guard let id = UUID(uuidString: idStr) else {
                throw PixelsIOError.runtimeERROR("PixelsFile: PIX ID is corrupt.")
            }
            guard let pixKindStr = pixPackDict["type"] as? String else {
                throw PixelsIOError.runtimeERROR("PixelsFile: PIX Type is not valid.")
            }
            guard let pixType = PIX.Kind.init(rawValue: pixKindStr)?.type else {
                throw PixelsIOError.runtimeERROR("PixelsFile: PIX Kind is not valid.")
            }
            guard let pixDict = pixPackDict["pix"] as? [String: Any] else {
                throw PixelsIOError.runtimeERROR("PixelsFile: \(pixType) dict is corrupt.")
            }
            let pixJsonData = try JSONSerialization.data(withJSONObject: pixDict, options: .prettyPrinted)
            let pix = try decoder.decode(pixType, from: pixJsonData)
            pix.id = id
            
            var inPixId: UUID? = nil
            var inPixAId: UUID? = nil
            var inPixBId: UUID? = nil
            var inPixsIds: [UUID]? = nil
            func getInPixId(_ key: String) throws -> UUID {
                guard let inPixIdStr = pixPackDict[key] as? String else {
                    throw PixelsIOError.runtimeERROR("PixelsFile: PIX In ID not found.")
                }
                guard let inPixId = UUID(uuidString: inPixIdStr) else {
                    throw PixelsIOError.runtimeERROR("PixelsFile: PIX In ID is corrupt.")
                }
                return inPixId
            }
            if let pixIn = pix as? PIX & PIXIn {
                if let pixInSingle = pixIn as? PIX & PIXInSingle {
                    inPixId = try? getInPixId("inPixId")
                } else if let pixInMerger = pixIn as? PIX & PIXInMerger {
                    inPixAId = try? getInPixId("inPixAId")
                    inPixBId = try? getInPixId("inPixBId")
                } else if let pixInMulti = pixIn as? PIX & PIXInMulti {
                    guard let inPixsIdsStrArr = pixPackDict["inPixsIds"] as? [String] else {
                        throw PixelsIOError.runtimeERROR("PixelsFile: PIX Ins IDs not found.")
                    }
                    inPixsIds = []
                    for inPixIdStr in inPixsIdsStrArr {
                        guard let iInPixId = UUID(uuidString: inPixIdStr) else {
                            throw PixelsIOError.runtimeERROR("PixelsFile: PIX In(s) is corrupt.")
                        }
                        inPixsIds?.append(iInPixId)
                    }
                }
            }
            
            let pixWithInIds = PIXWithInIds(pix: pix, inPixId: inPixId, inPixAId: inPixAId, inPixBId: inPixBId, inPixsIds: inPixsIds)
            pixsWithInIds.append(pixWithInIds)
        }
        
        let pixs = pixsWithInIds.map { pixWithInIds -> PIX in return pixWithInIds.pix }
        
        func findPixOut(by id: UUID) throws -> PIX & PIXOut {
            for pix in pixs {
                if pix.id == id {
                    guard let pixOut = pix as? PIX & PIXOut else {
                        throw PixelsIOError.runtimeERROR("PixelsFile: PIX In is not Out.")
                    }
                    return pixOut
                }
            }
            throw PixelsIOError.runtimeERROR("PixelsFile: PIX In not found.")
        }
        
        for pixWithInIds in pixsWithInIds {
            if let pixIn = pixWithInIds.pix as? PIX & PIXIn {
                if var pixInSingle = pixIn as? PIX & PIXInSingle {
                    if pixWithInIds.inPixId != nil {
                        pixInSingle.inPix = try findPixOut(by: pixWithInIds.inPixId!)
                    }
                } else if var pixInMerger = pixIn as? PIX & PIXInMerger {
                    if pixWithInIds.inPixAId != nil {
                        pixInMerger.inPixA = try findPixOut(by: pixWithInIds.inPixAId!)
                    }
                    if pixWithInIds.inPixBId != nil {
                        pixInMerger.inPixB = try findPixOut(by: pixWithInIds.inPixBId!)
                    }
                } else if var pixInMulti = pixIn as? PIX & PIXInMulti {
                    if pixWithInIds.inPixsIds != nil {
                        for pixId in pixWithInIds.inPixsIds! {
                            pixInMulti.inPixs.append(try findPixOut(by: pixId))
                        }
                    }
                }
            }
        }
        
        let pixelsFile = PixelsFile(id: id, name: name, pixs: pixs)
        return pixelsFile
    }
    
}
