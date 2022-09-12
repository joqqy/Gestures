//
//  Simultaneous.swift
//  Gestures
//
//  Created by SchwiftyUI on 12/4/19.
//  Copyright © 2019 SchwiftyUI. All rights reserved.
//

import SwiftUI

struct Simultaneous: View {
    enum SimultaneousState {
        
        case inactive
        case rotating(angle: Angle)
        case zooming(scale: CGFloat)
        case both(angle: Angle, scale: CGFloat)
        
        var rotationAngle: Angle {
            switch self {
            case .rotating(let angle), .both(let angle, _):
                return angle
            default:
                return Angle.zero
            }
        }
        
        var scale: CGFloat {
            switch self {
            case .zooming(let scale), .both(_, let scale):
                return scale
            default:
                return CGFloat(1.0)
            }
        }
        
        case dragging(translation: CGSize)
        
        var translation: CGSize {
            switch self {
            case .dragging(let translation):
                return translation
            default:
                return CGSize.zero
            }
        }
    }
    
    @GestureState var simultaneousState = SimultaneousState.inactive
    @State var viewRotationState = Angle.zero
    @State var viewMagnificationState = CGFloat(1.0)

    @State var viewDragState = CGSize.zero
    
    var magnificationScale: CGFloat {
        return viewMagnificationState * simultaneousState.scale
    }
    
    var rotationAngle: Angle {
        return viewRotationState + simultaneousState.rotationAngle
    }
    
    var translationOffset: CGSize {
        return CGSize(width: viewDragState.width + simultaneousState.translation.width, height: viewDragState.height + simultaneousState.translation.height)
    }
    
    var body: some View {
        
        let rotationGesture = RotationGesture(minimumAngleDelta: Angle(degrees: 5))
//            .updating($rotationState) { value, state, transation in
//                state = .rotating(angle: value)
//            }.onEnded { value in
//                self.viewRotationState += value
//            }
        
        let magnificationGesture = MagnificationGesture()
//            .updating($magnificationState) { value, state, transaction in
//                state = .zooming(scale: value)
//            }.onEnded { value in
//                self.viewMagnificationState *= value
//            }
        
        let simultaneous = SimultaneousGesture(rotationGesture, magnificationGesture)
            .updating($simultaneousState) { value, state, transation in
                
                if value.first != nil && value.second != nil {
                    state = .both(angle: value.first!, scale: value.second!)
                } else if value.first != nil {
                    state = .rotating(angle: value.first!)
                } else if value.second != nil {
                    state = .zooming(scale: value.second!)
                } else {
                    state = .inactive
                }
                
            }.onEnded { value in
                self.viewRotationState += value.first ?? Angle.zero
                self.viewMagnificationState *= value.second ?? 1
            }
        
        let dragGesture = DragGesture(minimumDistance: 10)
            .updating($simultaneousState) { value, state, transaction in
                state = .dragging(translation: value.translation)
        }.onEnded { value in
            self.viewDragState.height += value.translation.height
            self.viewDragState.width += value.translation.width
        }
        
        return LogoDrawing()
            .frame(width: 350, height: 650)
            .scaleEffect(magnificationScale)
            .rotationEffect(rotationAngle)
            .offset(translationOffset)
            .gesture(simultaneous)
            .simultaneousGesture(dragGesture)
    }
}

struct Simultaneous_Previews: PreviewProvider {
    static var previews: some View {
        Simultaneous()
    }
}
