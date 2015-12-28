import QtQuick 2.0

Item {
    id: root
    Component {
        id: thrustOutComponent
        Food {}
    }
    function puff(x, y) {
        if(!game.running) return;
        if(root.parent.moving.mass < 10) return;
        var len = Math.sqrt(x*x + y*y);
        x /= len;
        y /= len;
        var circles = root.parent.currentLevel.circleChildren;
        if (thrustOutComponent.status !== Component.Ready) {
            if (foodComponent.status === Component.Error) {
                // Error Handling
                console.log("Error loading component:", foodComponent.errorString());
            }
            return;
        }
        var food = thrustOutComponent.createObject(root.parent.currentLevel.childrenContainer);
        if (food === null) {
            // Error Handling
            console.log("Error creating object");
        }
        var usedMass = Math.max( 10, root.parent.moving.mass * 0.03);
        food.moving.addMass( usedMass );
        root.parent.moving.addMass( -usedMass );
        food.x = root.parent.centerX+x*(root.parent.moving.radius+food.moving.radius)*1.01;
        food.y = root.parent.centerY+y*(root.parent.moving.radius+food.moving.radius)*1.01;
        food.currentLevel = root.parent.currentLevel;
        food.moving.velocityX = root.parent.moving.velocityX+x;
        food.moving.velocityY = root.parent.moving.velocityY+y;
        food.currentLevel.childAdded( food );
        root.parent.moving.accel(x*root.parent.moving.mass, y*root.parent.moving.mass);
    }
}

