//
//  SwipePanel.swift
//  Explorer
//
//  Created by Kavindu Dilshan on 2025-04-15.
//
import SwiftUI

enum PanelPosition: CGFloat, CaseIterable {
    case top = 0.1
    case middle = 0.5
    case bottom = 0.85
}

struct SwipePanel<Content: View>: View {
    @Binding var position: PanelPosition
    let content: () -> Content
    @GestureState private var dragoffset = CGFloat.zero

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 0) {
                    Capsule()
                        .fill(Color.gray)
                        .frame(width: 40, height: 6)
                        .padding(.top, 8)

                    content()
                }
                .frame(width: geo.size.width, height: geo.size.height * (1 - position.rawValue))
                .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemBackground)))
                .offset(y: dragoffset)
                .animation(.interactiveSpring(), value: position)
                .gesture(
                    DragGesture()
                        .updating($dragoffset) { value, state, _ in
                            state = value.translation.height
                        }
                        .onEnded { value in
                            let height = geo.size.height
                            let relative = (value.translation.height / height) + position.rawValue
                            let closest = PanelPosition.allCases.min(by: {
                                abs($0.rawValue - relative) < abs($1.rawValue - relative)
                            }) ?? .middle
                            position = closest
                        }
                )
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}
