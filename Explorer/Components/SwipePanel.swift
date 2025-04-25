import SwiftUI

enum PanelPosition: CGFloat, CaseIterable {
    case top = 0.1
    case middle = 0.5
    case bottom = 0.85
}

struct SwipePanel<Content: View>: View {
    @Binding var position: PanelPosition
    let isKeyboardActive: Bool
    let content: Content
    @GestureState private var dragOffset: CGFloat = 0
    @State private var keyboardHeight: CGFloat = 0
    @State private var keyboardObservers: [NSObjectProtocol] = []

    init(position: Binding<PanelPosition>, isKeyboardActive: Bool = false, @ViewBuilder content: () -> Content) {
        self._position = position
        self.isKeyboardActive = isKeyboardActive
        self.content = content()
    }

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                // Handle
                Capsule()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 40, height: 6)
                    .padding(.top, 8)
                    .gesture(
                        TapGesture()
                            .onEnded {
                                withAnimation(.interactiveSpring()) {
                                    position = position == .top ? .middle : .top
                                }
                            }
                    )

                // Panel content
                content
                    .padding(.bottom, keyboardHeight > 0 ? keyboardHeight - geo.safeAreaInsets.bottom : 0)
            }
            .frame(width: geo.size.width)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(radius: 5)
            )
            .offset(y: currentOffset(for: geo.size.height))
            .animation(.interactiveSpring(), value: position)
            .offset(y: dragOffset)
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        if !isKeyboardActive {
                            state = value.translation.height
                        }
                    }
                    .onEnded { value in
                        guard !isKeyboardActive else { return }

                        let height = geo.size.height
                        let dragFraction = value.translation.height / height
                        let predictedFraction = value.predictedEndTranslation.height / height
                        let totalFraction = dragFraction + predictedFraction

                        let newRawValue = (position.rawValue + totalFraction).clamped(to: 0...1)
                        let closest = PanelPosition.allCases.min(by: {
                            abs($0.rawValue - newRawValue) < abs($1.rawValue - newRawValue)
                        }) ?? .middle

                        withAnimation(.interactiveSpring()) {
                            position = closest
                        }
                    }
            )
        }
        .onAppear(perform: setupKeyboardObservers)
        .onDisappear(perform: removeKeyboardObservers)
    }

    private func currentOffset(for height: CGFloat) -> CGFloat {
        height * (1 - position.rawValue)
    }

    private func setupKeyboardObservers() {
        let showObserver = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                keyboardHeight = keyboardFrame.height
            }
        }

        let hideObserver = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { _ in
            keyboardHeight = 0
        }

        keyboardObservers = [showObserver, hideObserver]
    }

    private func removeKeyboardObservers() {
        keyboardObservers.forEach { NotificationCenter.default.removeObserver($0) }
    }
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
