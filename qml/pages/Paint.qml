import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"


Page
{
    id: page

    width: 540
    height: 960

    property int drawColor: 0
    property int drawThickness: 0
    property bool clearRequest: false
    property int bgColor: colors.length

    Messagebox
    {
        id: messagebox
    }

    Toolpanel
    {
        id: toolPanel
        onShowMessage: messagebox.showMessage(message)
    }

    Toolbox
    {
        id: toolBox
        onShowMessage: messagebox.showMessage(message)
        anchors.top: toolPanel.bottom
    }

    Rectangle
    {
        id: bg
        anchors.fill: (toolBox.opacity == 0.0) ? page : canvas
        color: bgColor < colors.length ? colors[bgColor] : "transparent"
        z:7
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
        property color color: colors[drawColor]

        onPaint:
        {
            var ctx = getContext('2d')

            if (clearRequest)
            {
                ctx.clearRect(0,0,canvas.width, canvas.height);
                clearRequest = false
            }
            else
            {
                ctx.lineWidth = thicknesses[drawThickness]
                ctx.strokeStyle = canvas.color
                ctx.lineJoin = ctx.lineCap = 'round';
                ctx.beginPath()
                ctx.moveTo(lastX, lastY)
                lastX = area.mouseX
                lastY = area.mouseY
                ctx.lineTo(lastX, lastY)
                ctx.stroke()
            }
        }


        MouseArea
        {
            id: area
            anchors.fill: canvas
            onPressed:
            {
                canvas.lastX = mouseX
                canvas.lastY = mouseY
            }
            onPositionChanged:
            {
                canvas.requestPaint()
            }
        }
    }

    Component.onDestruction: canvas.destroy()

}
