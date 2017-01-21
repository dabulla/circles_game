import QtQuick 2.0
import QtGraphicalEffects 1.0

GameEntity {
    id: root
    width: moving.radius*2
    height: width
    property var currentLevel
    property CircleComponent circle: circleComp
    property MovingComponent moving: movingComp
    //property alias mass: movingComp.mass
    CircleComponent {
        id: circleComp
        color: col
//        RadialGradient {
//            cached: true
//            source: circleComp
//            anchors.fill: parent
//            gradient: Gradient {
//                id: grad
                property real rRand
                property real gRand
                property real bRand
                Component.onCompleted: {
                    rRand = Math.random()*0.9;
                    gRand = Math.random()*0.9;
                    bRand = Math.random()*0.9;
                }
                property color col: Qt.rgba(Math.min(0.4,1.0*root.width/500.0)+rRand,Math.min(0.4,1.0*root.width/700.0)+gRand,Math.min(0.4,1.0*root.width/800.0)+bRand,1.0 )
//                property real outerPos: 1.0 - (Math.max(1.0, Math.min(5.0, Math.abs( ((root.currentLevel?root.currentLevel.currentPlayer.moving.mass:0.0) - root.moving.mass) * 0.01 ))))*0.1
//                GradientStop {
//                    position: 0.0
//                    color:  Qt.darker( grad.col )
//                }
//                GradientStop {
//                    position: grad.outerPos*0.8
//                    color:  grad.col
//                }
//                GradientStop {
//                    position: 0.9
//                    color:  root.currentLevel?root.currentLevel.currentPlayer.moving.mass > moving.mass ? "green" : "red":"black"
//                }
//            }
//        }
    }
    MovingComponent {
        id: movingComp
        friction: 0.99
        inertia: 1.0
    }
}

