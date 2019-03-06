import QtQuick 2.12
import QtQuick.Window 2.12

Window {
    visible: true;
    width: container.width + 10;
    height: container.height + (canvas_quadratic.visible ? 175 : 200);
    title: canvas_quadratic.visible ? qsTr("二次贝塞尔曲线编辑器") : qsTr("三次贝塞尔曲线编辑器");

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
                onInputEditingFinished: function() {
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
                onInputEditingFinished: function() {
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
            anchors.horizontalCenter: parent.horizontalCenter;
            anchors.top: item_canvas_size_setting.bottom;
            anchors.topMargin: 10;
            width: 210;
            height: 30;
            hint.text: canvas_quadratic.visible ? qsTr("切换为三次贝塞尔曲线") : qsTr("切换为二次贝塞尔曲线");
            hint.font.pixelSize: 20;
            onButtonClick: function() {
                canvas_quadratic.visible = !canvas_quadratic.visible;
                if (canvas_quadratic.visible) {
                    input_start_point_x.inputText = canvas_quadratic.start_point_x;
                    input_start_point_y.inputText = canvas_quadratic.start_point_y;
                    input_control_point_1_x.inputText = canvas_quadratic.control_point_x;
                    input_control_point_1_y.inputText = canvas_quadratic.control_point_y;
                    input_control_point_2_x.inputFocus = false;
                    input_control_point_2_y.inputFocus = false;
                    input_end_point_x.inputText = canvas_quadratic.end_point_x;
                    input_end_point_y.inputText = canvas_quadratic.end_point_y;
                } else {
                    input_start_point_x.inputText = canvas_cubic.start_point_x;
                    input_start_point_y.inputText = canvas_cubic.start_point_y;
                    input_control_point_1_x.inputText = canvas_cubic.control_point_1_x;
                    input_control_point_1_y.inputText = canvas_cubic.control_point_1_y;
                    input_control_point_2_x.inputText = canvas_cubic.control_point_2_x;
                    input_control_point_2_y.inputText = canvas_cubic.control_point_2_y;
                    input_end_point_x.inputText = canvas_cubic.end_point_x;
                    input_end_point_y.inputText = canvas_cubic.end_point_y;
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
                property int start_point_x: 0;
                property int start_point_y: self.height;
                property int control_point_1_x: (self.width / 2) - 100;
                property int control_point_1_y: (self.height / 2) + 50;
                property int control_point_2_x: (self.width / 2) + 100;
                property int control_point_2_y: (self.height / 2) - 50;
                property int end_point_x: self.width;
                property int end_point_y: 0;
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
                    /* 坐标偏移计算 */
                    start_point_x = self.clamp(start_point_x, 0, self.width);
                    start_point_y = self.clamp(start_point_y, 0, self.height);
                    control_point_1_x = self.clamp(control_point_1_x, 0, self.width);
                    control_point_1_y = self.clamp(control_point_1_y, 0, self.height);
                    control_point_2_x = self.clamp(control_point_2_x, 0, self.width);
                    control_point_2_y = self.clamp(control_point_2_y, 0, self.height);
                    end_point_x = self.clamp(end_point_x, 0, self.width);
                    end_point_y = self.clamp(end_point_y, 0, self.height);
                    var startX = self.margin + start_point_x;
                    var startY = self.margin + start_point_y;
                    var control1X = self.margin + control_point_1_x;
                    var control1Y = self.margin + control_point_1_y;
                    var control2X = self.margin + control_point_2_x;
                    var control2Y = self.margin + control_point_2_y;
                    var endX = self.margin + end_point_x;
                    var endY = self.margin + end_point_y;
                    /* 绘制曲线 */
                    self.drawCubicBezierCruve(ctx, startX, startY, control1X, control1Y, control2X, control2Y, endX, endY, self.curve_width, "#AAAAAA");
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

            /* 二次贝塞尔曲线画布 */
            Canvas {
                property int start_point_x: 0;
                property int start_point_y: self.height;
                property int control_point_x: self.width / 2;
                property int control_point_y: self.height / 2;
                property int end_point_x: self.width;
                property int end_point_y: 0;
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
                    /* 坐标偏移计算 */
                    start_point_x = self.clamp(start_point_x, 0, self.width);
                    start_point_y = self.clamp(start_point_y, 0, self.height);
                    control_point_x = self.clamp(control_point_x, 0, self.width);
                    control_point_y = self.clamp(control_point_y, 0, self.height);
                    end_point_x = self.clamp(end_point_x, 0, self.width);
                    end_point_y = self.clamp(end_point_y, 0, self.height);
                    var startX = self.margin + start_point_x;
                    var startY = self.margin + start_point_y;
                    var controlX = self.margin + control_point_x;
                    var controlY = self.margin + control_point_y;
                    var endX = self.margin + end_point_x;
                    var endY = self.margin + end_point_y;
                    /* 绘制曲线 */
                    self.drawQuadraticBezierCruve(ctx, startX, startY, controlX, controlY, endX, endY, self.curve_width, "#AAAAAA");
                    /* 绘制起点 */
                    self.drawCircle(ctx, startX, startY, self.point_radius, "#FF0000");
                    /* 绘制控制点 */
                    self.drawCircle(ctx, controlX, controlY, self.point_radius, "#006400");
                    /* 绘制终点 */
                    self.drawCircle(ctx, endX, endY, self.point_radius, "#0000FF");
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
                /* 绘制圆点 */
                function drawCircle(ctx, x, y, radius, style) {
                    ctx.beginPath();
                    ctx.arc(x, y, radius, 0, 360, true);
                    ctx.closePath();
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
                property int point_type: 0; /* 控制点类型:1.起点,2.控制点1,3.控制点2,4.终点 */
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
                    if (canvas_quadratic.visible) { /* 二次贝塞尔曲线 */
                        if (self.isPointInCircle(canvas_quadratic.start_point_x, canvas_quadratic.start_point_y, self.point_radius, mX, mY)) {  /* 点击了起点 */
                            point_type = 1;
                        } else if (self.isPointInCircle(canvas_quadratic.control_point_x, canvas_quadratic.control_point_y, self.point_radius, mX, mY)) {  /* 点击了控制点 */
                            point_type = 2;
                        } else if (self.isPointInCircle(canvas_quadratic.end_point_x, canvas_quadratic.end_point_y, self.point_radius, mX, mY)) {  /* 点击了终点 */
                            point_type = 4;
                        }
                    } else {  /* 三次贝塞尔曲线 */
                        if (self.isPointInCircle(canvas_cubic.start_point_x, canvas_cubic.start_point_y, self.point_radius, mX, mY)) {  /* 点击了起点 */
                            point_type = 1;
                        } else if (self.isPointInCircle(canvas_cubic.control_point_1_x, canvas_cubic.control_point_1_y, self.point_radius, mX, mY)) {  /* 点击了控制点1 */
                            point_type = 2;
                        } else if (self.isPointInCircle(canvas_cubic.control_point_2_x, canvas_cubic.control_point_2_y, self.point_radius, mX, mY)) {  /* 点击了控制点2 */
                            point_type = 3;
                        } else if (self.isPointInCircle(canvas_cubic.end_point_x, canvas_cubic.end_point_y, self.point_radius, mX, mY)) {  /* 点击了终点 */
                            point_type = 4;
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
                        if (1 === point_type) {
                            canvas_quadratic.start_point_x = mX;
                            input_start_point_x.inputText = mX;
                        } else if (2 === point_type) {
                            canvas_quadratic.control_point_x = mX;
                            input_control_point_1_x.inputText = mX;
                        } else if (4 === point_type) {
                            canvas_quadratic.end_point_x = mX;
                            input_end_point_x.inputText = mX;
                        }
                    } else {  /* 三次贝塞尔曲线 */
                        if (1 === point_type) {
                            canvas_cubic.start_point_x = mX;
                            input_start_point_x.inputText = mX;
                        } else if (2 === point_type) {
                            canvas_cubic.control_point_1_x = mX;
                            input_control_point_1_x.inputText = mX;
                        } else if (3 === point_type) {
                            canvas_cubic.control_point_2_x = mX;
                            input_control_point_2_x.inputText = mX;
                        } else if (4 === point_type) {
                            canvas_cubic.end_point_x = mX;
                            input_end_point_x.inputText = mX;
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
                        if (1 === point_type) {
                            canvas_quadratic.start_point_y = mY;
                            input_start_point_y.inputText = mY;
                        } else if (2 === point_type) {
                            canvas_quadratic.control_point_y = mY;
                            input_control_point_1_y.inputText = mY;
                        } else if (4 === point_type) {
                            canvas_quadratic.end_point_y = mY;
                            input_end_point_y.inputText = mY;
                        }
                    } else {  /* 三次贝塞尔曲线 */
                        if (1 === point_type) {
                            canvas_cubic.start_point_y = mY;
                            input_start_point_y.inputText = mY;
                        } else if (2 === point_type) {
                            canvas_cubic.control_point_1_y = mY;
                            input_control_point_1_y.inputText = mY;
                        } else if (3 === point_type) {
                            canvas_cubic.control_point_2_y = mY;
                            input_control_point_2_y.inputText = mY;
                        } else if (4 === point_type) {
                            canvas_cubic.end_point_y = mY;
                            input_end_point_y.inputText = mY;
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

        /* 起点坐标 */
        Text {
            id: text_start_point_title;
            anchors.left: container.left;
            anchors.leftMargin: (container.width - (input_start_point_y.x + input_start_point_y.width - text_start_point_title.x)) / 2;
            anchors.top: text_corner_left_bottom.bottom;
            anchors.topMargin: 10;
            text: qsTr("起点:");
            color: "#FF0000";
            font.pixelSize: 20;
            font.bold: true;
        }

        XTextInput {
            id: input_start_point_x;
            anchors.left: text_start_point_title.left;
            anchors.leftMargin: 90;
            anchors.top: text_corner_left_bottom.bottom;
            anchors.topMargin: 10;
            inputValidator: RegExpValidator {   /* 数字 */
                regExp: /^[0-9]{0,}$/;
            }
            inputText: canvas_quadratic.visible ? canvas_quadratic.start_point_x : canvas_cubic.start_point_x;
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
                inputText = x.toString();
                if (canvas_quadratic.visible) {
                    canvas_quadratic.start_point_x = x;
                } else {
                    canvas_cubic.start_point_x = x;
                }
            }
        }

        XTextInput {
            id: input_start_point_y;
            anchors.left: input_start_point_x.right;
            anchors.leftMargin: 5;
            anchors.top: text_corner_left_bottom.bottom;
            anchors.topMargin: 10;
            inputValidator: RegExpValidator {   /* 数字 */
                regExp: /^[0-9]{0,}$/;
            }
            inputText: canvas_quadratic.visible ? canvas_quadratic.start_point_y : canvas_cubic.start_point_y;
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
                inputText = y.toString();
                if (canvas_quadratic.visible) {
                    canvas_quadratic.start_point_y = y;
                } else {
                    canvas_cubic.start_point_y = y;
                }
            }
        }

        /* 控制点1坐标 */
        Text {
            id: text_control_point_1_title;
            anchors.left: container.left;
            anchors.leftMargin: text_start_point_title.anchors.leftMargin;
            anchors.top: text_start_point_title.bottom;
            anchors.topMargin: 5;
            text: canvas_quadratic.visible ? qsTr("控制点:") : qsTr("控制点1:");
            color: "#006400";
            font.pixelSize: 20;
            font.bold: true;
        }

        XTextInput {
            id: input_control_point_1_x;
            anchors.left: text_control_point_1_title.left;
            anchors.leftMargin: 90;
            anchors.top: text_start_point_title.bottom;
            anchors.topMargin: 5;
            inputValidator: RegExpValidator {   /* 数字 */
                regExp: /^[0-9]{0,}$/;
            }
            inputText: canvas_quadratic.visible ? canvas_quadratic.control_point_x : canvas_cubic.control_point_1_x;
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
                inputText = x.toString();
                if (canvas_quadratic.visible) {
                    canvas_quadratic.control_point_x = x;
                } else {
                    canvas_cubic.control_point_1_x = x;
                }
            }
        }

        XTextInput {
            id: input_control_point_1_y;
            anchors.left: input_control_point_1_x.right;
            anchors.leftMargin: 5;
            anchors.top: text_start_point_title.bottom;
            anchors.topMargin: 5;
            inputValidator: RegExpValidator {   /* 数字 */
                regExp: /^[0-9]{0,}$/;
            }
            inputText: canvas_quadratic.visible ? canvas_quadratic.control_point_y : canvas_cubic.control_point_1_y;
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
                inputText = y.toString();
                if (canvas_quadratic.visible) {
                    canvas_quadratic.control_point_y = y;
                } else {
                    canvas_cubic.control_point_1_y = y;
                }
            }
        }

        /* 控制点2坐标 */
        Text {
            id: text_control_point_2_title;
            anchors.left: container.left;
            anchors.leftMargin: text_start_point_title.anchors.leftMargin;
            anchors.top: text_control_point_1_title.bottom;
            anchors.topMargin: 5;
            text: qsTr("控制点2:");
            color: "#00868B";
            font.pixelSize: 20;
            font.bold: true;
            visible: canvas_quadratic.visible ? false : true;
        }

        XTextInput {
            id: input_control_point_2_x;
            anchors.left: text_control_point_2_title.left;
            anchors.leftMargin: 90;
            anchors.top: text_control_point_1_title.bottom;
            anchors.topMargin: 5;
            inputValidator: RegExpValidator {   /* 数字 */
                regExp: /^[0-9]{0,}$/;
            }
            inputText: canvas_cubic.control_point_2_x;
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
                inputText = x.toString();
                canvas_cubic.control_point_2_x = x;
            }
        }

        XTextInput {
            id: input_control_point_2_y;
            anchors.left: input_control_point_2_x.right;
            anchors.leftMargin: 5;
            anchors.top: text_control_point_1_title.bottom;
            anchors.topMargin: 5;
            inputValidator: RegExpValidator {   /* 数字 */
                regExp: /^[0-9]{0,}$/;
            }
            inputText: canvas_cubic.control_point_2_y;
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
                inputText = y.toString();
                canvas_cubic.control_point_2_y = y;
            }
        }

        /* 终点坐标 */
        Text {
            id: text_end_point_title;
            anchors.left: container.left;
            anchors.leftMargin: text_start_point_title.anchors.leftMargin;
            anchors.top: canvas_quadratic.visible ? text_control_point_1_title.bottom : text_control_point_2_title.bottom;
            anchors.topMargin: 5;
            text: qsTr("终点:");
            color: "#0000FF";
            font.pixelSize: 20;
            font.bold: true;
        }

        XTextInput {
            id: input_end_point_x;
            anchors.left: text_end_point_title.left;
            anchors.leftMargin: 90;
            anchors.top: canvas_quadratic.visible ? text_control_point_1_title.bottom : text_control_point_2_title.bottom;
            anchors.topMargin: 5;
            inputValidator: RegExpValidator {   /* 数字 */
                regExp: /^[0-9]{0,}$/;
            }
            inputText: canvas_quadratic.visible ? canvas_quadratic.end_point_x : canvas_cubic.end_point_x;
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
                inputText = x.toString();
                if (canvas_quadratic.visible) {
                    canvas_quadratic.end_point_x = x;
                } else {
                    canvas_cubic.end_point_x = x;
                }
            }
        }

        XTextInput {
            id: input_end_point_y;
            anchors.left: input_end_point_x.right;
            anchors.leftMargin: 5;
            anchors.top: canvas_quadratic.visible ? text_control_point_1_title.bottom : text_control_point_2_title.bottom;
            anchors.topMargin: 5;
            inputValidator: RegExpValidator {   /* 数字 */
                regExp: /^[0-9]{0,}$/;
            }
            inputText: canvas_quadratic.visible ? canvas_quadratic.end_point_y : canvas_cubic.end_point_y;
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
                inputText = y.toString();
                if (canvas_quadratic.visible) {
                    canvas_quadratic.end_point_y = y;
                } else {
                    canvas_cubic.end_point_y = y;
                }
            }
        }
    }
}
