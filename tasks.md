# Flux Project Tasks

## ✅ 已完成 (Completed)

### 阶段一：项目基础架构 (Infrastructure)
- [x] **配置 `pubspec.yaml`** (Riverpod, http, mDNS, etc.)
- [x] **项目目录结构** (Models, Providers, Services, Screens, Widgets)
- [x] **WLED JSON API 模型** (WledDevice, WledState, WledSegment, WledInfo)

### 阶段二：核心通信层 (Communication)
- [x] **WledApiService**
    - GET /json 获取完整状态
    - POST /json/state 发送控制指令
    - 请求防抖/节流 (Debounce/Throttle)
    - 乐观 UI (Optimistic UI) 支持
- [x] **MdnsDiscoveryService** (mDNS 设备自动发现)

### 阶段三：状态管理 (Riverpod)
- [x] `deviceListProvider` (设备列表)
- [x] `currentDeviceProvider` (当前设备)
- [x] `deviceStateProvider` (实时状态)
- [x] `segmentProvider` (分区控制)
- [x] `effectsPalettesProvider` (效果/调色板)

### 阶段四：UI 实现 (UI Implementation)
- [x] **设备列表页 (DeviceListScreen)**
    - 设备卡片, 状态轮询, 离线状态
    - 自动发现 (mDNS) UI
    - 手动添加 IP 
- [x] **设备控制主页 (DeviceControlScreen)**
    - 开关, 亮度 (带防抖), 颜色选择 (RGB+W)
    - UI/UX 动效: Hero 转场, BouncyButton, 呼吸背景, 交错动画
- [x] **分段控制页 (SegmentScreen/SegmentsListScreen)**
    - 分段列表, 选中状态, 开关
- [x] **效果页 (EffectsScreen)**
    - 搜索, 实时预览图标 (Icon based)
- [x] **调色板页 (PalettesScreen)**
    - 搜索, 颜色预览
- [x] **场景管理 (PresetsListScreen)**
    - 预设列表, 保存预设, 播放列表控制 (Playlist Loop)

### 阶段五：高级功能 (Advanced Functions)
- [x] **设备组管理 (Group Management)**
    - 多设备同步控制
- [x] **数据持久化** (SharedPreferences)
    - 设置保存 (Theme, Locale)

### 阶段六：验证与优化 (Validation & Optimization)
- [x] **主题适配** (Light/Dark Mode, Glassmorphism)
- [x] **交互打磨** (HapticFeedback, Animations)

---

## 📅 待办事项 (To-Do)

### 质量保证 & 测试 (QA)
- [x] **单元测试 (Unit Tests)**
    - Json Parsing Edge Cases ✅
    - Riverpod State Logic *(需 mock)*
- [x] **集成测试 (Integration Test)** ✅
    - 应用启动测试
    - 导航流程测试
    - 主题切换测试
- [ ] **性能分析 (Profiling)**
    - 检查大量设备时的列表滚动性能

### 工程化 & 发布 (Engineering)
- [x] **国际化 (i18n)** ✅
    - 保留现有 `l10n.dart` 实现 (170+ 字符串, 类型安全, Riverpod 集成)
    - 修复所有硬编码中文：分段管理、预设、效果、调色板、过渡时间
- [x] **代码质量** ✅
    - 修复所有 `flutter analyze` 弃用警告
    - `activeColor` → `activeTrackColor`
    - `Color.value` → `Color.toARGB32()`
- [ ] **CI/CD Pipeline** (Github Actions)
