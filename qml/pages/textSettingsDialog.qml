import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog
{
    id: textSettingsDialog
    canAccept: true

    property int currentColor: 0
    property int currentSize: 40
    property bool isBold: false
    property bool isItalic: false

    onDone:
    {
        if (result === DialogResult.Accepted)
        {
            currentSize = sizeSlider.value
            isBold = tsBold.checked
            isItalic = tsItalic.checked
        }
    }


    DialogHeader
    {
        id: pageHeader
        title:  qsTr("Text settings")
        acceptText: acceptText
        cancelText: cancelText
    }

    Column
    {
        id: col
        width: parent.width - Theme.paddingLarge
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: pageHeader.bottom

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
                        onClicked: currentColor = index
                    }
                }
            }
        }

        SectionHeader
        {
            text: qsTr("Font size")
        }

        Slider
        {
            id: sizeSlider
            value: currentSize
            valueText: value
            minimumValue: 10
            maximumValue: 100
            stepSize: 1
            width: parent.width - 2*Theme.paddingLarge
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Row
        {
            width: parent.width

            TextSwitch
            {
                id: tsBold
                text: qsTr("Bold")
                checked: isBold
                width: parent.width/2
            }
            TextSwitch
            {
                id: tsItalic
                text: qsTr("Italic")
                checked: isItalic
                width: parent.width/2
            }
        }

    }
}
