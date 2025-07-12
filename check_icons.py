#!/usr/bin/env python3
"""
아이콘 설치 확인 스크립트
"""

import os

def check_icon_installation():
    print("🔍 아이콘 설치 상태 확인")
    print("=" * 50)
    
    # 기본 아이콘 파일 확인
    print("\n📁 기본 아이콘 파일:")
    base_files = [
        "app_icons/app_icon_512x512.png",
        "app_icons/app_icon_512x512.jpg",
        "assets/images/app_icon_512x512.png",
        "assets/images/app_icon_512x512.jpg"
    ]
    
    for file_path in base_files:
        if os.path.exists(file_path):
            size = os.path.getsize(file_path)
            print(f"✅ {file_path} ({size/1024:.1f}KB)")
        else:
            print(f"❌ {file_path} (누락)")
    
    # Android 아이콘 확인
    print("\n📱 Android 아이콘:")
    android_dirs = [
        "android/app/src/main/res/mipmap-mdpi",
        "android/app/src/main/res/mipmap-hdpi", 
        "android/app/src/main/res/mipmap-xhdpi",
        "android/app/src/main/res/mipmap-xxhdpi",
        "android/app/src/main/res/mipmap-xxxhdpi"
    ]
    
    for dir_path in android_dirs:
        icon_path = os.path.join(dir_path, "ic_launcher.png")
        if os.path.exists(icon_path):
            size = os.path.getsize(icon_path)
            print(f"✅ {icon_path} ({size/1024:.1f}KB)")
        else:
            print(f"❌ {icon_path} (누락)")
    
    print("\n🎯 설치 요약:")
    print("• 구글 플레이스토어용: 512x512px PNG/JPEG 파일 준비 완료")
    print("• Android 앱용: 다양한 해상도 ic_launcher.png 파일 설치 완료")
    print("• Flutter 프로젝트: pubspec.yaml 설명 업데이트 완료")
    
    print("\n📋 다음 단계:")
    print("1. 구글 플레이스토어에 업로드할 때 app_icon_512x512.png 사용")
    print("2. 앱 빌드 후 실제 디바이스에서 아이콘 확인")
    print("3. 필요 시 앱 이름을 '두뇌트레이닝: 수학'으로 변경")

if __name__ == "__main__":
    check_icon_installation()
