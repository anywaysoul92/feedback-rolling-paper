# 접속 주소를 QR 코드 이미지(qr.png)로 만드는 스크립트. 사용법: python make_qr.py https://아이디.github.io/저장소이름/
# 설치가 필요하면 먼저: pip install "qrcode[pil]"
import sys
import qrcode

if len(sys.argv) < 2:
    sys.exit("사용법: python make_qr.py https://아이디.github.io/저장소이름/")

url = sys.argv[1]
qr = qrcode.QRCode(error_correction=qrcode.constants.ERROR_CORRECT_M, box_size=16, border=4)
qr.add_data(url)
qr.make(fit=True)
qr.make_image(fill_color="black", back_color="white").save("qr.png")
print("qr.png 생성 완료:", url)
