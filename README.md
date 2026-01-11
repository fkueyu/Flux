# Flux - Modern WLED Controller

Flux 是一个现代化、极简设计的 WLED 设备控制应用，基于 Flutter 构建。它旨在提供流畅、直观的用户体验，让 WLED 灯带的管理变得简单而优雅。

## ✨ 特性 (Features)

*   **自动发现**: 通过 mDNS 自动发现局域网内的 WLED 设备，零配置上手。
*   **实时控制**: 毫秒级响应的开关、亮度、颜色调节。
*   **乐观 UI (Optimistic UI)**: 操作即时反馈，无视网络延迟，提供丝般顺滑体验。
*   **现代设计**: 采用 Glassmorphism 玻璃拟态设计，配合 `flutter_animate` 带来的细腻微交互。
*   **深色模式**: 完美适配 iOS/Android 系统级深色/浅色主题切换。
*   **防御性编程**: 针对网络波动优化的重试机制与降级处理，保证应用稳定性。

## 🛠 技术栈 (Tech Stack)

*   **Framework**: Flutter 3.10+ (Dart 3.0)
*   **State Management**: [Riverpod 2.6](https://riverpod.dev/) (Annotation-based)
*   **Networking**: HTTP (with Keep-Alive & Timeout handling)
*   **UI Components**:
    *   `flutter_animate`: 声明式动画
    *   `flex_color_picker`: 专业的色彩选择器
    *   `cuperintop_icons`: iOS 风格图标
*   **Architecture**:
    *   Feature-first layered architecture
    *   Code Generation (`riverpod_generator`, `json_serializable`)

## 📸 截图 (Screenshots)

| Light Mode | Dark Mode |
|:---:|:---:|
| ![Light Mode](docs/screenshots/light.png) | ![Dark Mode](docs/screenshots/dark.png) |

*(注：请在发布后替换截图路径)*

## 🚀 快速开始 (Getting Started)

### 环境要求

*   Flutter SDK >= 3.10.0
*   Dart SDK >= 3.0.0

### 安装与运行

1.  **克隆项目**
    ```bash
    git clone https://github.com/your-username/flux.git
    cd flux
    ```

2.  **安装依赖**
    ```bash
    flutter pub get
    ```

3.  **代码生成 (必须)**
    本项目使用 code generation 来处理 JSON 序列化和 Riverpod providers。
    ```bash
    dart run build_runner build -d
    ```

4.  **运行**
    ```bash
    flutter run
    ```

## 📂 项目结构 (Project Structure)

```
lib/
├── core/          # 核心配置 (Theme, Extensions, Utils)
├── models/        # 数据模型 (WLED JSON API, Settings) - 类型安全
├── providers/     # Riverpod Providers (Business Logic)
├── screens/       # 页面逻辑 (View Layers)
├── services/      # 基础设施 (API, mDNS, Storage)
├── widgets/       # 可复用组件 (GlassCard, BouncyButton)
└── main.dart      # 应用入口
```

## 🤝 贡献 (Contributing)

欢迎提交 PR！请确保代码风格符合 `flutter_lints` 规范，并保持 "No Fluff" 的代码哲学。

## 📄 许可证 (License)

本项目基于 MIT License 开源。
