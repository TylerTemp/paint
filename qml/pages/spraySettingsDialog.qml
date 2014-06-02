import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog
{
    id: eraserSettingsDialog
    canAccept: true

    property int currentRadius: 0
    property int currentParticleSize: 0
    property int currentDensity: 0
    property int currentColor: 0

    property var showpage
    property var showpageComp

    onDone:
    {
        if (result === DialogResult.Accepted)
        {
            currentRadius = radiusSlider.value
            currentParticleSize = particleSizeSlider.value
            currentDensity = densitySlider.value
        }
    }

    function changepage(name)
    {
        if (showpage)
            showpage.destroy()

        showpageComp = Qt.createComponent(Qt.resolvedUrl("../components/" + name + ".qml"))
        if (showpageComp.status === Component.Ready)
            finishCreation(showpageComp);
        else
            showpageComp.statusChanged.connect(finishCreation);
    }

    function finishCreation()
    {
        showpage = showpageComp.createObject(eraserSettingsDialog)
    }


    SilicaFlickable
    {
        id: flick

        anchors.fill: parent
        contentHeight: col.height
        width: parent.width

        VerticalScrollDecorator { flickable: flick }

        Column
        {
            id: col
            width: parent.width - Theme.paddingLarge
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Theme.paddingSmall

            DialogHeader
            {
                id: pageHeader
                title:  qsTr("Sprayer settings")
                acceptText: acceptText
                cancelText: cancelText
            }

            SectionHeader
            {
                text: qsTr("Select color")
            }

            Grid
            {
                id: colorSelector
                columns: 4
                Repeater
                {
                    model: colors
                    Rectangle
                    {
                        width: col.width/colorSelector.columns
                        height: col.width/colorSelector.columns
                        radius: 10
                        color: (index == currentColor) ? colors[index] : "transparent"
                        Rectangle
                        {
                            width: parent.width - 20
                            height: parent.height - 20
                            radius: 5
                            color: colors[index]
                            anchors.centerIn: parent
                        }
                        BackgroundItem
                        {
                            anchors.fill: parent
                            onClicked:
                            {
                                currentColor = index
                                previewCanvas.requestPaint()
                            }
                        }
                    }
                }
            }

            Rectangle
            {

                color: "transparent"
                height: 250
                width: parent.width
                Canvas
                {
                    id: previewCanvas
                    anchors.fill: parent
                    renderTarget: Canvas.FramebufferObject
                    antialiasing: true

                    property bool clearNow : false
                    property int midX : width / 2
                    property int midY : height / 2

                    onPaint:
                    {
                        var ctx = getContext('2d')

                        ctx.clearRect(0, 0, width, height);

                        for (var i = densitySlider.value; i--; )
                        {
                            var angle = getRandomFloat(0, Math.PI*2)
                            var radius = getRandomFloat(1, radiusSlider.value)
                            var partsize = particleSizeSlider.value
                            ctx.fillStyle = colors[currentColor]
                            ctx.fillRect(midX + radius * Math.cos(angle), midY + radius * Math.sin(angle), partsize, partsize)
                        }
                    }
                }
            }

            SectionHeader
            {
                text: qsTr("Sprayer parameters")
            }

            Slider
            {
                id: radiusSlider
                label: qsTr("Size")
                value: currentRadius
                valueText: value*2
                minimumValue: 3
                maximumValue: 100
                stepSize: 1
                width: parent.width - 2*Theme.paddingLarge
                anchors.horizontalCenter: parent.horizontalCenter
                onValueChanged: previewCanvas.requestPaint()
            }
            Slider
            {
                id: densitySlider
                label: qsTr("Density")
                value: currentDensity
                valueText: value
                minimumValue: 10
                maximumValue: 200
                stepSize: 5
                width: parent.width - 2*Theme.paddingLarge
                anchors.horizontalCenter: parent.horizontalCenter
                onValueChanged: previewCanvas.requestPaint()
            }

            Slider
            {
                id: particleSizeSlider
                label: qsTr("Particle size")
                value: currentParticleSize
                valueText: value
                minimumValue: 1
                maximumValue: 10
                stepSize: 1
                width: parent.width - 2*Theme.paddingLarge
                anchors.horizontalCenter: parent.horizontalCenter
                onValueChanged: previewCanvas.requestPaint()
            }

        }
    }
}



