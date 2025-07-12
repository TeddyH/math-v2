#!/usr/bin/env python3
"""
앱 아이콘 생성 스크립트
두뇌트레이닝: 수학 앱용 512x512px 아이콘 생성
"""

from PIL import Image, ImageDraw, ImageFont
import math
import os

def create_app_icon():
    # 아이콘 크기 설정
    size = 512
    
    # 이미지 생성 (투명 배경)
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # 색상 정의
    bg_color = (70, 130, 180)  # 스틸 블루
    accent_color = (255, 215, 0)  # 골드
    white = (255, 255, 255)
    dark_blue = (25, 25, 112)  # 미드나이트 블루
    light_blue = (135, 206, 235)  # 스카이 블루
    
    # 원형 배경 생성
    margin = 20
    circle_size = size - 2 * margin
    draw.ellipse([margin, margin, margin + circle_size, margin + circle_size], 
                 fill=bg_color, outline=dark_blue, width=8)
    
    # 내부 원형 그라데이션 효과
    inner_margin = 40
    inner_size = size - 2 * inner_margin
    draw.ellipse([inner_margin, inner_margin, inner_margin + inner_size, inner_margin + inner_size], 
                 fill=light_blue, outline=None)
    
    # 중앙 원형 수학 영역
    center_margin = 80
    center_size = size - 2 * center_margin
    draw.ellipse([center_margin, center_margin, center_margin + center_size, center_margin + center_size], 
                 fill=white, outline=dark_blue, width=4)
    
    # 수학 기호들 그리기
    center_x, center_y = size // 2, size // 2
    
    # 큰 수학 기호들
    font_size = 80
    try:
        # macOS 시스템 폰트 경로들 시도
        font_paths = [
            "/System/Library/Fonts/Arial.ttf",
            "/System/Library/Fonts/Helvetica.ttc",
            "/System/Library/Fonts/Arial Unicode.ttf",
            "/Library/Fonts/Arial.ttf"
        ]
        
        font = None
        small_font = None
        
        for font_path in font_paths:
            try:
                font = ImageFont.truetype(font_path, font_size)
                small_font = ImageFont.truetype(font_path, 60)
                break
            except:
                continue
                
        if font is None:
            raise Exception("No suitable font found")
            
    except:
        # 기본 폰트 사용
        font = ImageFont.load_default()
        small_font = ImageFont.load_default()
    
    # 중앙에 계산식 그리기
    equation = "2+3=5"
    bbox = draw.textbbox((0, 0), equation, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    
    text_x = center_x - text_width // 2
    text_y = center_y - text_height // 2
    
    # 텍스트 그림자 효과
    shadow_offset = 3
    draw.text((text_x + shadow_offset, text_y + shadow_offset), equation, 
              fill=(0, 0, 0, 100), font=font)
    
    # 메인 텍스트
    draw.text((text_x, text_y), equation, fill=dark_blue, font=font)
    
    # 비행기 아이콘 그리기 (우상단)
    plane_x, plane_y = center_x + 80, center_y - 80
    
    # 비행기 몸체
    plane_body = [
        (plane_x, plane_y - 15),
        (plane_x + 5, plane_y - 10),
        (plane_x + 5, plane_y + 15),
        (plane_x - 5, plane_y + 15),
        (plane_x - 5, plane_y - 10)
    ]
    draw.polygon(plane_body, fill=accent_color, outline=dark_blue, width=2)
    
    # 비행기 날개
    wing_left = [
        (plane_x - 20, plane_y),
        (plane_x - 5, plane_y - 5),
        (plane_x - 5, plane_y + 5)
    ]
    wing_right = [
        (plane_x + 20, plane_y),
        (plane_x + 5, plane_y - 5),
        (plane_x + 5, plane_y + 5)
    ]
    draw.polygon(wing_left, fill=accent_color, outline=dark_blue, width=2)
    draw.polygon(wing_right, fill=accent_color, outline=dark_blue, width=2)
    
    # 두뇌 아이콘 (좌하단)
    brain_x, brain_y = center_x - 80, center_y + 60
    
    # 두뇌 모양 (간단한 원형들로 구성)
    brain_size = 25
    draw.ellipse([brain_x - brain_size, brain_y - brain_size//2, 
                  brain_x + brain_size, brain_y + brain_size//2], 
                 fill=accent_color, outline=dark_blue, width=2)
    
    # 두뇌 세부 선들
    for i in range(3):
        y_offset = (i - 1) * 8
        draw.arc([brain_x - brain_size + 5, brain_y - brain_size//2 + y_offset, 
                  brain_x + brain_size - 5, brain_y + brain_size//2 + y_offset], 
                 0, 180, fill=dark_blue, width=2)
    
    # 작은 수학 기호들을 주변에 배치
    symbols = ['+', '-', '×', '÷', '=']
    angles = [0, 72, 144, 216, 288]  # 5개 기호를 원형으로 배치
    
    for i, (symbol, angle) in enumerate(zip(symbols, angles)):
        rad = math.radians(angle)
        symbol_x = center_x + int(140 * math.cos(rad))
        symbol_y = center_y + int(140 * math.sin(rad))
        
        # 기호 배경 원
        symbol_bg_size = 25
        draw.ellipse([symbol_x - symbol_bg_size, symbol_y - symbol_bg_size,
                      symbol_x + symbol_bg_size, symbol_y + symbol_bg_size],
                     fill=accent_color, outline=dark_blue, width=2)
        
        # 기호 텍스트
        bbox = draw.textbbox((0, 0), symbol, font=small_font)
        text_width = bbox[2] - bbox[0]
        text_height = bbox[3] - bbox[1]
        
        draw.text((symbol_x - text_width//2, symbol_y - text_height//2), 
                  symbol, fill=dark_blue, font=small_font)
    
    # 최종 테두리 강조
    draw.ellipse([5, 5, size-5, size-5], fill=None, outline=dark_blue, width=3)
    
    return img

def main():
    print("앱 아이콘 생성 중...")
    
    # 아이콘 생성
    icon = create_app_icon()
    
    # 저장 경로 설정
    output_dir = "app_icons"
    os.makedirs(output_dir, exist_ok=True)
    
    # PNG 형식으로 저장 (투명 배경 지원)
    png_path = os.path.join(output_dir, "app_icon_512x512.png")
    icon.save(png_path, "PNG", optimize=True)
    
    # JPEG 형식으로도 저장 (흰색 배경 추가)
    jpg_icon = Image.new('RGB', (512, 512), 'white')
    jpg_icon.paste(icon, (0, 0), icon)
    jpg_path = os.path.join(output_dir, "app_icon_512x512.jpg")
    jpg_icon.save(jpg_path, "JPEG", quality=95, optimize=True)
    
    # 파일 크기 확인
    png_size = os.path.getsize(png_path)
    jpg_size = os.path.getsize(jpg_path)
    
    print(f"✅ 앱 아이콘 생성 완료!")
    print(f"📁 PNG: {png_path} ({png_size/1024:.1f}KB)")
    print(f"📁 JPEG: {jpg_path} ({jpg_size/1024:.1f}KB)")
    
    if png_size > 1024*1024:
        print("⚠️  PNG 파일이 1MB를 초과합니다. JPEG 버전을 사용하세요.")
    elif jpg_size > 1024*1024:
        print("⚠️  JPEG 파일이 1MB를 초과합니다. 품질을 조정해야 합니다.")
    else:
        print("✅ 파일 크기가 1MB 이하입니다.")
    
    print("\n🎯 아이콘 특징:")
    print("• 크기: 512x512px")
    print("• 두뇌트레이닝 + 수학 테마")
    print("• 파란색 계열의 교육적 색상")
    print("• 비행기와 수학 기호 조합")
    print("• 원형 디자인으로 모던한 느낌")

if __name__ == "__main__":
    main()
