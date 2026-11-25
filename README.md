<div align="center">

<img src="assets/art/ui/launcher_192.png" alt="Windbreath Village Emblem" width="128" height="128" />

# 风息村落物语 · Windbreath Village

**慢节奏疗愈系田园六边形拼接 × 生态微循环经营手游（Android / Windows）**

[![Godot](https://img.shields.io/badge/Godot-4.7.2%20GL%20Compatibility-478CBF?logo=godotengine&logoColor=white)](https://godotengine.org/)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Windows-3DDC84?logo=android&logoColor=white)](https://github.com/Muuurain/windbreath-village/releases)
[![CI](https://github.com/Muuurain/windbreath-village/actions/workflows/ci.yml/badge.svg)](https://github.com/Muuurain/windbreath-village/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-34D399.svg)](LICENSE)

> **六边形山水拼接 × 邻接生态协同 × 村民挑货冒泡 × 昼夜光影白噪音伴侣**

</div>

---

## 游戏简介

**《风息村落物语》（Windbreath Village）** 是一款专为手机碎片时间打造的竖屏慢节奏田园生态建设游戏。没有倒计时压迫与失败惩罚——在铺展六边形草甸、麦田、茶园、竹林与清溪的同时，触发**溪流灌溉、水力驱动、宜居风景宅与道路物流**等丰富邻接协同，看着背篓农夫、煮茶婆婆、打盹橘猫、溪畔白鹭与雪顶小狐在你亲手筑起的小村里自由漫步、泡泡产出。

随时打开拼几块地砖、点亮暖黄色纸灯笼、听着溪流与细雨风铃放空，退出自动存档随时接续。

---

## 核心特色

- **超越单纯拼图的生态微循环体系**
  - **10 类基础地块**（野花草甸、金色麦田、翠绿茶园、樱雪花海、青翠竹林、清冽直溪、弯月小溪、碧波荷塘、青瓦民居、青石岔路）。
  - **5 座可建造「风物地标」**：消耗村落积累的稻穗、茶香、竹木，建造 **水车磨坊**、**灯笼茶寮**、**灯笼木桥**（水陆双通跨溪架桥）、**风铃花塔**、**云泉温泉亭**。
  - **多维邻接协同**：溪流灌溉 ×2、水力丰收 ×2、宜居风景宅 +4、石路/水系连通加和煦、风铃和鸣光环。
- **会呼吸的居民与动物伙伴**
  - 达成对应生态布局即可吸引 **6 位各具性格的居民**入住：**阿禾**（沿石路挑货）、**柳姨**（茶寮煮茗）、**团子**（蜷在花旁打呼噜的橘猫）、**霜羽**（沿水系巡游的白鹭）、**远风**（红氅旅人）、**绒雪**（雪顶小狐）。
- **双模式游玩 × 纪念明信片收集**
  - **6 大主题章节箱庭**：每章拥有独立的氛围基调与 3 项温和目标，通关解锁手绘纪念明信片并永久收入图鉴。
  - **无尽禅意造景模式**：自由扩张理想桃源并自动持久化保存，支持开启右上角**「赏景」**纯净无 UI 模式当作桌面陪伴动态画卷。
- **四种昼夜光影 × 多轨白噪音混音**
  - 一键切换 **晨曦薄雾 / 午后暖阳 / 落日余晖 / 萤火夏夜**（夜间纸灯笼暖光透窗、萤火虫飞舞）。
  - 独立调节 **田园卡林巴配乐**、**溪流风声**、**细雨风铃白噪音** 与触感震动反馈。
- **新手引导与完整玩法图解 (`v1.1.0`)**
  - **5 步互动新手引导 (`TutorialCoach`)**：首次进入村落自动开启，跟随「认识目标 → 选牌与旋转 → 点击空位预览 → 确认放置 → 协同口诀」实时操作推进，支持随时跳过或从暂停/指南重温。
  - **4 分页图文《玩法说明》(`GameplayGuideModal`)**：在主菜单、风物图鉴、局内顶部与暂停界面均可打开，含「核心操作」「协同加分（双六边形对照图解）」「风物与居民」「模式图鉴」四大分页。
  - **行囊地形接口实时预览 (`HexEdgePreview`)**：全部手牌实时显示微缩景物与随旋转同步转动的蓝色溪流/米色石路边线。
- **移动端竖屏触控优化**
  - 单指拖动平移、双指捏合缩放、点击预览协同连线后二次确认落子（支持 1 步撤回与行囊换牌）。
  - 内置 `TouchScrollContainer` 确保手势在图标、卡片和按钮上直接滑动也能流畅滚动不误触。

---

## 技术架构与目录结构

项目采用 **Godot 4.7.2 + 强类型 GDScript 2.0 + GL Compatibility (OpenGL ES 3.0)** 构建，结合 **Nanobanana 手绘风图像生成** 与 **Python + FFmpeg 离线音频合成管线**。

```text
windbreath_village/
├── assets/
│   ├── art/                 # 39 张处理后透明精灵、六边形地砖、UI 图标、主视觉与明信片
│   ├── audio/               # 3 首无缝循环 BGM/白噪音与 10 个柔和木质/五声调音效 (.ogg)
│   └── shaders/             # 水波闪烁、微风轻拂摇曳、暖光灯笼着色器
├── docs/
│   ├── GAME_DESIGN.md       # 生态协同公式、风物地标与关卡设计文档
│   └── ARCHITECTURE.md      # 分层架构与移动端性能优化说明
├── src/
│   ├── autoload/            # EventBus / GameData / SaveManager / AudioManager
│   ├── core/                # 纯逻辑层 (HexMath / EcosystemEngine / VillageState)
│   ├── world/               # 2.5D 地块节点 / 村民动物巡游 / 交互相机世界 (VillageWorld)
│   ├── ui/                  # TouchScrollContainer / HexEdgePreview / GameplayGuideModal / TutorialCoach / UiStyles / MainMenu / ChapterSelect / Almanac / GameHud
│   ├── scenes/              # Main.tscn
│   └── Main.gd              # 根场景调度器
├── tests/                   # 自动化单元测试与主场景集成测试 (TestSuite.gd)
├── tools/                   # Nanobanana 切图抠图管线、音频合成器与打包校验脚本
├── project.godot
└── export_presets.cfg
```

更多细节请参阅 [游戏设计文档](docs/GAME_DESIGN.md) 与 [技术架构文档](docs/ARCHITECTURE.md)。

---

## 快速开始与构建

### 1. 直接下载游玩
前往本仓库 [Releases](https://github.com/Muuurain/windbreath-village/releases) 下载最新发行包（当前最新 **`v1.1.0`**）：
- **Android 手机**：下载 `windbreath_village_debug.apk` 安装游玩，或通过 ADB 安装：
  ```bash
  adb install -r windbreath_village_debug.apk
  ```
- **Windows 桌面**：下载 `WindbreathVillage-v1.1.0-win64.zip` 解压后运行 `windbreath_village_win64.exe`。

### 2. 源码运行与自动化测试
使用 **Godot 4.7.2** 打开根目录 `project.godot` 即可运行，或通过命令行运行测试与导出：

```powershell
# 运行无头单元测试与集成测试
powershell -ExecutionPolicy Bypass -File tools\verify_project.ps1

# 测试并导出 Android APK 与 Windows 可执行文件
powershell -ExecutionPolicy Bypass -File tools\verify_project.ps1 -ExportAndroid -ExportWindows
```

### 3. 重新处理美术与生成音频资源（可选）
需要 Python 3.11+（`Pillow`、`numpy`）以及 `ffmpeg`：
```bash
python tools/process_nano_assets.py   # 切分与抠图透明化精灵表并生成无缝六边形底图
python tools/generate_audio.py        # 重新合成 OGG 音效与无缝循环背景音轨
```

---

## 操控说明

| 平台 | 地图移动 / 缩放 | 放置与协同 | 氛围与休息 |
| :--- | :--- | :--- | :--- |
| **Android 手机** | 单指拖拽平移 / 双指捏合缩放 / 右侧 `+ -` | 点选行囊地块或工坊风物 → 点击空位预览连线 → 再点确认 | 右上角切换昼夜光影或开启「赏景」纯净模式 |
| **Windows 桌面** | 鼠标左键拖拽平移 / 滚轮缩放 | 左键点选与预览落子 | 支持全部面板触屏模拟与音频混音滑块 |

---

## 开源协议

本项目基于 [MIT License](LICENSE) 开源。
