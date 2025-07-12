#!/usr/bin/env python3
"""
Android 아이콘 생성 스크립트
다양한 해상도의 Android 아이콘들을 생성합니다.
"""

from PIL import Image
import os

def create_android_icons():
    # 기본 아이콘 로드
    base_icon = Image.open("app_icons/app_icon_512x512.png")
    
    # Android 아이콘 크기 정의
    android_sizes = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192
    }
    
    # Android 아이콘 디렉토리 생성
    android_dir = "android_icons"
    os.makedirs(android_dir, exist_ok=True)
    
    print("Android 아이콘 생성 중...")
    
    for folder, size in android_sizes.items():
        # 폴더 생성
        folder_path = os.path.join(android_dir, folder)
        os.makedirs(folder_path, exist_ok=True)
        
        # 아이콘 리사이즈
        resized_icon = base_icon.resize((size, size), Image.Resampling.LANCZOS)
        
        # ic_launcher.png로 저장
        icon_path = os.path.join(folder_path, "ic_launcher.png")
        resized_icon.save(icon_path, "PNG", optimize=True)
        
        print(f"✅ {folder}/ic_launcher.png ({size}x{size}px)")
    
    print("\n🎯 Android 아이콘 생성 완료!")
    print("📁 생성된 폴더: android_icons/")
    print("📱 각 mipmap 폴더의 ic_launcher.png 파일들을")
    print("   android/app/src/main/res/ 아래의 해당 폴더에 복사하세요.")

if __name__ == "__main__":
    create_android_icons()
