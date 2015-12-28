import QtQuick 2.0

Item {
    id: root
    property real velocityX: 0.0
    property real velocityY: 0.0
    property real friction: 0.8
    property real inertia: 0.994
    readonly property real mass: internal.internalMass
    readonly property real radius: Math.max(0.0, Math.sqrt(internal.internalMass)) // / Math.PI * constant
    Item {
        id: internal
        property real internalMass: 0
    }

    function accel(x, y) {
        var len = Math.sqrt(x*x + y*y);
        x /= len;
        y /= len;
        velocityX -= x;//*friction;
        velocityY -= y;//*friction;
    }
    function accelVar(x, y) {
        velocityX -= x;//*friction;
        velocityY -= y;//*friction;
    }
    function addMass(m) {
        internal.internalMass += m;
        //setMass(m + root.internal.internalMass);
    }

    function setMass(m) {
        var w = root.parent.width;
        var h = root.parent.height;
        internal.internalMass = m;
        return;
        var dw = root.parent.width-w;
        var dh = root.parent.height-h;
        root.parent.x += dw*0.5;
        root.parent.y += dh*0.5;
        if(Math.abs(w) >= 0.01 && Math.abs(h) >= 0.01) {
            for( var c in root.parent.containedChildren) {
                var ch = root.parent.containedChildren[c];
                if(!ch) continue;
                ch.x = ch.centerX*((w+dw)/w);//-ch.width*0.5;
                ch.y = ch.centerY*((h+dh)/h);//-ch.height*0.5;
            }
        } else {
            //for( var c in root.parent.containedChildren) {
            //    var ch = root.parent.containedChildren[c];
            //    if(!ch) continue;
                //ch.x += ch.width*0.5;
                //ch.y += ch.height*0.5;
            //}
        }

    }

    function step(t) {
        var ch = root.parent;
        ch.x += velocityX;
        ch.y += velocityY;
        velocityX *= inertia;
        velocityY *= inertia;
        var lvlRad = ch.currentLevel.width*0.5;
        var dx = ch.centerX//-lvlRad;
        var dy = ch.centerY//-lvlRad;
        var len = Math.sqrt(dx*dx + dy*dy);
        if( len > lvlRad-ch.circle.radius ) {
            if(dx > 0.0 && velocityX > 0.0 ||
               dx < 0.0 && velocityX < 0.0 ||
               dy > 0.0 && velocityY > 0.0 ||
               dy < 0.0 && velocityY < 0.0) {
                var dxn = dx / len;
                var dyn = dy / len;
                var dot = dxn * velocityX + dyn * velocityY;
                var velX = 2.0 * dxn * dot - velocityX;
                var velY = 2.0 * dyn * dot - velocityY;
                velocityX = -velX;
                velocityY = -velY;
            }

            var dx2 = ch.centerX + velocityX//-lvlRad;
            var dy2 = ch.centerY + velocityY//-lvlRad;
            var len2 = Math.sqrt(dx*dx + dy*dy) + ch.circle.radius;
            if(len2 > lvlRad) {
                ch.x *= len2/(len2+len2-lvlRad);
                ch.y *= len2/(len2+len2-lvlRad);
            }
        }
    }
}

