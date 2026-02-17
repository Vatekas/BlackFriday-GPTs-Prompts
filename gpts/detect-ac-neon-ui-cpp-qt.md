# Detect.AC Neon UI (C++ / Qt)

Berikut contoh UI C++ (Qt Widgets) untuk tampilan seperti screenshot: tema gelap, teks hijau neon, frame "scanner", dan input access code.

## main.cpp

```cpp
#include <QApplication>
#include <QWidget>
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QLabel>
#include <QLineEdit>
#include <QFrame>
#include <QPushButton>
#include <QGraphicsDropShadowEffect>

static QString neon = "#00ff66";
static QString dark = "#02070b";

int main(int argc, char *argv[]) {
    QApplication app(argc, argv);

    QWidget window;
    window.setWindowTitle("DETECT.AC");
    window.resize(720, 540);

    window.setStyleSheet(QString(R"(
        QWidget {
            background-color: %1;
            color: %2;
            font-family: Consolas, 'Courier New', monospace;
        }
        QLabel#title {
            font-size: 52px;
            font-weight: 700;
            letter-spacing: 2px;
        }
        QLabel#subtitle {
            font-size: 16px;
            color: #1bcf66;
        }
        QFrame#scanBox {
            border: 1px solid #0f5f35;
            border-radius: 2px;
            background-color: rgba(0, 0, 0, 0.25);
        }
        QLineEdit {
            border: 1px solid #0f5f35;
            background: transparent;
            color: %2;
            padding: 12px;
            font-size: 17px;
        }
        QPushButton {
            border: 1px solid #1bcf66;
            color: %2;
            background: transparent;
            padding: 10px 16px;
            font-size: 15px;
        }
        QPushButton:hover {
            background: rgba(0,255,102,0.12);
        }
    )").arg(dark, neon));

    auto *root = new QVBoxLayout(&window);
    root->setContentsMargins(36, 24, 36, 24);
    root->setSpacing(16);

    auto *topLabel = new QLabel("VIBECODED FREE DETECT.AC SCANNER");
    topLabel->setStyleSheet("font-size: 11px; color: #0ba855;");
    root->addWidget(topLabel, 0, Qt::AlignLeft);

    auto *title = new QLabel("DETECT.AC");
    title->setObjectName("title");
    root->addWidget(title, 0, Qt::AlignHCenter);

    auto *subtitle = new QLabel("Anti-Cheat Forensic Scanner • vibecoded edition");
    subtitle->setObjectName("subtitle");
    root->addWidget(subtitle, 0, Qt::AlignHCenter);

    auto *scanBox = new QFrame;
    scanBox->setObjectName("scanBox");
    scanBox->setMinimumHeight(260);

    auto *scanLayout = new QVBoxLayout(scanBox);
    scanLayout->addStretch();

    auto *input = new QLineEdit;
    input->setPlaceholderText("[ ENTER ACCESS CODE ]");
    input->setAlignment(Qt::AlignCenter);

    auto *glow = new QGraphicsDropShadowEffect;
    glow->setBlurRadius(18);
    glow->setOffset(0);
    glow->setColor(QColor(0, 255, 102, 120));
    input->setGraphicsEffect(glow);

    scanLayout->addWidget(input);

    auto *btn = new QPushButton("START ANALYSIS");
    scanLayout->addWidget(btn, 0, Qt::AlignHCenter);
    scanLayout->addStretch();

    root->addWidget(scanBox, 1);

    auto *footer = new QLabel("v1.0 // entropy analysis • trust signature verification");
    footer->setStyleSheet("font-size: 10px; color: #0a7a3e;");
    root->addWidget(footer, 0, Qt::AlignHCenter);

    window.show();
    return app.exec();
}
```

## Build (Qt 6 + CMake)

```cmake
cmake_minimum_required(VERSION 3.16)
project(DetectACNeonUI LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt6 REQUIRED COMPONENTS Widgets)

add_executable(detect_ac main.cpp)
target_link_libraries(detect_ac PRIVATE Qt6::Widgets)
```

## Cara compile

```bash
mkdir build && cd build
cmake ..
cmake --build .
./detect_ac
```

Kalau mau, saya bisa lanjutkan versi **ImGui + DirectX/OpenGL** (lebih cocok untuk overlay/tools) atau versi dengan animasi scanline.
