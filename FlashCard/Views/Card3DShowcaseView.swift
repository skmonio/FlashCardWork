import SwiftUI
import SceneKit
import RealityKit

struct Card3DShowcaseView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 40) {
                    // SwiftUI Fake 3D Card
                    VStack(spacing: 16) {
                        Text("SwiftUI Fake 3D Card")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Fake3DCardView()
                            .frame(height: 180)
                        
                        Text("Uses rotation, shadows, and gradients to simulate 3D")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // SceneKit 3D Card
                    VStack(spacing: 16) {
                        Text("SceneKit 3D Card")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        SceneKitCardView()
                            .frame(height: 200)
                        
                        Text("Real 3D geometry with SceneKit")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // RealityKit 3D Card
                    VStack(spacing: 16) {
                        Text("RealityKit 3D Card")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Group {
                            #if targetEnvironment(simulator)
                            // Use fallback on simulator
                            FallbackRealityKitCardView()
                            #else
                            // Try RealityKit on device
                            RealityKitCardView()
                            #endif
                        }
                        .frame(height: 200)
                        
                        Text("Modern 3D rendering with RealityKit")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Interactive Demo
                    VStack(spacing: 16) {
                        Text("Interactive 3D Card Demo")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Interactive3DCardView()
                            .frame(height: 250)
                        
                        Text("Tap and drag to interact with the 3D card")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("3D Card Experiments")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - SwiftUI Fake 3D Card
struct Fake3DCardView: View {
    @State private var angle: Double = 0
    @State private var isFlipped = false
    
    var body: some View {
        VStack {
            ZStack {
                // Front of card
                VStack(spacing: 12) {
                    Text("Hallo")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Hello")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Tap to flip")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .padding()
                .frame(width: 200, height: 120)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.white, .blue.opacity(0.1)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.3), radius: 10, x: 10, y: 10)
                .rotation3DEffect(
                    .degrees(isFlipped ? 180 : 0),
                    axis: (x: 0, y: 1, z: 0)
                )
                .opacity(isFlipped ? 0 : 1)
                
                // Back of card
                VStack(spacing: 12) {
                    Text("Definition")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("A greeting in Dutch")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Text("Tap to flip back")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .padding()
                .frame(width: 200, height: 120)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.white, .green.opacity(0.1)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.3), radius: 10, x: 10, y: 10)
                .rotation3DEffect(
                    .degrees(isFlipped ? 0 : -180),
                    axis: (x: 0, y: 1, z: 0)
                )
                .opacity(isFlipped ? 1 : 0)
            }
            .onTapGesture {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    isFlipped.toggle()
                }
            }
        }
    }
}

// MARK: - SceneKit 3D Card
struct SceneKitCardView: UIViewRepresentable {
    func makeUIView(context: Context) -> SCNView {
        let scene = SCNScene()
        
        // Create card geometry
        let card = SCNBox(width: 2, height: 3, length: 0.1, chamferRadius: 0.1)
        
        // Create material with gradient-like appearance
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.systemBlue
        material.specular.contents = UIColor.white
        material.shininess = 0.8
        material.lightingModel = .physicallyBased
        
        card.materials = [material]
        
        let cardNode = SCNNode(geometry: card)
        cardNode.position = SCNVector3(0, 0, 0)
        cardNode.eulerAngles = SCNVector3(-0.3, 0.3, 0)
        
        // Add text to the card
        let textGeometry = SCNText(string: "Hallo", extrusionDepth: 0.05)
        textGeometry.font = UIFont.systemFont(ofSize: 0.3, weight: .bold)
        let textMaterial = SCNMaterial()
        textMaterial.diffuse.contents = UIColor.white
        textGeometry.materials = [textMaterial]
        
        let textNode = SCNNode(geometry: textGeometry)
        textNode.position = SCNVector3(-0.5, 0.5, 0.06)
        cardNode.addChildNode(textNode)
        
        scene.rootNode.addChildNode(cardNode)
        
        // Add lighting
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.position = SCNVector3(0, 10, 10)
        scene.rootNode.addChildNode(lightNode)
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        // Setup camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 0, 5)
        scene.rootNode.addChildNode(cameraNode)
        
        let scnView = SCNView()
        scnView.scene = scene
        scnView.allowsCameraControl = true
        scnView.backgroundColor = UIColor.clear
        scnView.autoenablesDefaultLighting = true
        
        return scnView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {}
}

// MARK: - RealityKit 3D Card
struct RealityKitCardView: UIViewRepresentable {
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // Create a simple card mesh
        let mesh = MeshResource.generateBox(size: [0.2, 0.3, 0.02], cornerRadius: 0.02)
        
        // Create a simple material without complex properties
        let material = SimpleMaterial(color: .systemPurple, isMetallic: false)
        
        // Create entity
        let entity = ModelEntity(mesh: mesh, materials: [material])
        entity.transform.translation = [0, 0, -0.5]
        entity.transform.rotation = simd_quatf(angle: 0.3, axis: [1, 0, 0])
        
        // Create anchor and add to scene
        let anchor = AnchorEntity(world: .zero)
        anchor.addChild(entity)
        arView.scene.addAnchor(anchor)
        
        // Setup camera for non-AR mode
        arView.cameraMode = .nonAR
        
        // Disable video processing to avoid warnings
        arView.renderOptions = [.disablePersonOcclusion, .disableDepthOfField, .disableMotionBlur]
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
}

// MARK: - Fallback RealityKit Card (if main one fails)
struct FallbackRealityKitCardView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("RealityKit Card")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Simplified 3D rendering")
                .font(.caption)
                .foregroundColor(.secondary)
            
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [.purple, .purple.opacity(0.7)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 200, height: 120)
                .shadow(color: .black.opacity(0.3), radius: 8, x: 4, y: 4)
                .rotation3DEffect(.degrees(15), axis: (x: 1, y: 0, z: 0))
                .rotation3DEffect(.degrees(10), axis: (x: 0, y: 1, z: 0))
        }
    }
}

// MARK: - Interactive 3D Card Demo
struct Interactive3DCardView: UIViewRepresentable {
    func makeUIView(context: Context) -> SCNView {
        let scene = SCNScene()
        
        // Create card geometry
        let card = SCNBox(width: 2, height: 3, length: 0.1, chamferRadius: 0.1)
        
        // Create material with realistic appearance
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.systemTeal
        material.specular.contents = UIColor.white
        material.shininess = 0.9
        material.lightingModel = .physicallyBased
        
        card.materials = [material]
        
        let cardNode = SCNNode(geometry: card)
        cardNode.position = SCNVector3(0, 0, 0)
        
        // Add text to the card
        let textGeometry = SCNText(string: "Interactive", extrusionDepth: 0.05)
        textGeometry.font = UIFont.systemFont(ofSize: 0.2, weight: .bold)
        let textMaterial = SCNMaterial()
        textMaterial.diffuse.contents = UIColor.white
        textGeometry.materials = [textMaterial]
        
        let textNode = SCNNode(geometry: textGeometry)
        textNode.position = SCNVector3(-0.6, 0.5, 0.06)
        cardNode.addChildNode(textNode)
        
        // Add subtitle
        let subtitleGeometry = SCNText(string: "Drag to rotate", extrusionDepth: 0.02)
        subtitleGeometry.font = UIFont.systemFont(ofSize: 0.1)
        let subtitleMaterial = SCNMaterial()
        subtitleMaterial.diffuse.contents = UIColor.lightGray
        subtitleGeometry.materials = [subtitleMaterial]
        
        let subtitleNode = SCNNode(geometry: subtitleGeometry)
        subtitleNode.position = SCNVector3(-0.4, 0.2, 0.06)
        cardNode.addChildNode(subtitleNode)
        
        scene.rootNode.addChildNode(cardNode)
        
        // Add lighting
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.position = SCNVector3(5, 5, 5)
        scene.rootNode.addChildNode(lightNode)
        
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        // Setup camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 0, 4)
        scene.rootNode.addChildNode(cameraNode)
        
        let scnView = SCNView()
        scnView.scene = scene
        scnView.allowsCameraControl = true
        scnView.backgroundColor = UIColor.clear
        scnView.autoenablesDefaultLighting = true
        
        // Add gesture recognizer for custom interactions
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
        scnView.addGestureRecognizer(panGesture)
        
        context.coordinator.cardNode = cardNode
        
        return scnView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject {
        var cardNode: SCNNode?
        var lastPanLocation: CGPoint?
        
        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard let cardNode = cardNode else { return }
            
            let location = gesture.location(in: gesture.view)
            
            switch gesture.state {
            case .began:
                lastPanLocation = location
            case .changed:
                guard let lastLocation = lastPanLocation else { return }
                
                let deltaX = Float(location.x - lastLocation.x) * 0.01
                let deltaY = Float(location.y - lastLocation.y) * 0.01
                
                cardNode.eulerAngles.y += deltaX
                cardNode.eulerAngles.x += deltaY
                
                lastPanLocation = location
            default:
                break
            }
        }
    }
}

// MARK: - Preview
struct Card3DShowcaseView_Previews: PreviewProvider {
    static var previews: some View {
        Card3DShowcaseView()
    }
} 