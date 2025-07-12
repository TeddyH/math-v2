#!/bin/bash
# 구글 플레이스토어 배포 준비 스크립트
# 두뇌트레이닝: 수학 앱 배포 가이드

echo "🚀 구글 플레이스토어 배포 준비 시작"
echo "======================================"

# 1. 앱 정보 확인
echo "📱 1. 앱 정보 확인"
echo "앱 이름: 두뇌트레이닝: 수학"
echo "패키지 ID: com.tenspoon.math_training"
echo "버전: $(grep 'version:' pubspec.yaml | cut -d' ' -f2)"
echo ""

# 2. 필요한 파일들 확인
echo "📁 2. 필요한 파일들 확인"
echo "✅ 앱 아이콘 확인"
if [ -f "android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png" ]; then
    echo "   ✅ 앱 아이콘 설치됨"
else
    echo "   ❌ 앱 아이콘 누락"
fi

echo ""
echo "📋 3. 다음 단계 안내"
echo "아래 명령어들을 순서대로 실행하세요:"
echo ""
echo "1️⃣ 앱 이름 한글로 변경 (선택사항)"
echo "2️⃣ 키스토어 생성 (릴리즈 서명용)"
echo "3️⃣ 빌드 설정 업데이트"
echo "4️⃣ App Bundle 빌드"
echo "5️⃣ 플레이스토어 업로드"
echo ""
echo "🎯 준비 완료! 다음 단계를 진행하세요."
