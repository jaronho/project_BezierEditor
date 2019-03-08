import QtQuick 2.12
import QtQuick.Window 2.12

Window {
    readonly property string version: "v1.0.0";
    readonly property string author: "（作者：何展然）";
    id: win;
    visible: true;
    width: container.width + 10;
    height: container.height + (canvas_quadratic.visible ? 280 : 330);
    title: (canvas_quadratic.visible ? qsTr("二次贝塞尔曲线编辑器") : qsTr("三次贝塞尔曲线编辑器")) + " " + version + author;

    Item {
        anchors.fill: parent;

        /* 画布宽高设置 */
        Item {
            id: item_canvas_size_setting;
            anchors.horizontalCenter: parent.horizontalCenter;
            anchors.top: parent.top;
            anchors.topMargin: 10;
            width: container.width;
            height: 20;
            clip: true;

            /* 画布宽 */
            Text {
                id: text_canvas_width_title;
                anchors.left: parent.left;
                anchors.leftMargin: 40;
                text: qsTr("画布宽:");
                color: "#000000";
                font.pixelSize: 20;
            }

            XTextInput {
                id: input_canvas_width;
                anchors.left: text_canvas_width_title.right;
                anchors.leftMargin: 5;
                inputValidator: RegExpValidator {   /* 数字 */
                    regExp: /^[0-9]{0,}$/;
                }
                inputText: self.width;
                inputTextColor: "#000000";
                inputFont.pixelSize: 20;
                hintText: "";
                width: 80;
                onInputAccepted: function() {
                    var width = 0;
                    if (inputText.length > 0) {
                        width = parseInt(inputText);
                    }
                    if (width < 400) {
                        width = 400;
                    } else if (width > 1000) {
                        width = 1000;
                    }
                    inputText = width.toString();
                    self.width = width;
                }
            }

            /* 画布高 */
            Text {
                id: text_canvas_height_title;
                anchors.right: input_canvas_height.left;
                anchors.rightMargin: 5;
                text: qsTr("画布高:");
                color: "#000000";
                font.pixelSize: 20;
            }

            XTextInput {
                id: input_canvas_height;
                anchors.right: parent.right;
                anchors.rightMargin: 40;
                inputValidator: RegExpValidator {   /* 数字 */
                    regExp: /^[0-9]{0,}$/;
                }
                inputText: self.height;
                inputTextColor: "#000000";
                inputFont.pixelSize: 20;
                hintText: "";
                width: 80;
                onInputAccepted: function() {
                    var height = 0;
                    if (inputText.length > 0) {
                        height = parseInt(inputText);
                    }
                    if (height < 200) {
                        height = 200;
                    } else if (height > 600) {
                        height = 600;
                    }
                    inputText = height.toString();
                    self.height = height;
                }
            }
        }

        /* 切换按钮 */
        XButton {
            id: button_switch;
            anchors.horizontalCenter: parent.horizontalCenter;
            anchors.top: item_canvas_size_setting.bottom;
            anchors.topMargin: 10;
            width: 210;
            height: 30;
            hint.text: canvas_quadratic.visible ? qsTr("切换为三次贝塞尔曲线") : qsTr("切换为二次贝塞尔曲线");
            hint.font.pixelSize: 20;
            onButtonClick: function() {
                listmodel_curve.clear();
                canvas_quadratic.visible = !canvas_quadratic.visible;
                win.setMinimumWidth(container.width + 10);
                win.setMinimumHeight(container.height + (canvas_quadratic.visible ? 280 : 330));
                win.setMaximumWidth(container.width + 10);
                win.setMaximumHeight(container.height + (canvas_quadratic.visible ? 280 : 330));
                win.setHeight(container.height + (canvas_quadratic.visible ? 280 : 330));
                if (canvas_quadratic.visible) {
                    for (var i = 0; i < canvas_quadratic.list_curve.length; ++i) {
                        listmodel_curve.append(canvas_quadratic.list_curve[i]);
                    }
                } else {
                    for (var j = 0; j < canvas_cubic.list_curve.length; ++j) {
                        listmodel_curve.append(canvas_cubic.list_curve[j]);
                    }
                }
            }
        }

        /* 左上角 */
        Text {
            id: text_corner_left_top;
            anchors.left: container.left;
            anchors.top: item_canvas_size_setting.bottom;
            anchors.topMargin: 25;
            text: qsTr("(0,0)");
            font.pixelSize: 16;
        }

        /* 右上角 */
        Text {
            id: text_corner_right_top;
            anchors.right: container.right;
            anchors.top: item_canvas_size_setting.bottom;
            anchors.topMargin: 25;
            text: qsTr("(" + self.width + ",0)");
            font.pixelSize: 16;
        }

        Item {
            id: container;
            anchors.horizontalCenter: parent.horizontalCenter;
            anchors.top: text_corner_left_top.bottom;
            width: self.width + 2 * self.margin;
            height: self.height + 2 * self.margin;

            /* 三次贝塞尔曲线画布 */
            Canvas {
                property var list_curve: [];
                id: canvas_cubic;
                anchors.fill: parent;
                renderStrategy: Canvas.Threaded;
                visible: !canvas_quadratic.visible;
                onPaint: {
                    draw();
                }
                function draw() {
                    var ctx = getContext("2d");
                    ctx.fillStyle = "#FFFFFF";
                    ctx.fillRect(0, 0, self.width + 2 * self.margin, self.height + 2 * self.margin);
                    ctx.fillStyle = "#EEEEEE";
                    ctx.fillRect(self.margin, self.margin, self.width, self.height);
                    if (0 === list_curve.length) {
                        return;
                    }
                    for (var i = 0; i < list_curve.length; ++i) {
                        var pt = list_curve[i];
                        /* 坐标偏移计算 */
                        var startX = self.clamp(pt.start_x, 0, self.width) + self.margin;
                        var startY = self.clamp(pt.start_y, 0, self.height) + self.margin;
                        var control1X = self.clamp(pt.control_1_x, 0, self.width) + self.margin;
                        var control1Y = self.clamp(pt.control_1_y, 0, self.height) + self.margin;
                        var control2X = self.clamp(pt.control_2_x, 0, self.width) + self.margin;
                        var control2Y = self.clamp(pt.control_2_y, 0, self.height) + self.margin;
                        var endX = self.clamp(pt.end_x, 0, self.width) + self.margin;
                        var endY = self.clamp(pt.end_y, 0, self.height) + self.margin;
                        /* 绘制曲线 */
                        self.drawCubicBezierCruve(ctx, startX, startY, control1X, control1Y, control2X, control2Y, endX, endY, self.curve_width, "#AAAAAA");
                        if (1 === pt.debug || 2 === pt.debug) {
                            if (2 === pt.debug) {
                                self.drawLine(ctx, startX, startY, control1X, control1Y, 1, "#FF0000");
                                self.drawLine(ctx, endX, endY, control2X, control2Y, 1, "#FF0000");
                            }
                            /* 绘制起点 */
                            self.drawCircle(ctx, startX, startY, self.point_radius, "#FF0000");
                            /* 绘制控制点1 */
                            self.drawCircle(ctx, control1X, control1Y, self.point_radius, "#006400");
                            /* 绘制控制点2 */
                            self.drawCircle(ctx, control2X, control2Y, self.point_radius, "#00868B");
                            /* 绘制终点 */
                            self.drawCircle(ctx, endX, endY, self.point_radius, "#0000FF");
                        }
                    }
                }
            }

            /* 二次贝塞尔曲线画布 */
            Canvas {
                property var list_curve: [];
                id: canvas_quadratic;
                anchors.fill: parent;
                renderStrategy: Canvas.Threaded;
                visible: !canvas_cubic.visible;
                onPaint: {
                    draw();
                }
                function draw() {
                    var ctx = getContext("2d");
                    ctx.fillStyle = "#FFFFFF";
                    ctx.fillRect(0, 0, self.width + 2 * self.margin, self.height + 2 * self.margin);
                    ctx.fillStyle = "#EEEEEE";
                    ctx.fillRect(self.margin, self.margin, self.width, self.height);
                    if (0 === list_curve.length) {
                        return;
                    }
                    for (var i = 0; i < list_curve.length; ++i) {
                        var pt = list_curve[i];
                        /* 坐标偏移计算 */
                        var startX = self.clamp(pt.start_x, 0, self.width) + self.margin;
                        var startY = self.clamp(pt.start_y, 0, self.height) + self.margin;
                        var control1X = self.clamp(pt.control_1_x, 0, self.width) + self.margin;
                        var control1Y = self.clamp(pt.control_1_y, 0, self.height) + self.margin;
                        var endX = self.clamp(pt.end_x, 0, self.width) + self.margin;
                        var endY = self.clamp(pt.end_y, 0, self.height) + self.margin;
                        /* 绘制曲线 */
                        self.drawQuadraticBezierCruve(ctx, startX, startY, control1X, control1Y, endX, endY, self.curve_width, "#AAAAAA");
                        if (1 === pt.debug || 2 === pt.debug) {
                            if (2 === pt.debug) {
                                self.drawLine(ctx, startX, startY, control1X, control1Y, 1, "#FF0000");
                                self.drawLine(ctx, endX, endY, control1X, control1Y, 1, "#FF0000");
                            }
                            /* 绘制起点 */
                            self.drawCircle(ctx, startX, startY, self.point_radius, "#FF0000");
                            /* 绘制控制点 */
                            self.drawCircle(ctx, control1X, control1Y, self.point_radius, "#006400");
                            /* 绘制终点 */
                            self.drawCircle(ctx, endX, endY, self.point_radius, "#0000FF");
                        }
                    }
                }
            }

            /* 帧率定时器 */
            Timer {
                id: timer_fps;
                interval: (1000 / 60);  /* 帧率:60(FPS) */
                repeat: true;
                running: true;
                onTriggered: {
                    canvas_quadratic.requestAnimationFrame(canvas_quadratic.draw);
                    canvas_cubic.requestAnimationFrame(canvas_cubic.draw);
                }
            }

            /* 函数模块 */
            QtObject {
                id: self;
                readonly property int curve_width: 3;   /* 曲线宽度 */
                readonly property int point_radius: 10; /* 圆点半径 */
                property int width: 480;
                property int height: 240;
                property int margin: 10;
                /* 绘制二次贝塞尔曲线 */
                function drawQuadraticBezierCruve(ctx, startX, startY, controlX, controlY, endX, endY, width, style) {
                    ctx.beginPath();
                    ctx.moveTo(startX, startY);
                    ctx.quadraticCurveTo(controlX, controlY, endX, endY);
                    ctx.lineWidth = width;
                    ctx.strokeStyle = style;
                    ctx.stroke();
                }
                /* 绘制三次贝塞尔曲线 */
                function drawCubicBezierCruve(ctx, startX, startY, control1X, control1Y, control2X, control2Y, endX, endY, width, style) {
                    ctx.beginPath();
                    ctx.moveTo(startX, startY);
                    ctx.bezierCurveTo(control1X, control1Y, control2X, control2Y, endX, endY);
                    ctx.lineWidth = width;
                    ctx.strokeStyle = style;
                    ctx.stroke();
                }
                /* 绘制直线 */
                function drawLine(ctx, x1, y1, x2, y2, width, style) {
                    ctx.beginPath();
                    ctx.moveTo(x1, y1);
                    ctx.lineTo(x2, y2);
                    ctx.lineWidth = width;
                    ctx.strokeStyle = style;
                    ctx.stroke();
                }
                /* 绘制圆点 */
                function drawCircle(ctx, x, y, radius, style) {
                    ctx.beginPath();
                    ctx.arc(x, y, radius, 0, 360, true);
                    ctx.fillStyle = style;
                    ctx.fill();
                }
                /* 数值夹具 */
                function clamp(value, min, max) {
                    if (min > max) {
                        var tmp = min;
                        min = max;
                        max = tmp;
                    }
                    value = value > min ? value : min;
                    value = value < max ? value : max;
                    return value;
                }
                /* 点是否在圆内 */
                function isPointInCircle(centerX, centerY, radius, x, y) {
                    var distance = Math.sqrt(Math.pow(x - centerX, 2) + Math.pow(y - centerY, 2));
                    return distance <= radius;
                }
            }

            /* 鼠标操作区域 */
            MouseArea {
                property int curve_index: -1;   /* 曲线索引 */
                property int point_type: 0;     /* 点类型:1.起点,2.控制点1,3.控制点2,4.终点 */
                x: self.margin;
                y: self.margin;
                width: self.width;
                height: self.height;
                onPressed: {
                    var mX = mouseX;
                    if (mX < 0) {
                        mX = 0;
                    } else if (mX > self.width) {
                        mX = self.width;
                    }
                    var mY = mouseY;
                    if (mY < 0) {
                        mY = 0;
                    } else if (mY > self.height) {
                        mY = self.height;
                    }
                    //console.log("on pressed: (" + mX + ", " + mY + ")");
                    curve_index = -1;
                    point_type = 0;
                    if (canvas_quadratic.visible) { /* 二次贝塞尔曲线 */
                        for (var i = canvas_quadratic.list_curve.length - 1; i >= 0; --i) {
                            var pt1 = canvas_quadratic.list_curve[i];
                            if (1 === pt1.debug || 2 === pt1.debug) {
                                if (self.isPointInCircle(pt1.end_x, pt1.end_y, self.point_radius, mX, mY)) {  /* 点击了终点 */
                                    curve_index = i;
                                    point_type = 4;
                                    break;
                                } else if (self.isPointInCircle(pt1.control_1_x, pt1.control_1_y, self.point_radius, mX, mY)) {  /* 点击了控制点 */
                                    curve_index = i;
                                    point_type = 2;
                                    break;
                                } else if (self.isPointInCircle(pt1.start_x, pt1.start_y, self.point_radius, mX, mY)) {  /* 点击了起点 */
                                    curve_index = i;
                                    point_type = 1;
                                    break;
                                }
                            }
                        }
                    } else {  /* 三次贝塞尔曲线 */
                        for (var j = canvas_cubic.list_curve.length - 1; j >= 0; --j) {
                            var pt2 = canvas_cubic.list_curve[j];
                            if (1 === pt2.debug || 2 === pt2.debug) {
                                if (self.isPointInCircle(pt2.end_x, pt2.end_y, self.point_radius, mX, mY)) {  /* 点击了终点 */
                                    curve_index = j;
                                    point_type = 4;
                                    break;
                                } else if (self.isPointInCircle(pt2.control_2_x, pt2.control_2_y, self.point_radius, mX, mY)) {  /* 点击了控制点2 */
                                    curve_index = j;
                                    point_type = 3;
                                    break;
                                } else if (self.isPointInCircle(pt2.control_1_x, pt2.control_1_y, self.point_radius, mX, mY)) {  /* 点击了控制点1 */
                                    curve_index = j;
                                    point_type = 2;
                                    break;
                                } else if (self.isPointInCircle(pt2.start_x, pt2.start_y, self.point_radius, mX, mY)) {  /* 点击了起点 */
                                    curve_index = j;
                                    point_type = 1;
                                    break;
                                }
                            }
                        }
                    }
                }
                onReleased: {
                    var mX = mouseX;
                    if (mX < 0) {
                        mX = 0;
                    } else if (mX > self.width) {
                        mX = self.width;
                    }
                    var mY = mouseY;
                    if (mY < 0) {
                        mY = 0;
                    } else if (mY > self.height) {
                        mY = self.height;
                    }
                    //console.log("on released: (" + mX + ", " + mY + ")");
                    curve_index = -1;
                    point_type = 0;
                }
                onMouseXChanged: {
                    var mX = mouseX;
                    if (mX < 0) {
                        mX = 0;
                    } else if (mX > self.width) {
                        mX = self.width;
                    }
                    var mY = mouseY;
                    if (mY < 0) {
                        mY = 0;
                    } else if (mY > self.height) {
                        mY = self.height;
                    }
                    //console.log("on x changed: (" + mX + ", " + mY + ")");
                    if (canvas_quadratic.visible) { /* 二次贝塞尔曲线 */
                        if (curve_index >= 0) {
                            var pt1 = canvas_quadratic.list_curve[curve_index];
                            if (1 === pt1.debug || 2 === pt1.debug) {
                                if (1 === point_type) {
                                    pt1.start_x = mX;
                                    listmodel_curve.get(curve_index).start_x = mX;
                                } else if (2 === point_type) {
                                    pt1.control_1_x = mX;
                                    listmodel_curve.get(curve_index).control_1_x = mX;
                                } else if (4 === point_type) {
                                    pt1.end_x = mX;
                                    listmodel_curve.get(curve_index).end_x = mX;
                                }
                            }
                        }

                    } else {  /* 三次贝塞尔曲线 */
                        if (curve_index >= 0) {
                            var pt2 = canvas_cubic.list_curve[curve_index];
                            if (1 === pt2.debug || 2 === pt2.debug) {
                                if (1 === point_type) {
                                    pt2.start_x = mX;
                                    listmodel_curve.get(curve_index).start_x = mX;
                                } else if (2 === point_type) {
                                    pt2.control_1_x = mX;
                                    listmodel_curve.get(curve_index).control_1_x = mX;
                                } else if (3 === point_type) {
                                    pt2.control_2_x = mX;
                                    listmodel_curve.get(curve_index).control_2_x = mX;
                                } else if (4 === point_type) {
                                    pt2.end_x = mX;
                                    listmodel_curve.get(curve_index).end_x = mX;
                                }
                            }
                        }
                    }
                }
                onMouseYChanged: {
                    var mX = mouseX;
                    if (mX < 0) {
                        mX = 0;
                    } else if (mX > self.width) {
                        mX = self.width;
                    }
                    var mY = mouseY;
                    if (mY < 0) {
                        mY = 0;
                    } else if (mY > self.height) {
                        mY = self.height;
                    }
                    //console.log("on y changed: (" + mX + ", " + mY + ")");
                    if (canvas_quadratic.visible) { /* 二次贝塞尔曲线 */
                        if (curve_index >= 0) {
                            var pt1 = canvas_quadratic.list_curve[curve_index];
                            if (1 === pt1.debug || 2 === pt1.debug) {
                                if (1 === point_type) {
                                    pt1.start_y = mY;
                                    listmodel_curve.get(curve_index).start_y = mY;
                                } else if (2 === point_type) {
                                    pt1.control_1_y = mY;
                                    listmodel_curve.get(curve_index).control_1_y = mY;
                                } else if (4 === point_type) {
                                    pt1.end_y = mY;
                                    listmodel_curve.get(curve_index).end_y = mY;
                                }
                            }
                        }
                    } else {  /* 三次贝塞尔曲线 */
                        if (curve_index >= 0) {
                            var pt2 = canvas_cubic.list_curve[curve_index];
                            if (1 === pt2.debug || 2 === pt2.debug) {
                                if (1 === point_type) {
                                    pt2.start_y = mY;
                                    listmodel_curve.get(curve_index).start_y = mY;
                                } else if (2 === point_type) {
                                    pt2.control_1_y = mY;
                                    listmodel_curve.get(curve_index).control_1_y = mY;
                                } else if (3 === point_type) {
                                    pt2.control_2_y = mY;
                                    listmodel_curve.get(curve_index).control_2_y = mY;
                                } else if (4 === point_type) {
                                    pt2.end_y = mY;
                                    listmodel_curve.get(curve_index).end_y = mY;
                                }
                            }
                        }
                    }
                }
            }
        }

        /* 左下角 */
        Text {
            id: text_corner_left_bottom;
            anchors.left: container.left;
            anchors.top: container.bottom;
            text: qsTr("(0," + self.height + ")");
            font.pixelSize: 16;
        }

        /* 右下角 */
        Text {
            id: text_corner_right_bottom;
            anchors.right: container.right;
            anchors.top: container.bottom;
            text: qsTr("(" + self.width + "," + self.height + ")");
            font.pixelSize: 16;
        }

        /* 添加按钮 */
        XButton {
            id: button_add;
            anchors.top: container.bottom;
            anchors.horizontalCenter: parent.horizontalCenter;
            hint.text: "添加曲线";
            hint.color: "#000000";
            hint.font.pixelSize: 20;
            width: 90;
            height: 30;
            onButtonClick: function() {
                if (canvas_quadratic.visible) {
                    var pt1 = {
                        start_x: 0,
                        start_y: self.height,
                        control_1_x: self.width/2,
                        control_1_y: self.height/2,
                        control_2_x: 0,
                        control_2_y: 0,
                        end_x: self.width,
                        end_y: 0,
                        debug: 1
                    };
                    canvas_quadratic.list_curve.push(pt1);
                    listmodel_curve.append(pt1);
                } else {
                    var pt2 = {
                        start_x: 0,
                        start_y: self.height,
                        control_1_x: self.width/2 - 100,
                        control_1_y: self.height/2 + 100,
                        control_2_x: self.width/2 + 100,
                        control_2_y: self.height/2 - 100,
                        end_x: self.width,
                        end_y: 0,
                        debug: 1
                    };
                    canvas_cubic.list_curve.push(pt2);
                    listmodel_curve.append(pt2);
                }
            }
        }

        /* 分割线 */
        Rectangle {
            width: container.width;
            height: 1;
            anchors.horizontalCenter: parent.horizontalCenter;
            anchors.top: button_add.bottom;
            anchors.topMargin: 5;
            color: "#BBBBBB";
        }

        ListView {
            id: listview_curve;
            width: self.width;
            height: canvas_quadratic.visible ? 170 : 220;
            anchors.horizontalCenter: parent.horizontalCenter;
            anchors.top: button_add.bottom;
            anchors.topMargin: 10;
            model: ListModel {
                id: listmodel_curve;
            }
            clip: true;
            delegate: Item {
                width: listview_curve.width;
                height: canvas_quadratic.visible ? 85 : 110;

                Rectangle {
                    anchors.fill: parent;
                    color: "#F0F0F0";
                }

                Text {
                    anchors.left: parent.left;
                    anchors.leftMargin: 30;
                    anchors.verticalCenter: parent.verticalCenter;
                    text: "第" + (index + 1) + "条";
                    color: "#000000";
                    font.pixelSize: 20;
                }

                /* 起点坐标 */
                Text {
                    id: text_start_title;
                    anchors.left: parent.left;
                    anchors.leftMargin: (parent.width - (input_start_y.x + input_start_y.width - text_start_title.x)) / 2;
                    anchors.top: parent.top;
                    anchors.topMargin: 5;
                    text: qsTr("起点:");
                    color: "#FF0000";
                    font.pixelSize: 20;
                    font.bold: true;
                }

                XTextInput {
                    id: input_start_x;
                    anchors.left: text_start_title.left;
                    anchors.leftMargin: 90;
                    anchors.top: parent.top;
                    anchors.topMargin: text_start_title.anchors.topMargin;
                    inputValidator: RegExpValidator {   /* 数字 */
                        regExp: /^[0-9]{0,}$/;
                    }
                    inputText: start_x;
                    inputTextColor: "#FF0000";
                    inputFont.pixelSize: 20;
                    inputFont.bold: true;
                    hintText: "";
                    width: 80;
                    onInputTextEdited: function() {
                        var x = 0;
                        if (inputText.length > 0) {
                            x = parseInt(inputText);
                        }
                        if (x > self.width) {
                            x = self.width;
                        }
                        start_x = x;
                        inputText = x.toString();
                        if (canvas_quadratic.visible) {
                            canvas_quadratic.list_curve[index].start_x = x;
                        } else {
                            canvas_cubic.list_curve[index].start_x = x;
                        }
                    }
                    Timer {
                        interval: 100;
                        repeat: true;
                        running: true;
                        onTriggered: {
                            input_start_x.inputText = start_x;
                        }
                    }
                }

                XTextInput {
                    id: input_start_y;
                    anchors.left: input_start_x.right;
                    anchors.leftMargin: 5;
                    anchors.top: parent.top;
                    anchors.topMargin: text_start_title.anchors.topMargin;
                    inputValidator: RegExpValidator {   /* 数字 */
                        regExp: /^[0-9]{0,}$/;
                    }
                    inputText: start_y;
                    inputTextColor: "#FF0000";
                    inputFont.pixelSize: 20;
                    inputFont.bold: true;
                    hintText: "";
                    width: 80;
                    onInputTextEdited: function() {
                        var y = 0;
                        if (inputText.length > 0) {
                            y = parseInt(inputText);
                        }
                        if (y > self.height) {
                            y = self.height;
                        }
                        start_y = y;
                        inputText = y.toString();
                        if (canvas_quadratic.visible) {
                            canvas_quadratic.list_curve[index].start_y = y;
                        } else {
                            canvas_cubic.list_curve[index].start_y = y;
                        }
                    }
                    Timer {
                        interval: 100;
                        repeat: true;
                        running: true;
                        onTriggered: {
                            input_start_y.inputText = start_y;
                        }
                    }
                }

                /* 控制点1坐标 */
                Text {
                    id: text_control_1_title
                    anchors.left: parent.left;
                    anchors.leftMargin: text_start_title.anchors.leftMargin;
                    anchors.top: text_start_title.bottom;
                    anchors.topMargin: 5;
                    text: canvas_quadratic.visible ? qsTr("控制点:") : qsTr("控制点1:");
                    color: "#006400";
                    font.pixelSize: 20;
                    font.bold: true;
                }

                XTextInput {
                    id: input_control_1_x;
                    anchors.left: text_control_1_title.left;
                    anchors.leftMargin: input_start_x.anchors.leftMargin;
                    anchors.top: text_start_title.bottom;
                    anchors.topMargin: text_control_1_title.anchors.topMargin;
                    inputValidator: RegExpValidator {   /* 数字 */
                        regExp: /^[0-9]{0,}$/;
                    }
                    inputText: control_1_x;
                    inputTextColor: "#006400";
                    inputFont.pixelSize: 20;
                    inputFont.bold: true;
                    hintText: "";
                    width: 80;
                    onInputTextEdited: function() {
                        var x = 0;
                        if (inputText.length > 0) {
                            x = parseInt(inputText);
                        }
                        if (x > self.width) {
                            x = self.width;
                        }
                        control_1_x = x;
                        inputText = x.toString();
                        if (canvas_quadratic.visible) {
                            canvas_quadratic.list_curve[index].control_1_x = x;
                        } else {
                            canvas_cubic.list_curve[index].control_1_x = x;
                        }
                    }
                    Timer {
                        interval: 100;
                        repeat: true;
                        running: true;
                        onTriggered: {
                            input_control_1_x.inputText = control_1_x;
                        }
                    }
                }

                XTextInput {
                    id: input_control_1_y;
                    anchors.left: input_control_1_x.right;
                    anchors.leftMargin: input_start_y.anchors.leftMargin;
                    anchors.top: text_start_title.bottom;
                    anchors.topMargin: text_control_1_title.anchors.topMargin;
                    inputValidator: RegExpValidator {   /* 数字 */
                        regExp: /^[0-9]{0,}$/;
                    }
                    inputText: control_1_y;
                    inputTextColor: "#006400";
                    inputFont.pixelSize: 20;
                    inputFont.bold: true;
                    hintText: "";
                    width: 80;
                    onInputTextEdited: function() {
                        var y = 0;
                        if (inputText.length > 0) {
                            y = parseInt(inputText);
                        }
                        if (y > self.height) {
                            y = self.height;
                        }
                        control_1_y = y;
                        inputText = y.toString();
                        if (canvas_quadratic.visible) {
                            canvas_quadratic.list_curve[index].control_1_y = y;
                        } else {
                            canvas_cubic.list_curve[index].control_1_y = y;
                        }
                    }
                    Timer {
                        interval: 100;
                        repeat: true;
                        running: true;
                        onTriggered: {
                            input_control_1_y.inputText = control_1_y;
                        }
                    }
                }

                /* 控制点2坐标 */
                Text {
                    id: text_control_2_title;
                    anchors.left: parent.left;
                    anchors.leftMargin: text_start_title.anchors.leftMargin;
                    anchors.top: text_control_1_title.bottom;
                    anchors.topMargin: text_control_1_title.anchors.topMargin;
                    text: qsTr("控制点2:");
                    color: "#00868B";
                    font.pixelSize: 20;
                    font.bold: true;
                    visible: canvas_quadratic.visible ? false : true;
                }

                XTextInput {
                    id: input_control_2_x;
                    anchors.left: text_control_2_title.left;
                    anchors.leftMargin: input_start_x.anchors.leftMargin;
                    anchors.top: text_control_1_title.bottom;
                    anchors.topMargin: text_control_2_title.anchors.topMargin;
                    inputValidator: RegExpValidator {   /* 数字 */
                        regExp: /^[0-9]{0,}$/;
                    }
                    inputText: control_2_x;
                    inputTextColor: "#00868B";
                    inputFont.pixelSize: 20;
                    inputFont.bold: true;
                    hintText: "";
                    width: 80;
                    visible: canvas_quadratic.visible ? false : true;
                    onInputTextEdited: function() {
                        var x = 0;
                        if (inputText.length > 0) {
                            x = parseInt(inputText);
                        }
                        if (x > self.width) {
                            x = self.width;
                        }
                        control_2_x = x;
                        inputText = x.toString();
                        canvas_cubic.list_curve[index].control_2_x = x;
                    }
                    Timer {
                        interval: 100;
                        repeat: true;
                        running: true;
                        onTriggered: {
                            input_control_2_x.inputText = control_2_x;
                        }
                    }
                }

                XTextInput {
                    id: input_control_2_y;
                    anchors.left: input_control_2_x.right;
                    anchors.leftMargin: input_control_1_y.anchors.leftMargin;
                    anchors.top: text_control_1_title.bottom;
                    anchors.topMargin: text_control_2_title.anchors.topMargin;
                    inputValidator: RegExpValidator {   /* 数字 */
                        regExp: /^[0-9]{0,}$/;
                    }
                    inputText: control_2_y;
                    inputTextColor: "#00868B";
                    inputFont.pixelSize: 20;
                    inputFont.bold: true;
                    hintText: "";
                    width: 80;
                    visible: canvas_quadratic.visible ? false : true;
                    onInputTextEdited: function() {
                        var y = 0;
                        if (inputText.length > 0) {
                            y = parseInt(inputText);
                        }
                        if (y > self.height) {
                            y = self.height;
                        }
                        control_2_y = y;
                        inputText = y.toString();
                        canvas_cubic.list_curve[index].control_2_y = y;
                    }
                    Timer {
                        interval: 100;
                        repeat: true;
                        running: true;
                        onTriggered: {
                            input_control_2_y.inputText = control_2_y;
                        }
                    }
                }

                /* 终点坐标 */
                Text {
                    id: text_end_title;
                    anchors.left: parent.left;
                    anchors.leftMargin: text_start_title.anchors.leftMargin;
                    anchors.top: canvas_quadratic.visible ? text_control_1_title.bottom : text_control_2_title.bottom;
                    anchors.topMargin: text_control_1_title.anchors.topMargin;
                    text: qsTr("终点:");
                    color: "#0000FF";
                    font.pixelSize: 20;
                    font.bold: true;
                }

                XTextInput {
                    id: input_end_x;
                    anchors.left: text_end_title.left;
                    anchors.leftMargin: input_start_x.anchors.leftMargin;
                    anchors.top: canvas_quadratic.visible ? text_control_1_title.bottom : text_control_2_title.bottom;
                    anchors.topMargin: text_end_title.anchors.topMargin;
                    inputValidator: RegExpValidator {   /* 数字 */
                        regExp: /^[0-9]{0,}$/;
                    }
                    inputText: end_x;
                    inputTextColor: "#0000FF";
                    inputFont.pixelSize: 20;
                    inputFont.bold: true;
                    hintText: "";
                    width: 80;
                    onInputTextEdited: function() {
                        var x = 0;
                        if (inputText.length > 0) {
                            x = parseInt(inputText);
                        }
                        if (x > self.width) {
                            x = self.width;
                        }
                        end_x = x;
                        inputText = x.toString();
                        if (canvas_quadratic.visible) {
                            canvas_quadratic.list_curve[index].end_x = x;
                        } else {
                            canvas_cubic.list_curve[index].end_x = x;
                        }
                    }
                    Timer {
                        interval: 100;
                        repeat: true;
                        running: true;
                        onTriggered: {
                            input_end_x.inputText = end_x;
                        }
                    }
                }

                XTextInput {
                    id: input_end_y;
                    anchors.left: input_end_x.right;
                    anchors.leftMargin: input_start_y.anchors.leftMargin;
                    anchors.top: canvas_quadratic.visible ? text_control_1_title.bottom : text_control_2_title.bottom;
                    anchors.topMargin: input_end_x.anchors.topMargin;
                    inputValidator: RegExpValidator {   /* 数字 */
                        regExp: /^[0-9]{0,}$/;
                    }
                    inputText: end_y;
                    inputTextColor: "#0000FF";
                    inputFont.pixelSize: 20;
                    inputFont.bold: true;
                    hintText: "";
                    width: 80;
                    onInputTextEdited: function() {
                        var y = 0;
                        if (inputText.length > 0) {
                            y = parseInt(inputText);
                        }
                        if (y > self.height) {
                            y = self.height;
                        }
                        end_y = y;
                        inputText = y.toString();
                        if (canvas_quadratic.visible) {
                            canvas_quadratic.list_curve[index].end_y = y;
                        } else {
                            canvas_cubic.list_curve[index].end_y = y;
                        }
                    }
                    Timer {
                        interval: 100;
                        repeat: true;
                        running: true;
                        onTriggered: {
                            input_end_y.inputText = end_y;
                        }
                    }
                }

                XButton {
                    anchors.top: parent.top;
                    anchors.topMargin: 5;
                    anchors.right: parent.right;
                    anchors.rightMargin: 30;
                    hint.text: 1 === debug ? "调试1" : (2 === debug ? "调试2" : "调试关");
                    hint.color: "#000000";
                    hint.font.pixelSize: 20;
                    width: 65;
                    height: 30;
                    onButtonClick: function() {
                        if (0 === debug) {
                            debug = 1;
                        } else if (1 === debug) {
                            debug = 2;
                        } else if (2 === debug) {
                            debug = 0;
                        }
                        if (canvas_quadratic.visible) {
                            canvas_quadratic.list_curve[index].debug = debug;
                        } else {
                            canvas_cubic.list_curve[index].debug = debug;
                        }
                    }
                }

                XButton {
                    anchors.bottom: parent.bottom;
                    anchors.bottomMargin: 10;
                    anchors.right: parent.right;
                    anchors.rightMargin: 30;
                    hint.text: "删除";
                    hint.color: "#000000";
                    hint.font.pixelSize: 20;
                    width: 50;
                    height: 30;
                    onButtonClick: function() {
                        if (canvas_quadratic.visible) {
                            canvas_quadratic.list_curve.splice(index, 1);
                        } else {
                            canvas_cubic.list_curve.splice(index, 1);
                        }
                        listmodel_curve.remove(index);
                    }
                }

                Rectangle {
                    width: parent.width;
                    height: 5;
                    anchors.bottom: parent.bottom;
                    color: "#FFFFFF";
                }
            }
        }

        Component.onCompleted: {
            win.setMinimumWidth(container.width + 10);
            win.setMinimumHeight(container.height + (canvas_quadratic.visible ? 280 : 330));
            win.setMaximumWidth(container.width + 10);
            win.setMaximumHeight(container.height + (canvas_quadratic.visible ? 280 : 330));
            win.setHeight(container.height + (canvas_quadratic.visible ? 280 : 330));
            if (canvas_quadratic.visible) {
                listmodel_curve.clear();
                for (var i = 0; i < canvas_quadratic.list_curve.length; ++i) {
                    listmodel_curve.append(canvas_quadratic.list_curve[i]);
                }
            } else {
                listmodel_curve.clear();
                for (var j = 0; j < canvas_cubic.list_curve.length; ++j) {
                    listmodel_curve.append(canvas_cubic.list_curve[j]);
                }
            }
        }
    }
}
