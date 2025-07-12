import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedAirplane extends StatefulWidget {
  final double size;
  final bool isFlashing;
  final Color flashingColor;
  final Color normalColor;
  final String type; // 'airplane', 'rocket', 'helicopter'

  const AnimatedAirplane({
    Key? key,
    this.size = 50.0,
    this.isFlashing = false,
    this.flashingColor = Colors.green,
    this.normalColor = Colors.blue,
    this.type = 'airplane',
  }) : super(key: key);

  @override
  State<AnimatedAirplane> createState() => _AnimatedAirplaneState();
}

class _AnimatedAirplaneState extends State<AnimatedAirplane>
    with TickerProviderStateMixin {
  late AnimationController _propellerController;
  late AnimationController _hoverController;
  late Animation<double> _propellerAnimation;
  late Animation<double> _hoverAnimation;

  @override
  void initState() {
    super.initState();
    
    // 프로펠러 회전 애니메이션
    _propellerController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _propellerAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_propellerController);

    // 부드러운 호버 효과
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _hoverAnimation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));

    // 애니메이션 시작
    _propellerController.repeat();
    _hoverController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _propellerController.dispose();
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_propellerAnimation, _hoverAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _hoverAnimation.value),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.size / 2),
              boxShadow: widget.isFlashing ? [
                BoxShadow(
                  color: widget.flashingColor.withOpacity(0.6),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ] : null,
            ),
            child: CustomPaint(
              painter: _AirplanePainter(
                type: widget.type,
                propellerRotation: _propellerAnimation.value,
                color: widget.isFlashing ? widget.flashingColor : widget.normalColor,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AirplanePainter extends CustomPainter {
  final String type;
  final double propellerRotation;
  final Color color;

  _AirplanePainter({
    required this.type,
    required this.propellerRotation,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);

    switch (type) {
      case 'airplane':
        _drawAirplane(canvas, size, paint, strokePaint, center);
        break;
      case 'rocket':
        _drawRocket(canvas, size, paint, strokePaint, center);
        break;
      case 'helicopter':
        _drawHelicopter(canvas, size, paint, strokePaint, center);
        break;
    }
  }

  void _drawAirplane(Canvas canvas, Size size, Paint paint, Paint strokePaint, Offset center) {
    // 비행기 몸체 (흰색/회색)
    final bodyPaint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.fill;
    
    final bodyStrokePaint = Paint()
      ..color = Colors.grey[400]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // 메인 몸체
    final bodyRect = RRect.fromLTRBR(
      center.dx - 5, center.dy - 20,
      center.dx + 5, center.dy + 25,
      const Radius.circular(5),
    );
    canvas.drawRRect(bodyRect, bodyPaint);
    canvas.drawRRect(bodyRect, bodyStrokePaint);

    // 주 날개 (파란색)
    final wingPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    
    final wingStrokePaint = Paint()
      ..color = Colors.blue[700]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // 주 날개 (좌측)
    final leftWingRect = RRect.fromLTRBR(
      center.dx - 30, center.dy + 2,
      center.dx - 5, center.dy + 8,
      const Radius.circular(3),
    );
    canvas.drawRRect(leftWingRect, wingPaint);
    canvas.drawRRect(leftWingRect, wingStrokePaint);

    // 주 날개 (우측)
    final rightWingRect = RRect.fromLTRBR(
      center.dx + 5, center.dy + 2,
      center.dx + 30, center.dy + 8,
      const Radius.circular(3),
    );
    canvas.drawRRect(rightWingRect, wingPaint);
    canvas.drawRRect(rightWingRect, wingStrokePaint);

    // 수평 꼬리 날개 (파란색)
    final tailWingRect = RRect.fromLTRBR(
      center.dx - 12, center.dy + 20,
      center.dx + 12, center.dy + 24,
      const Radius.circular(2),
    );
    canvas.drawRRect(tailWingRect, wingPaint);
    canvas.drawRRect(tailWingRect, wingStrokePaint);

    // 수직 꼬리 날개 (파란색)
    final verticalTailRect = RRect.fromLTRBR(
      center.dx - 2, center.dy + 18,
      center.dx + 2, center.dy + 30,
      const Radius.circular(2),
    );
    canvas.drawRRect(verticalTailRect, wingPaint);
    canvas.drawRRect(verticalTailRect, wingStrokePaint);

    // 조종석 창문 (파란색)
    final windowPaint = Paint()
      ..color = Colors.lightBlue[300]!
      ..style = PaintingStyle.fill;
    
    final windowRect = RRect.fromLTRBR(
      center.dx - 4, center.dy - 15,
      center.dx + 4, center.dy - 5,
      const Radius.circular(2),
    );
    canvas.drawRRect(windowRect, windowPaint);

    // 프로펠러 허브 (회색)
    final hubPaint = Paint()
      ..color = Colors.grey[600]!
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(center.dx, center.dy - 20), 3, hubPaint);

    // 프로펠러 날개 (회전)
    canvas.save();
    canvas.translate(center.dx, center.dy - 20);
    canvas.rotate(propellerRotation);
    
    final propellerPaint = Paint()
      ..color = Colors.brown[700]!
      ..style = PaintingStyle.fill;
    
    // 프로펠러 블레이드 (간단한 형태)
    final propellerRect1 = RRect.fromLTRBR(
      -1, -12,
      1, 12,
      const Radius.circular(1),
    );
    canvas.drawRRect(propellerRect1, propellerPaint);
    
    final propellerRect2 = RRect.fromLTRBR(
      -12, -1,
      12, 1,
      const Radius.circular(1),
    );
    canvas.drawRRect(propellerRect2, propellerPaint);
    
    canvas.restore();
  }

  void _drawRocket(Canvas canvas, Size size, Paint paint, Paint strokePaint, Offset center) {
    // 로켓 몸체 (중앙 정렬 조정) - 예쁜 빨간색
    final bodyPaint = Paint()
      ..color = Colors.red[400]!
      ..style = PaintingStyle.fill;
    
    final bodyStrokePaint = Paint()
      ..color = Colors.red[600]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final bodyRect = RRect.fromLTRBR(
      center.dx - 8, center.dy - 15,
      center.dx + 8, center.dy + 20,
      const Radius.circular(4),
    );
    canvas.drawRRect(bodyRect, bodyPaint);
    canvas.drawRRect(bodyRect, bodyStrokePaint);

    // 로켓 꼭대기 (더 밝은 빨간색)
    final topPaint = Paint()
      ..color = Colors.red[300]!
      ..style = PaintingStyle.fill;
    
    final topStrokePaint = Paint()
      ..color = Colors.red[500]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final topPath = Path()
      ..moveTo(center.dx - 8, center.dy - 15)
      ..lineTo(center.dx, center.dy - 25)
      ..lineTo(center.dx + 8, center.dy - 15)
      ..close();
    canvas.drawPath(topPath, topPaint);
    canvas.drawPath(topPath, topStrokePaint);

    // 로켓 날개 (파란색)
    final wingPaint = Paint()
      ..color = Colors.blue[400]!
      ..style = PaintingStyle.fill;
    
    final wingStrokePaint = Paint()
      ..color = Colors.blue[600]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final wingPath = Path()
      ..moveTo(center.dx - 8, center.dy + 10)
      ..lineTo(center.dx - 15, center.dy + 20)
      ..lineTo(center.dx - 8, center.dy + 15)
      ..close();
    canvas.drawPath(wingPath, wingPaint);
    canvas.drawPath(wingPath, wingStrokePaint);

    final wingPath2 = Path()
      ..moveTo(center.dx + 8, center.dy + 10)
      ..lineTo(center.dx + 15, center.dy + 20)
      ..lineTo(center.dx + 8, center.dy + 15)
      ..close();
    canvas.drawPath(wingPath2, wingPaint);
    canvas.drawPath(wingPath2, wingStrokePaint);

    // 창문
    final windowPaint = Paint()
      ..color = Colors.lightBlueAccent
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(center.dx, center.dy - 5), 3, windowPaint);
    canvas.drawCircle(Offset(center.dx, center.dy + 5), 3, windowPaint);

    // 애니메이션 화염 효과
    final flameOffset = propellerRotation % (2 * math.pi);
    final flameIntensity = (math.sin(flameOffset * 4) + 1) * 0.5; // 0~1 사이 값
    
    // 주 화염
    final mainFlamePaint = Paint()
      ..color = Colors.orange.withOpacity(0.8 + flameIntensity * 0.2)
      ..style = PaintingStyle.fill;
    
    final mainFlameHeight = 8 + flameIntensity * 4;
    canvas.drawRRect(
      RRect.fromLTRBR(
        center.dx - 6, center.dy + 20,
        center.dx + 6, center.dy + 20 + mainFlameHeight,
        const Radius.circular(6),
      ),
      mainFlamePaint,
    );

    // 내부 화염 (더 뜨거운 색)
    final innerFlamePaint = Paint()
      ..color = Colors.yellow.withOpacity(0.9 + flameIntensity * 0.1)
      ..style = PaintingStyle.fill;
    
    final innerFlameHeight = 6 + flameIntensity * 3;
    canvas.drawRRect(
      RRect.fromLTRBR(
        center.dx - 4, center.dy + 20,
        center.dx + 4, center.dy + 20 + innerFlameHeight,
        const Radius.circular(4),
      ),
      innerFlamePaint,
    );

    // 사이드 화염 (작은 불꽃들)
    final sideFlamePaint = Paint()
      ..color = Colors.red.withOpacity(0.7 + flameIntensity * 0.3)
      ..style = PaintingStyle.fill;
    
    final sideFlameSize = 2 + flameIntensity * 2;
    canvas.drawCircle(
      Offset(center.dx - 4, center.dy + 23 + flameIntensity * 2), 
      sideFlameSize, 
      sideFlamePaint
    );
    canvas.drawCircle(
      Offset(center.dx + 4, center.dy + 23 + flameIntensity * 2), 
      sideFlameSize, 
      sideFlamePaint
    );
    canvas.drawCircle(
      Offset(center.dx, center.dy + 25 + flameIntensity * 3), 
      sideFlameSize * 0.8, 
      sideFlamePaint
    );
  }

  void _drawHelicopter(Canvas canvas, Size size, Paint paint, Paint strokePaint, Offset center) {
    // 헬리콥터 전체를 위쪽으로 이동 (더 높이 조정)
    final adjustedCenter = Offset(center.dx, center.dy - 18);
    
    // 헬리콥터 몸체 (중앙 정렬 조정) - 예쁜 초록색
    final bodyPaint = Paint()
      ..color = Colors.green[400]!
      ..style = PaintingStyle.fill;
    
    final bodyStrokePaint = Paint()
      ..color = Colors.green[600]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final bodyRect = RRect.fromLTRBR(
      adjustedCenter.dx - 8, adjustedCenter.dy - 10,
      adjustedCenter.dx + 8, adjustedCenter.dy + 25,
      const Radius.circular(8),
    );
    canvas.drawRRect(bodyRect, bodyPaint);
    canvas.drawRRect(bodyRect, bodyStrokePaint);

    // 조종실 (위쪽 부분) - 더 밝은 초록색
    final cockpitPaint = Paint()
      ..color = Colors.green[300]!
      ..style = PaintingStyle.fill;
    
    final cockpitRect = RRect.fromLTRBR(
      adjustedCenter.dx - 8, adjustedCenter.dy - 10,
      adjustedCenter.dx + 8, adjustedCenter.dy + 10,
      const Radius.circular(8),
    );
    canvas.drawRRect(cockpitRect, cockpitPaint);
    canvas.drawRRect(cockpitRect, bodyStrokePaint);

    // 창문들 추가
    final windowPaint = Paint()
      ..color = Colors.lightBlueAccent
      ..style = PaintingStyle.fill;
    
    // 전면 창문
    canvas.drawRRect(
      RRect.fromLTRBR(
        adjustedCenter.dx - 6, adjustedCenter.dy - 7,
        adjustedCenter.dx + 6, adjustedCenter.dy,
        const Radius.circular(3),
      ),
      windowPaint,
    );
    
    // 좌측 창문
    canvas.drawRRect(
      RRect.fromLTRBR(
        adjustedCenter.dx - 8, adjustedCenter.dy - 3,
        adjustedCenter.dx - 2, adjustedCenter.dy + 3,
        const Radius.circular(2),
      ),
      windowPaint,
    );
    
    // 우측 창문
    canvas.drawRRect(
      RRect.fromLTRBR(
        adjustedCenter.dx + 2, adjustedCenter.dy - 3,
        adjustedCenter.dx + 8, adjustedCenter.dy + 3,
        const Radius.circular(2),
      ),
      windowPaint,
    );

    // 꼬리 (뒤쪽으로 연장) - 헬기 몸체와 같은 색
    final tailPaint = Paint()
      ..color = Colors.green[400]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawLine(Offset(adjustedCenter.dx, adjustedCenter.dy + 25), Offset(adjustedCenter.dx, adjustedCenter.dy + 45), tailPaint);

    // 꼬리 로터 (회전) - 수직 배치
    canvas.save();
    canvas.translate(adjustedCenter.dx, adjustedCenter.dy + 45);
    canvas.rotate(propellerRotation * 2);
    
    final tailRotorPaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawLine(const Offset(-6, 0), const Offset(6, 0), tailRotorPaint);
    canvas.restore();

    // 메인 로터 (회전) - 헬기 몸체 중앙에 배치
    canvas.save();
    canvas.translate(adjustedCenter.dx, adjustedCenter.dy + 8);
    canvas.rotate(propellerRotation);
    
    final mainRotorPaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    canvas.drawLine(const Offset(-25, 0), const Offset(25, 0), mainRotorPaint);
    canvas.drawLine(const Offset(0, -25), const Offset(0, 25), mainRotorPaint);
    canvas.restore();

    // 로터 축 - 헬기 몸체와 같은 색
    final rotorAxisPaint = Paint()
      ..color = Colors.green[600]!
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(adjustedCenter.dx, adjustedCenter.dy + 8), 2, rotorAxisPaint);
    
    // 랜딩 스키드 (착륙 장치)
    final skidPaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawLine(Offset(adjustedCenter.dx - 12, adjustedCenter.dy + 23), Offset(adjustedCenter.dx + 12, adjustedCenter.dy + 23), skidPaint);
    canvas.drawLine(Offset(adjustedCenter.dx - 12, adjustedCenter.dy + 27), Offset(adjustedCenter.dx + 12, adjustedCenter.dy + 27), skidPaint);
    canvas.drawLine(Offset(adjustedCenter.dx - 12, adjustedCenter.dy + 23), Offset(adjustedCenter.dx - 12, adjustedCenter.dy + 27), skidPaint);
    canvas.drawLine(Offset(adjustedCenter.dx + 12, adjustedCenter.dy + 23), Offset(adjustedCenter.dx + 12, adjustedCenter.dy + 27), skidPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
