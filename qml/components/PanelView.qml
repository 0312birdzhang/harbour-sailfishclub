/*
  Copyright (C) 2013-2014 The Communi Project

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the copyright holder nor the names of its
      contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.1
import Sailfish.Silica 1.0

SilicaListView {
    id: container

    property Panel leftPanel
    property Panel rightPanel

    property real panelWidth: container.width / 5 * 3
    property real panelHeight: container.height

    readonly property bool closed: container.contentX - container.originX === container.panelWidth


    pressDelay: 0 // important! (makes vertical flicking "stable")
    interactive: !container.closed && !leftEdgeSwipe._dragging // non-interactive while closed or dragging

    function hidePanel() {
        if (leftEdgeSwipe._dragging) {
            return
        }
        if (container.moving) {
            delayedHide = true
        } else if (container.currentIndex !== 1) {
            container.currentIndex = 1
            shutter.start()
        }
    }

    property bool delayedHide: false
    onMovementEnded: {
        if (leftEdgeSwipe._dragging) {
            container.delayedHide = false
            return
        }
        if (container.delayedHide) {
            container.currentIndex = 1
        }
        container.delayedHide = false
    }

    Timer {
        id: shutter
        interval: 10
        onTriggered: {
            // a hack for the side panels getting stuck open
            if (!container.closed && !container.moving && container.currentIndex === 1) {
                container.currentIndex = 0
                container.currentIndex = 1
            }
        }
    }

    currentIndex: 0
    orientation: Qt.Horizontal
    snapMode: ListView.SnapOneItem
    boundsBehavior: Flickable.StopAtBounds
    highlightRangeMode: ListView.StrictlyEnforceRange
    highlightMoveDuration: 200

    Rectangle {
        z: -1
        width: container.width
        height: container.panelHeight
        color: Theme.highlightDimmerColor
        opacity: container.moving || container.currentIndex !== 1 || !container.closed ? 0.5 : 0.0
        Behavior on opacity { FadeAnimation { } }

        MouseArea {
            anchors.fill: parent
            enabled: !container.closed
            onClicked: {
                container.hidePanel()
            }
        }
    }

    // left edge drag area to open panel when closed
    MouseArea {
        id: leftEdgeSwipe
        width: Theme.paddingLarge * 6
        height: parent.height
        anchors.left: parent.left
        preventStealing: true
        enabled: container.closed || _dragging
        property int _pressX: 0
        property int _startContentX: 0
        property bool _dragging: false
        onPressed: {
            container.highlightRangeMode = ListView.NoHighlightRange
            container.snapMode = ListView.NoSnap
            _pressX = mouse.x
            _startContentX = container.contentX
            _dragging = true
        }
        onPositionChanged: {
            if (_dragging) {
                var target = _startContentX - (mouse.x - _pressX)
                container.contentX = Math.max(0, Math.min(container.panelWidth, target))
            }
        }
        onReleased: {
            if (_dragging) {
                _dragging = false
                var target = container.contentX < container.panelWidth * 2 / 3 ? 0 : 1
                container.highlightRangeMode = ListView.StrictlyEnforceRange
                container.snapMode = ListView.SnapOneItem
                container.currentIndex = target
                // lock position immediately to avoid the highlight-animation bounce
                container.contentX = target === 0 ? 0 : container.panelWidth
            }
        }
        onCanceled: {
            if (_dragging) {
                _dragging = false
                container.highlightRangeMode = ListView.StrictlyEnforceRange
                container.snapMode = ListView.SnapOneItem
                container.currentIndex = 1
                container.contentX = container.panelWidth
            }
        }
    }

    Connections {
        target: leftPanel
        onToggled: {
            if (leftPanel.active) {
                panelModel.prependPanel("leftPanel")
            } else {
                panelModel.removePanel("leftPanel")
            }
        }
    }

    Connections {
        target: rightPanel
        onToggled: {
            if (rightPanel.active)
                panelModel.appendPanel("rightPanel")
            else
                panelModel.removePanel("rightPanel")
        }
    }

    Binding { target: leftPanel; property: "__view"; value: container }
    Binding { target: leftPanel; property: "edge"; value: Qt.LeftEdge }

    Binding { target: rightPanel; property: "__view"; value: container }
    Binding { target: rightPanel; property: "edge"; value: Qt.RightEdge }

    Component.onCompleted: {
        if (leftPanel && leftPanel.active) {
            panelModel.prependPanel("leftPanel")
            currentIndex = 1
        }
        if (rightPanel && rightPanel.active)
            panelModel.appendPanel("rightPanel")
    }

    model: ListModel {
        id: panelModel

        ListElement { panel: "" }

        function appendPanel(panel) {
            var item = get(count - 1)
            if (item.panel !== panel) {
                append({panel: panel})
            }
        }

        function prependPanel(panel) {
            var item = get(0)
            if (item.panel !== panel) {
                insert(0, {panel: panel})
            }
        }

        function removePanel(panel) {
            for (var i = 0; i < count; ++i) {
                var item = get(i)
                if (item.panel === panel) {
                    remove(i)
                    break
                }
            }
        }
    }

    delegate: Item {
        id: delegate
        width: container.panelWidth
        height: container.height
        property Item panel: container[model.panel] || null
        Binding {
            target: panel
            property: "parent"
            value: delegate
        }
        Binding {
            target: panel
            property: "implicitWidth"
            value: container.panelWidth
        }
        Binding {
            target: panel
            property: "implicitHeight"
            value: container.panelHeight
        }
        Binding {
            target: panel
            property: "x"
            value: container.width - container.panelWidth
            when: index === 2 || ((!leftPanel || !leftPanel.active) && index === 1)
        }
    }
}
