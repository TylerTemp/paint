import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.paint.PainterClass 1.0

Row
{
    id: toolbar2

    IconButton
    {
        icon.source: "image://paintIcons/icon-m-texttool"
        anchors.bottom: parent.bottom
        highlighted: drawMode === Painter.Text

        onClicked:
        {
            toolSettingsButton.icon.source = "image://paintIcons/icon-m-textsettings"
            drawMode = Painter.Text
            if (textEditPending)
                textEditCancel()
        }
    }

    IconButton
    {
        icon.source: "image://theme/icon-m-enter-accept"
        anchors.bottom: parent.bottom
        enabled: textEditPending

        onClicked: textEditAccept()
    }

    IconButton
    {
        icon.source: "image://paintIcons/icon-m-dimensiontool"
        anchors.bottom: parent.bottom
        highlighted: drawMode === Painter.Dimensioning

        onClicked: drawMode = Painter.Dimensioning
    }

    Rectangle
    {
        color: "transparent"
        width: 80
        height: 80
    }

    IconButton
    {
        id: toolSettingsButton
        icon.source: "image://paintIcons/icon-m-toolsettings"
        anchors.bottom: parent.bottom

        onClicked:
        {
            var SettingsDialog = pageStack.push(Qt.resolvedUrl("../pages/textSettingsDialog.qml"),
                                                 { "currentColor": textColor,
                                                   "currentSize": textFontSize,
                                                   "isBold": textFontBold,
                                                   "isItalic": textFontItalic })

            SettingsDialog.accepted.connect(function()
            {
                textColor = SettingsDialog.currentColor
                textFontSize = SettingsDialog.currentSize
                textFontBold = SettingsDialog.isBold
                textFontItalic = SettingsDialog.isItalic
                textSettingsChanged()
            })
        }
    }

}
