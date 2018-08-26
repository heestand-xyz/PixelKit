//
//  PixelsFileIO.swift
//  Pixels
//
//  Created by Hexagons on 2018-08-22.
//  Copyright © 2018 Hexagons. All rights reserved.
//

import MetalKit

extension Pixels {
    
    enum FileIOError: Error {
        case export(String)
        case `import`(String)
    }
    
    public struct ColorSettings: Encodable {
        var bits: PIX.Color.Bits
        var space: PIX.Color.Space
    }
    
    public struct ProjectSettings: Encodable {
        var color: ColorSettings
        var generatorsGlobalResMultiplier: CGFloat
    }
    
    public struct ProjectInfo: Encodable {
        let name: String
        let id: UUID
    }
    
    public struct PIXGeneratorSettings: Encodable {
        let res: String
        let premultiply: Bool
    }

    public struct PIXSettings: Encodable {
        let interpolate: PIX.InterpolateMode
        let extend: PIX.ExtendMode
        let generator: PIXGeneratorSettings?
    }
    
    struct PIXPack: Encodable {
        let id: UUID
        let name: String?
        let kind: PIX.Kind
        let inPixId: UUID?
        let inPixAId: UUID?
        let inPixBId: UUID?
        let inPixsIds: [UUID]?
        let pix: PIX
        let settings: PIXSettings
    }
    
    struct Pack: Encodable {
        let framework: Signature
        let info: ProjectInfo
        let settings: ProjectSettings
        let pixs: [PIXPack]
    }
    
    public func export(name: String = "", id: UUID = UUID()) throws -> String {
        let info = ProjectInfo(name: name, id: id)
        let pixPacks = try linkedPixs.map { pix -> PIXPack in
            let (inPixId, inPixAId, inPixBId, inPixsIds) = inPixIDs(from: pix)
            guard let pixKind = (pix as? PIXofaKind)?.kind else {
                throw FileIOError.export("Pixels export: PIX is not of a kind.")
            }
            var genSettings: PIXGeneratorSettings? = nil
            if let genPix = pix as? PIXGenerator {
                let autoRes = genPix._res == .fullScreen ? "fullScreen" : "\(genPix._res.w)x\(genPix._res.h)"
                genSettings = PIXGeneratorSettings(res: autoRes, premultiply: genPix.premultiply)
            }
            let pixSettings = PIXSettings(interpolate: pix.interpolate, extend: pix.extend, generator: genSettings)
            return PIXPack(id: pix.id, name: pix.name, kind: pixKind, inPixId: inPixId, inPixAId: inPixAId, inPixBId: inPixBId, inPixsIds: inPixsIds, pix: pix, settings: pixSettings)
        }
        let colorSettings = ColorSettings(bits: colorBits, space: colorSpace)
        let settings = ProjectSettings(color: colorSettings, generatorsGlobalResMultiplier: PIXGenerator.globalResMultiplier)
        let pack = Pack(framework: signature, info: info, settings: settings, pixs: pixPacks)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let packJsonData = try encoder.encode(pack)
        guard let packJsonString = String(data: packJsonData, encoding: .utf8) else {
            throw FileIOError.export("Pixels export: JSON data to string conversion failed.")
        }
        log(.info, .fileIO, "Export successful.")
        return packJsonString
    }
    
    func inPixIDs(from pix: PIX) -> (inPixId: UUID?, inPixAId: UUID?, inPixBId: UUID?, inPixsIds: [UUID]?) {
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
        return (inPixId, inPixAId, inPixBId, inPixsIds)
    }
    
    public struct Project {
        public let info: ProjectInfo
        public let pixs: [PIX]
    }
    
    struct PIXImportPack {
        let pix: PIX
        let settings: PIXSettings
        let inPixId: UUID?
        let inPixAId: UUID?
        let inPixBId: UUID?
        let inPixsIds: [UUID]?
    }
    
    public func `import`(json: String) throws -> Project {
        
        let decoder = JSONDecoder()
        
        guard let jsonData = json.data(using: .utf8) else {
            throw FileIOError.import("Pixels import: JSON string to data conversion failed.")
        }
        
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments)
        
        guard let jsonDict = jsonObject as? [String: Any] else {
            throw FileIOError.import("Pixels import: JSON object to dict conversion failed.")
        }
        
        // MARK: Compatibility Check
        guard let frameworkDict = jsonDict["framework"] as? [String: Any] else {
            throw FileIOError.import("Pixels import: HxH is not valid.")
        }
        guard let bundleName = frameworkDict["name"] as? String else {
            throw FileIOError.import("Pixels import: Framework Name is not valid.")
        }
        guard let bundleId = frameworkDict["id"] as? String else {
            throw FileIOError.import("Pixels import: Framework ID is not valid.")
        }
        if bundleId != kBundleId {
            throw FileIOError.import("Pixels import: This JSON file, for framework \(bundleName) is not compatible with Pixels. Bundle ID missmatch.")
        }
        guard let version = frameworkDict["version"] as? String else {
            throw FileIOError.import("Pixels import: Framework Version is not valid.")
        }
        guard let build = frameworkDict["build"] as? Int else {
            throw FileIOError.import("Pixels import: Framework Build is not valid.")
        }
        if build < signature.build {
            log(.warning, .pixels, "Pixels import: File is from an older version of Pixels v\(version) b\(build).")
        } else if build > signature.build {
            log(.warning, .pixels, "Pixels import: File is from a newer version of Pixels v\(version) b\(build).")
        }
        
        // MARK: Load Info
        guard let infoDict = jsonDict["info"] as? [String: Any] else {
            throw FileIOError.import("Pixels import: Info is not valid.")
        }
        guard let name = infoDict["name"] as? String else {
            throw FileIOError.import("Pixels import: Info Name Bits is not valid.")
        }
        guard let idStr = infoDict["id"] as? String else {
            throw FileIOError.import("Pixels import: Info ID Space is not valid.")
        }
        guard let id = UUID(uuidString: idStr) else {
            throw FileIOError.import("Pixels import: File ID is corrupt.")
        }
        let info = ProjectInfo(name: name, id: id)
        
        // MARK: Load Settings
        guard let settingsDict = jsonDict["settings"] as? [String: Any] else {
            throw FileIOError.import("Pixels import: Settings is not valid.")
        }
        guard let colorDict = settingsDict["color"] as? [String: Any] else {
            throw FileIOError.import("Pixels import: Settings Color is not valid.")
        }
        guard let bitsInt = colorDict["bits"] as? Int else {
            throw FileIOError.import("Pixels import: Settings Color Bits is not valid.")
        }
        guard let bits = PIX.Color.Bits(rawValue: bitsInt) else {
            throw FileIOError.import("Pixels import: Settings Color Bits is corrupt.")
        }
        guard let spaceStr = colorDict["space"] as? String else {
            throw FileIOError.import("Pixels import: Settings Color Space is not valid.")
        }
        guard let space = PIX.Color.Space(rawValue: spaceStr) else {
            throw FileIOError.import("Pixels import: Settings Color Space is corrupt.")
        }
        guard let generatorsGlobalResMultiplier = settingsDict["generatorsGlobalResMultiplier"] as? CGFloat else {
            throw FileIOError.import("Pixels import: Settings Generators Global Res Multiplier is not valid.")
        }
        
        // MARK: Load PIXs
        guard let pixPackDictList = jsonDict["pixs"] as? [[String: Any]] else {
            throw FileIOError.import("Pixels import: PIX list is corrupt.")
        }
        var pixImportPacks: [PIXImportPack] = []
        for pixPackDict in pixPackDictList {
            
            guard let idStr = pixPackDict["id"] as? String else {
                throw FileIOError.import("Pixels import: PIX ID is not valid.")
            }
            guard let id = UUID(uuidString: idStr) else {
                throw FileIOError.import("Pixels import: PIX ID is corrupt.")
            }
            let name = pixPackDict["name"] as? String
            
            guard let pixKindStr = pixPackDict["kind"] as? String else {
                throw FileIOError.import("Pixels import: PIX Kind is not valid.")
            }
            guard let pixType = PIX.Kind.init(rawValue: pixKindStr)?.type else {
                throw FileIOError.import("Pixels import: PIX Kind is corrupt.")
            }
            
            guard let pixSettings = pixPackDict["settings"] as? [String: Any] else {
                throw FileIOError.import("Pixels import: PIX Settings is not valid.")
            }
            guard let interpolateStr = pixSettings["interpolate"] as? String else {
                throw FileIOError.import("Pixels import: PIX Interpolate Setting is not valid.")
            }
            guard let interpolate = PIX.InterpolateMode(rawValue: interpolateStr) else {
                throw FileIOError.import("Pixels import: PIX Interpolate Setting is corrupt.")
            }
            guard let extendStr = pixSettings["extend"] as? String else {
                throw FileIOError.import("Pixels import: PIX Extend Setting is not valid.")
            }
            guard let extend = PIX.ExtendMode(rawValue: extendStr) else {
                throw FileIOError.import("Pixels import: PIX Extend Setting is corrupt.")
            }
            
            let pixGeneratorSettingsDict = pixSettings["generator"] as? [String: Any]
            var generatorSettings: PIXGeneratorSettings? = nil
            if let genDict = pixGeneratorSettingsDict {
                guard let resStr = genDict["res"] as? String else {
                    throw FileIOError.import("Pixels import: PIX Res Generator Setting is not valid.")
                }
                guard let premultiply = genDict["premultiply"] as? Bool else {
                    throw FileIOError.import("Pixels import: PIX Premultiply Generator Setting is not valid.")
                }
                generatorSettings = PIXGeneratorSettings(res: resStr, premultiply: premultiply)
            }
            
            let settings = PIXSettings(interpolate: interpolate, extend: extend, generator: generatorSettings)
            
            guard let pixDict = pixPackDict["pix"] as? [String: Any] else {
                throw FileIOError.import("Pixels import: \(pixType) dict is corrupt.")
            }
            let pixJsonData = try JSONSerialization.data(withJSONObject: pixDict, options: .prettyPrinted)
            
            let pix = try decoder.decode(pixType, from: pixJsonData)
            pix.id = id
            pix.name = name
            
            var inPixId: UUID? = nil
            var inPixAId: UUID? = nil
            var inPixBId: UUID? = nil
            var inPixsIds: [UUID]? = nil
            func getInPixId(_ key: String) throws -> UUID {
                guard let inPixIdStr = pixPackDict[key] as? String else {
                    throw FileIOError.import("Pixels import: PIX In ID not found.")
                }
                guard let inPixId = UUID(uuidString: inPixIdStr) else {
                    throw FileIOError.import("Pixels import: PIX In ID is corrupt.")
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
                        throw FileIOError.import("Pixels import: PIX Ins IDs not found.")
                    }
                    inPixsIds = []
                    for inPixIdStr in inPixsIdsStrArr {
                        guard let iInPixId = UUID(uuidString: inPixIdStr) else {
                            throw FileIOError.import("Pixels import: PIX In(s) is corrupt.")
                        }
                        inPixsIds?.append(iInPixId)
                    }
                }
            }
            
            let pixImportPack = PIXImportPack(pix: pix, settings: settings, inPixId: inPixId, inPixAId: inPixAId, inPixBId: inPixBId, inPixsIds: inPixsIds)
            pixImportPacks.append(pixImportPack)
        }
        
        let pixs = pixImportPacks.map { pixImportPack -> PIX in return pixImportPack.pix }
        
        // MARK: Setup Pixels
        
        colorBits = bits
        colorSpace = space
        PIXGenerator.globalResMultiplier = generatorsGlobalResMultiplier
        
        // MARK: Setup PIXs
        
        for pixImportPack in pixImportPacks {
            pixImportPack.pix.interpolate = pixImportPack.settings.interpolate
            pixImportPack.pix.extend = pixImportPack.settings.extend
            if let genPix = pixImportPack.pix as? PIXGenerator {
                guard let genSettings = pixImportPack.settings.generator else {
                    throw FileIOError.import("Pixels import: PIX Generator Settings are missing.")
                }
                let res: PIX.Res
                if genSettings.res == "fullScreen" {
                    res = .fullScreen
                } else {
                    let wh = genSettings.res.split(separator: "x")
                    guard wh.count == 2 else {
                        throw FileIOError.import("Pixels import: PIX Res Generator Setting is corrupt.")
                    }
                    guard let w = Int(wh.first!) else {
                        throw FileIOError.import("Pixels import: PIX Res Width Generator Setting is corrupt.")
                    }
                    guard let h = Int(wh.last!) else {
                        throw FileIOError.import("Pixels import: PIX Res Height Generator Setting is corrupt.")
                    }
                    res = PIX.Res(PIX.Res.Raw(w: w, h: h))
                }
                genPix.res = res
                genPix.premultiply = genSettings.premultiply
            }
        }
        
        // MARK: Connect PIXs
        
        func findPixOut(by id: UUID) throws -> PIX & PIXOut {
            for pix in pixs {
                if pix.id == id {
                    guard let pixOut = pix as? PIX & PIXOut else {
                        throw FileIOError.import("Pixels import: PIX In is not Out.")
                    }
                    return pixOut
                }
            }
            throw FileIOError.import("Pixels import: PIX In not found.")
        }
        
        for pixImportPack in pixImportPacks {
            if let pixIn = pixImportPack.pix as? PIX & PIXIn {
                if var pixInSingle = pixIn as? PIX & PIXInSingle {
                    if pixImportPack.inPixId != nil {
                        pixInSingle.inPix = try findPixOut(by: pixImportPack.inPixId!)
                    }
                } else if var pixInMerger = pixIn as? PIX & PIXInMerger {
                    if pixImportPack.inPixAId != nil {
                        pixInMerger.inPixA = try findPixOut(by: pixImportPack.inPixAId!)
                    }
                    if pixImportPack.inPixBId != nil {
                        pixInMerger.inPixB = try findPixOut(by: pixImportPack.inPixBId!)
                    }
                } else if var pixInMulti = pixIn as? PIX & PIXInMulti {
                    if pixImportPack.inPixsIds != nil {
                        for pixId in pixImportPack.inPixsIds! {
                            pixInMulti.inPixs.append(try findPixOut(by: pixId))
                        }
                    }
                }
            }
        }
        
        log(.info, .fileIO, "Import successful.")
        return Project(info: info, pixs: pixs)
    }
    
}
