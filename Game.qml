import QtQuick 2.0
import QtQuick.Controls 1.3
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.1

Item {
    id: game
    property LevelPlayer currentLevel: startLevel
    property LevelPlayer currentPlayer
    property bool gameover
    property bool win
    property bool running: true
    MouseArea {
        property real zoomLevel: 1.0;
        anchors.fill: parent
        onClicked: {
            var coord = mapToItem(currentPlayer, mouse.x, mouse.y);
            //player.thrust.puff( coord.x-currentPlayer.width*0.5, coord.y-currentPlayer.height*0.5 );
            currentPlayer.thrust.puff( coord.x, coord.y );
        }
        onWheel: {
            zoomLevel += wheel.angleDelta.y*0.001;
            zoomLevel = Math.max(0.01, zoomLevel);
            zoomLevel = Math.min(10.0, zoomLevel);
            camera.scale = zoomLevel;
        }
    }
    RowLayout {
        z: 100
        anchors.top: parent.top
        anchors.right: parent.right
        Button {
            text: "restart"
            onClicked: reset()
        }
        CheckBox {
            checked: game.running
            onCheckedChanged: {
                game.running = checked
            }
        }
    }
    Rectangle {
        anchors.fill: parent
        z: 99
        color: "black"
        opacity: (game.gameover||game.win)*0.5
        Behavior on opacity {
            NumberAnimation {
                duration: 1000
            }
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            text: game.gameover?"You've been (b)eaten!":game.win?"Congratulations!":""
            font.pixelSize: Math.min(parent.width, parent.height)*0.1;
            color: "white"
        }
    }

    function reset() {
        game.gameover = false;
        game.win = false;
        currentLevel.clearChildren( function() {
            currentLevel.init();
        });
    }
    Component {
        id: playerComponent
        LevelPlayer {
            Component.onCompleted: moving.setMass( 100 )
            x: 0
            y: 0
            isControlled: true
        }
    }

    Item {
        width: game.width
        height: game.height
        id: camera
        property point center: mapFromItem(currentLevel, currentPlayer.centerX, currentPlayer.centerY)
        x: currentPlayer==null?0:-(center.x-camera.width*0.5)*camera.scale;
        y: currentPlayer==null?0:-(center.y-camera.height*0.5)*camera.scale;
        LevelPlayer {
            id: startLevel
            currentLevel: startLevel
            function init() {
                if (playerComponent.status === Component.Ready) {
                    var player = playerComponent.createObject(startLevel.childrenContainer);
                    if (player === null) console.log("Error creating object");
                    player.currentLevel = startLevel;
                    player.currentPlayer = player;
                    startLevel.currentPlayer = player
                    game.currentPlayer = player
                } else if (playerComponent.status === Component.Error) {
                    // Error Handling
                    console.log("Error loading component:", playerComponent.errorString());
                }
                moving.setMass( 1000000 );
                initChildren();
            }

            Component.onCompleted: init()
            x: 0
            y: 0
        }
    }
}

