import QtQuick 2.0

GameEntity {
    id: root
    property var currentLevel
    property var currentPlayer
    property CircleComponent circle: circleComp
    property MovingComponent moving: movingComp
    property ThrustingComponent thrust: thrustComp
    property alias childrenContainer: circles // used to create children procedural (first arg of createObject does not recognize default-property for children)
    default property alias containedChildren: circles.children
    property bool isBig: false
    width: moving.radius*2
    height: width
    CircleComponent {
        id: circleComp
        color: root.isControlled?"green":"black"

    }
    MovingComponent {
        id: movingComp
        friction: 0.99
        inertia: 0.995
    }
    ThrustingComponent {
        id: thrustComp
    }

    function childAdded(c) { circles.childAdded(c); }
    Item {
        anchors.fill: parent
        id: circles
        property var connections: []

        function childAdded(c) {
            for( var ci in circles.children) {
                connections.push([c, circles.children[ci]]);
            }
        }
        onChildrenChanged: {
            if(children.length === 0) {
                becameEmpty();
            }
        }
        signal becameEmpty()
    }

    property bool isControlled: false
    Timer {
        property bool waiting: false
        id: childrenTimer
        interval: 20
        repeat: true
        running: game.running && !waiting && circles.children.length !== 0
        onTriggered: {
            var playersize = currentPlayer.moving.mass;
            var maxEnemySize = 0;
            for( var c in circles.children) {
                var ch = circles.children[c].moving;
                if(!ch) continue;
                ch.step(1000.0/16.0);
                maxEnemySize = Math.max(maxEnemySize, ch.mass);
            }
            if( playersize === maxEnemySize) {
                game.win = true;
                isBig = true;
                //console.log("won!");
                //TODO: isBig in this level, is immune to this level as enemy.
                //root.currentPlayer.parent = game.appendParentLevel();
            }

            if( circles.connections.length === 0) return;
            for(var c2=circles.connections.length-1; 0 <= c2 ; --c2) {
                var e = circles.connections[c2];
                if( e === undefined) {
                    circles.connections.splice(c2, 1);
                    continue;
                }
                var i1 = e[0];
                var i2 = e[1];
                if( i1 === undefined || i2 === undefined) {
                    circles.connections.splice(c2, 1);
                    continue;
                }

                var distance = overlap(i1, i2);
                if( distance < 0.0 ) {
                    if(i1.moving.radius===i2.moving.radius) continue;
                    var bigger;
                    var smaller;
                    if(i1.moving.radius>i2.moving.radius) {
                        bigger = i1;
                        smaller = i2;
                    } else {
                        bigger = i2;
                        smaller = i1;
                    }
                    var desiredRad = Math.max(0.0,smaller.moving.radius+distance);
                    var desiredMass = desiredRad*desiredRad;
                    var exchangedMass = smaller.moving.mass-desiredMass;
                    var exchangedVelX = -(smaller.moving.velocityX-bigger.moving.velocityX)*exchangedMass/bigger.moving.mass;
                    var exchangedVelY = -(smaller.moving.velocityY-bigger.moving.velocityY)*exchangedMass/bigger.moving.mass;
                    //var exchangedMass = Math.min(smaller.moving.mass, Math.min(1.0,-distance)*(1000.0/16.0)*0.1);
                    bigger.moving.addMass(exchangedMass);
                    smaller.moving.addMass(-exchangedMass);
                    bigger.moving.accelVar(exchangedVelX, exchangedVelY);
                    if(smaller.moving.mass <= 0.0) {
                        //circles.connections.splice(c2, 1);
                        for(var des=circles.connections.length-1; 0<= des ; --des) {
                            var e2 = circles.connections[des];
                            if( e2[0] === smaller || e2[1] === smaller) {
                                circles.connections.splice(des, 1);
                            }
                        }
                        if(typeof circles.children.indexOf === "function") {
                            circles.children.splice(circles.children.indexOf(smaller), 1);
                        }
                        if(!smaller.isControlled) {
                            smaller.destroy();
                        } else {
                            game.gameover = true;
                        }
                    }
                }
            }
        }
        function overlap(a, b) {
            var xd = a.centerX-b.centerX;
            var yd = a.centerY-b.centerY;
            var max = a.moving.radius+b.moving.radius;
            if(xd < max && yd < max) {
                return Math.sqrt(xd*xd + yd*yd) - max;
            } else {
                return max;
            }
        }
    }
    Component {
        id: foodComponent
        Food {}
    }
    function clearChildren(callback) {
        childrenTimer.waiting = true;
        circles.connections = []
        var fn = function(){
            circles.becameEmpty.disconnect( fn );
            callback();
            childrenTimer.waiting = false;
        }
        circles.becameEmpty.connect( fn );
        for(var i = circles.children.length; i > 0 ; i--) {
            circles.children[i-1].destroy()
        }
    }
    function initChildren() {
        if(root.isControlled) return;
        circles.childAdded( currentPlayer );
        for(var i=0 ; i<150 ; ++i) {
            var foodMass = 4000;
            var foodRad = Math.sqrt(foodMass);
            var ang = Math.random()*Math.PI*2.0;
            var l1 = 1.0-Math.random();
            l1 = 1.0-(l1*l1*l1);
            var len = l1*root.width*0.5-foodRad;
            len = Math.max(len, currentPlayer.width*1.6 + foodRad*2.0);
            if (foodComponent.status === Component.Ready) {
                var food = foodComponent.createObject(childrenContainer);
                if (food === null) {
                    // Error Handling
                    console.log("Error creating object");
                }
                var massFac = Math.random();
                massFac = massFac*massFac*massFac*massFac;
                var finalMass = Math.max(currentPlayer.moving.mass*0.5, massFac*foodMass);

                food.moving.addMass( finalMass );
                food.x = Math.cos(ang)*len;
                food.y = Math.sin(ang)*len;
                food.currentLevel = root;
                food.moving.velocityX = (Math.random()-0.5)*0.2;
                food.moving.velocityY = (Math.random()-0.5)*0.2;
                circles.childAdded( food );
            } else if (foodComponent.status === Component.Error) {
                // Error Handling
                console.log("Error loading component:", foodComponent.errorString());
            }
        }
    }
}

