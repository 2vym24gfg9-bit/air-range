import SwiftUI
import SceneKit
import CoreMotion
import UIKit

struct ContentView: View {
    @StateObject private var game = AimRangeModel()
    @State private var showSettings = false
    @State private var lastDragTranslation = CGSize.zero

    var body: some View {
        ZStack {
            RangeSceneView(scene: game.scene, onAim: { dx, dy in game.aim(dx: dx, dy: dy) })
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .gesture(DragGesture(minimumDistance: 2).onChanged { value in
                    let dx = value.translation.width - lastDragTranslation.width
                    let dy = value.translation.height - lastDragTranslation.height
                    game.aim(dx: dx, dy: dy)
                    lastDragTranslation = value.translation
                }.onEnded { _ in
                    lastDragTranslation = .zero
                })
                .simultaneousGesture(TapGesture().onEnded { game.fire() })

            VStack(spacing: 0) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("AIM RANGE").font(.system(size: 13, weight: .black, design: .rounded)).tracking(2).foregroundStyle(.cyan)
                        Text("FPS 训练场").font(.system(size: 22, weight: .bold, design: .rounded))
                    }
                    Spacer()
                    statPill("命中", "\(game.hits)")
                    statPill("射击", "\(game.shots)")
                    statPill("命中率", game.shots == 0 ? "—" : "\(Int(Double(game.hits) / Double(game.shots) * 100))%")
                    Button { showSettings = true } label: {
                        Image(systemName: "slider.horizontal.3").font(.system(size: 18, weight: .bold)).frame(width: 44, height: 44)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 13))
                    }.buttonStyle(.plain)
                }.padding(.horizontal, 18).padding(.top, 14)

                Spacer()
                ZStack {
                    Circle().stroke(.white.opacity(0.9), lineWidth: 1.5).frame(width: 28, height: 28)
                    Rectangle().fill(.white).frame(width: 2, height: 10)
                    Rectangle().fill(.white).frame(width: 10, height: 2)
                    Circle().fill(.cyan).frame(width: 3, height: 3)
                }.shadow(color: .black.opacity(0.7), radius: 3)
                Spacer()

                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(game.message).font(.system(size: 13, weight: .semibold)).foregroundStyle(.white.opacity(0.9))
                        HStack(spacing: 8) {
                            Image(systemName: "hand.draw").foregroundStyle(.cyan)
                            Text("拖动屏幕瞄准").font(.system(size: 12, weight: .medium))
                            Text("·").foregroundStyle(.white.opacity(0.5))
                            Image(systemName: "scope").foregroundStyle(.cyan)
                            Text("点击射击").font(.system(size: 12, weight: .medium))
                        }.foregroundStyle(.white.opacity(0.85))
                    }
                    Spacer()
                    Button { game.fire() } label: {
                        ZStack {
                            Circle().fill(.red.opacity(0.18)).frame(width: 82, height: 82)
                            Circle().stroke(.red.opacity(0.9), lineWidth: 2).frame(width: 68, height: 68)
                            Circle().fill(LinearGradient(colors: [.red, Color(red: 0.55, green: 0.02, blue: 0.05)], startPoint: .topLeading, endPoint: .bottomTrailing)).frame(width: 56, height: 56)
                            Image(systemName: "scope").font(.system(size: 25, weight: .black)).foregroundStyle(.white)
                        }
                    }.buttonStyle(.plain).accessibilityLabel("射击")
                }.padding(.horizontal, 22).padding(.bottom, 18)
            }
        }
        .sheet(isPresented: $showSettings) { SettingsView(game: game).presentationDetents([.medium, .large]) }
        .onAppear { game.start() }
        .onDisappear { game.stop() }
    }

    private func statPill(_ title: String, _ value: String) -> some View {
        VStack(spacing: 3) {
            Text(title).font(.system(size: 10, weight: .medium)).foregroundStyle(.white.opacity(0.65))
            Text(value).font(.system(size: 16, weight: .bold, design: .rounded)).monospacedDigit()
        }.frame(minWidth: 48).padding(.horizontal, 9).padding(.vertical, 8)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct SettingsView: View {
    @ObservedObject var game: AimRangeModel
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            Form {
                Section("瞄准设置") {
                    VStack(alignment: .leading) {
                        HStack { Text("触屏灵敏度"); Spacer(); Text(String(format: "%.1fx", game.touchSensitivity)).foregroundStyle(.secondary) }
                        Slider(value: $game.touchSensitivity, in: 0.4...2.5, step: 0.1)
                    }
                    Toggle("陀螺仪辅助瞄准", isOn: $game.gyroEnabled)
                    VStack(alignment: .leading) {
                        HStack { Text("陀螺仪灵敏度"); Spacer(); Text(String(format: "%.1fx", game.gyroSensitivity)).foregroundStyle(.secondary) }
                        Slider(value: $game.gyroSensitivity, in: 0.2...3.0, step: 0.1)
                    }
                    Picker("训练难度", selection: $game.difficulty) {
                        Text("轻松").tag(0); Text("标准").tag(1); Text("挑战").tag(2)
                    }.pickerStyle(.segmented)
                }
                Section("本局成绩") {
                    LabeledContent("命中", value: "\(game.hits)")
                    LabeledContent("射击", value: "\(game.shots)")
                    LabeledContent("命中率", value: game.shots == 0 ? "—" : "\(Int(Double(game.hits) / Double(game.shots) * 100))%")
                    Button("重置成绩") { game.resetScore() }.foregroundStyle(.red)
                }
                Section { Text("提示：陀螺仪仅在支持的设备上生效。首版为轻量 3D 靶场原型，尚未加入联网、账号或云端成绩。") .font(.footnote).foregroundStyle(.secondary) }
            }
            .navigationTitle("训练设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("完成") { dismiss() } } }
        }
    }
}

struct RangeSceneView: UIViewRepresentable {
    let scene: SCNScene
    var onAim: (CGFloat, CGFloat) -> Void
    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.scene = scene
        view.backgroundColor = UIColor(red: 0.035, green: 0.07, blue: 0.11, alpha: 1)
        view.isPlaying = true
        view.antialiasingMode = .multisampling4X
        view.rendersContinuously = true
        view.pointOfView = scene.rootNode.childNode(withName: "camera", recursively: true)
        view.allowsCameraControl = false
        return view
    }
    func updateUIView(_ uiView: SCNView, context: Context) { uiView.scene = scene }
}

final class AimRangeModel: ObservableObject {
    let scene = SCNScene()
    @Published var hits = 0
    @Published var shots = 0
    @Published var message = "准备就绪 · 点击红色靶心开始训练"
    @Published var touchSensitivity = 1.0
    @Published var gyroSensitivity = 1.0
    @Published var gyroEnabled = false { didSet { gyroEnabled ? startMotion() : stopMotion() } }
    @Published var difficulty = 1 { didSet { configureTargetMotion() } }
    private let motion = CMMotionManager()
    private var camera: SCNNode!
    private var targets: [SCNNode] = []
    private var lastAimX: Float = 0
    private var lastAimY: Float = 0
    private var lastGyroX: Double = 0
    private var lastGyroY: Double = 0
    private var motionStarted = false

    func start() {
        if scene.rootNode.childNode(withName: "camera", recursively: true) != nil { return }
        scene.background.contents = UIColor(red: 0.035, green: 0.07, blue: 0.11, alpha: 1)
        let cameraNode = SCNNode(); cameraNode.name = "camera"; cameraNode.camera = SCNCamera(); cameraNode.camera?.fieldOfView = 68
        cameraNode.position = SCNVector3(0, 1.6, 7.5); cameraNode.eulerAngles = SCNVector3Zero
        scene.rootNode.addChildNode(cameraNode); camera = cameraNode
        buildArena(); spawnTargets()
        if gyroEnabled { startMotion() }
    }

    private func buildArena() {
        let floor = SCNFloor(); floor.reflectivity = 0
        let floorNode = SCNNode(geometry: floor); floorNode.geometry?.firstMaterial?.diffuse.contents = UIColor(red: 0.08, green: 0.13, blue: 0.17, alpha: 1); floorNode.position = SCNVector3(0, 0, 0); scene.rootNode.addChildNode(floorNode)
        let back = SCNBox(width: 24, height: 12, length: 0.25, chamferRadius: 0)
        back.firstMaterial?.diffuse.contents = UIColor(red: 0.07, green: 0.14, blue: 0.19, alpha: 1)
        let wall = SCNNode(geometry: back); wall.position = SCNVector3(0, 5, -15); scene.rootNode.addChildNode(wall)
        for x in -10...10 {
            let line = SCNBox(width: 0.025, height: 0.01, length: 25, chamferRadius: 0)
            line.firstMaterial?.diffuse.contents = UIColor.cyan.withAlphaComponent(0.12)
            let node = SCNNode(geometry: line); node.position = SCNVector3(Float(x), 0.012, -5); scene.rootNode.addChildNode(node)
        }
        let ambient = SCNNode(); ambient.light = SCNLight(); ambient.light?.type = .ambient; ambient.light?.intensity = 650; scene.rootNode.addChildNode(ambient)
        let omni = SCNNode(); omni.light = SCNLight(); omni.light?.type = .omni; omni.light?.intensity = 850; omni.position = SCNVector3(0, 8, 4); scene.rootNode.addChildNode(omni)
    }

    private func spawnTargets() {
        for i in 0..<7 {
            let outer = SCNCylinder(radius: 0.56, height: 0.12); outer.firstMaterial?.diffuse.contents = UIColor(red: 0.9, green: 0.12, blue: 0.16, alpha: 1)
            let node = SCNNode(geometry: outer); node.name = "target_\(i)"
            let inner = SCNCylinder(radius: 0.29, height: 0.135); inner.firstMaterial?.diffuse.contents = UIColor(red: 1, green: 0.72, blue: 0.2, alpha: 1)
            let innerNode = SCNNode(geometry: inner); innerNode.position = SCNVector3(0, 0, 0.01); node.addChildNode(innerNode)
            let bull = SCNCylinder(radius: 0.11, height: 0.15); bull.firstMaterial?.diffuse.contents = UIColor.white
            let bullNode = SCNNode(geometry: bull); bullNode.position = SCNVector3(0, 0, 0.02); node.addChildNode(bullNode)
            let x = Float(i - 3) * 2.1
            node.position = SCNVector3(x, Float(2.1 + (i % 3) * 0.8), -8 - Float(i % 2) * 2)
            scene.rootNode.addChildNode(node); targets.append(node)
        }
        configureTargetMotion()
    }

    func configureTargetMotion() {
        for (i, node) in targets.enumerated() {
            node.removeAction(forKey: "move")
            guard difficulty > 0 else { continue }
            let range = difficulty == 1 ? 0.65 : 1.35
            let duration = difficulty == 1 ? 1.6 : 0.85
            let left = SCNAction.moveBy(x: CGFloat(-range), y: CGFloat((i % 2 == 0 ? 0.35 : -0.3)), z: 0, duration: duration)
            let right = SCNAction.moveBy(x: CGFloat(range * 2), y: CGFloat((i % 2 == 0 ? -0.35 : 0.3)), z: 0, duration: duration * 2)
            let back = SCNAction.moveBy(x: CGFloat(-range), y: CGFloat((i % 2 == 0 ? 0.35 : -0.3)), z: 0, duration: duration)
            node.runAction(.repeatForever(.sequence([left, right, back])), forKey: "move")
        }
    }

    func aim(dx: CGFloat, dy: CGFloat) {
        guard camera != nil else { return }
        let yaw = Float(dx) * 0.0035 * Float(touchSensitivity)
        let pitch = Float(dy) * 0.0035 * Float(touchSensitivity)
        camera.eulerAngles.y -= yaw
        camera.eulerAngles.x = max(-0.8, min(0.8, camera.eulerAngles.x - pitch))
        lastAimX = camera.eulerAngles.y; lastAimY = camera.eulerAngles.x
    }

    func fire() {
        guard camera != nil else { return }
        shots += 1
        let origin = camera.presentation.worldPosition
        let forward = camera.presentation.convertVector(SCNVector3(0, 0, -1), to: nil)
        let end = SCNVector3(origin.x + forward.x * 100, origin.y + forward.y * 100, origin.z + forward.z * 100)
        let hitsResult = scene.rootNode.hitTestWithSegment(from: origin, to: end, options: [.searchMode: SCNHitTestSearchMode.all.rawValue])
        if let hit = hitsResult.first(where: { result in
            var n: SCNNode? = result.node
            while let current = n { if current.name?.hasPrefix("target_") == true { return true }; n = current.parent }
            return false
        }) {
            var target: SCNNode? = hit.node
            while let current = target, current.name?.hasPrefix("target_") != true { target = current.parent }
            if let target {
                hits += 1; message = "命中！继续保持准度。"
                let old = target.opacity
                target.runAction(.sequence([.fadeOpacity(to: 0.25, duration: 0.06), .fadeOpacity(to: old, duration: 0.12)]))
                let x = Float.random(in: -6.5...6.5); let y = Float.random(in: 1.6...4.4)
                target.runAction(.move(to: SCNVector3(x, y, target.position.z), duration: 0.16))
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                return
            }
        }
        message = "未命中 · 调整准星后再试"
    }

    func resetScore() { hits = 0; shots = 0; message = "成绩已重置，开始新一轮训练。" }
    private func startMotion() {
        guard motion.isDeviceMotionAvailable, !motionStarted else { return }
        motion.deviceMotionUpdateInterval = 1.0 / 60.0
        motion.startDeviceMotionUpdates(to: .main) { [weak self] data, _ in
            guard let self, let data, let camera = self.camera else { return }
            let rx = data.rotationRate
            let dt = self.motion.deviceMotionUpdateInterval
            camera.eulerAngles.y -= Float(rx.y * dt * self.gyroSensitivity * 0.7)
            camera.eulerAngles.x = max(-0.8, min(0.8, camera.eulerAngles.x + Float(rx.x * dt * self.gyroSensitivity * 0.7)))
        }
        motionStarted = true
    }
    func stop() { stopMotion() }
    private func stopMotion() { if motion.isDeviceMotionActive { motion.stopDeviceMotionUpdates() }; motionStarted = false }
}
