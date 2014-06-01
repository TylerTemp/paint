import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.paint.PainterClass 1.0
import "../components"


Page
{
    id: page

    width: 540
    height: 960

    property int drawColor: 0
    property int drawThickness: 0
    property int bgColor: colors.length

    Messagebox
    {
        id: messagebox
    }

    Toolbox
    {
        id: toolBox
        onShowMessage: messagebox.showMessage(message, delay)
        onShowGeometryPopup: geometryPopup.visible = true
        anchors.top: parent.top
    }

    GeometryPopup
    {
        z:0
        id: geometryPopup
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: toolBox.bottom
        visible: false
        onVisibleChanged: z = visible ? 19 : 0
    }

    Rectangle
    {
        id: bg
        anchors.fill: (toolBox.opacity == 0.0) ? page : canvas
        color: bgColor < colors.length ? colors[bgColor] : "transparent"
        z:7
    }

    function getRandomFloat(min, max)
    {
      return Math.random() * (max - min) + min;
    }

    function drawLine(ctx, x0,y0,x1,y1)
    {
        ctx.lineWidth = thicknesses[drawThickness]
        ctx.strokeStyle = colors[drawColor]

        ctx.beginPath();
        ctx.moveTo(x0, y0);
        ctx.lineTo(x1, y1);
        ctx.stroke();
        ctx.closePath();
    }

    Canvas
    {
        id: geometryCanvas
        z: 10
        anchors.fill: canvas
        renderTarget: Canvas.FramebufferObject
        antialiasing: true

        property real downX
        property real downY
        property color color: colors[drawColor]

        property bool clearNow : false

        function clear()
        {
            clearNow = true
            requestPaint()
        }

        onPaint:
        {
            var ctx = getContext('2d')

            ctx.clearRect(0, 0, width, height);
            if (clearNow)
            {
                clearNow = false
                return
            }

            switch(geometricsMode)
            {
                case Painter.Line :
                    drawLine(ctx, downX, downY, area.mouseX, area.mouseY)
                    break;

                default:
                    break;
            }
        }
    }


    Canvas
    {
        id: canvas
        z: 9
        width: page.width
        anchors.top: toolBox.bottom
        height: page.height - toolBox.height
        renderTarget: Canvas.FramebufferObject
        antialiasing: true

        property real lastX
        property real lastY
        property int density: 50
        property real angle
        property real radius

        property bool clearNow : false

        function clear()
        {
            clearNow = true
            requestPaint()
        }

        onPaint:
        {
            var ctx = getContext('2d')

            if (clearNow)
            {
                ctx.clearRect(0, 0, width, height);
                clearNow = false
                return
            }

            switch (drawMode)
            {
                case Painter.Pen :
                    ctx.lineWidth = thicknesses[drawThickness]
                    ctx.strokeStyle = colors[drawColor]
                    ctx.lineJoin = ctx.lineCap = 'round';
                    ctx.beginPath()
                    ctx.moveTo(lastX, lastY)
                    lastX = area.mouseX
                    lastY = area.mouseY
                    ctx.lineTo(lastX, lastY)
                    ctx.stroke()
                    break;

                case Painter.Eraser :
                    radius = 10*thicknesses[drawThickness]
                    ctx.globalCompositeOperation = 'destination-out'
                    ctx.beginPath()
                    ctx.arc(area.mouseX, area.mouseY, radius, 0, Math.PI*2, true)
                    ctx.fill()
                    ctx.stroke()
                    ctx.globalCompositeOperation = 'source-over'
                    break;

                case Painter.Spray :
                    for (var i = density; i--; )
                    {
                        angle = getRandomFloat(0, Math.PI*2)
                        radius = getRandomFloat(0, 10*thicknesses[drawThickness])
                        ctx.fillStyle = colors[drawColor]
                        ctx.fillRect(lastX + radius * Math.cos(angle), lastY + radius * Math.sin(angle), 1+drawThickness, 1+drawThickness)
                    }
                    break;

                case Painter.Geometrics :
                    switch(geometricsMode)
                    {
                    case Painter.Line :
                        drawLine(ctx, geometryCanvas.downX, geometryCanvas.downY, area.mouseX, area.mouseY)
                        break;

                    default:
                        console.log("Sorry, not such geometry available")
                        break;
                    }

                    break;

                default:
                    console.log("You need to code some more...")
                    break;
            }
            lastX = area.mouseX
            lastY = area.mouseY
        }

        MouseArea
        {
            id: area
            anchors.fill: canvas
            onPressed:
            {
                console.log("pressed")
                geometryPopup.visible = false

                canvas.lastX = mouseX
                canvas.lastY = mouseY
                if (drawMode === Painter.Geometrics)
                {
                    geometryCanvas.downX = mouseX
                    geometryCanvas.downY = mouseY
                }
                else
                {
                    canvas.lastX = mouseX
                    canvas.lastY = mouseY
                }
            }

            onReleased:
            {
                console.log("released")
                if (drawMode === Painter.Geometrics)
                {
                    canvas.requestPaint()
                    geometryCanvas.clear()
                }
            }

            onPositionChanged:
            {
                if (drawMode === Painter.Geometrics)
                    geometryCanvas.requestPaint()
                else
                    canvas.requestPaint()
            }
        }
    }

    Component.onDestruction: canvas.destroy()

}
