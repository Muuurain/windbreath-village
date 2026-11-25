# 《风息村落物语》(Windbreath Village) 技术架构说明

## 1. 引擎与渲染选型
- **引擎**：Godot 4.7.2 Stable Mono（强类型 GDScript 2.0 构建，免 .NET AOT 与 NDK 交叉编译风险，稳定导出 Android APK）。
- **渲染后端**：`GL Compatibility`（OpenGL ES 3.0），配合 `import_etc2_astc=true` 优化移动端显存与续航。
- **分辨率与安全区**：逻辑竖屏 `720×1280`，`canvas_items` + `expand`，全面接入 `DisplayServer.get_display_safe_area()` 适配刘海屏与手势导航条。

## 2. 分层目录设计
- `src/autoload/`：`EventBus`（事件解耦）、`GameData`（10 地块 + 5 风物 + 6 居民 + 6 章节 + 4 明信片 + 4 氛围）、`SaveManager`（局外收藏、章节断点与无尽禅意村落三档 JSON 持久化）、`AudioManager`（多轨无缝循环环境音 + 池化音效）。
- `src/core/`：纯数据与逻辑层（`HexMath`、`EcosystemEngine`、`VillageState`），完全不依赖渲染树，支持 `--headless` 下毫秒级单元测试。
- `src/world/`：`HexTileNode`（底层六边形纹理 + 精确 60° 中点河流/石路样条绘制 + 风吹摇曳/水光/灯笼着色器）、`VillagerManager`（沿连通石路/水系漫游的小人与动物 + 昼夜花瓣/萤火粒子）、`VillageWorld`（双指缩放、拖拽平移防误触、点击预览与协同连线提示）。
- `src/ui/`：`TouchScrollContainer`（在图标/按钮上直接拖动不卡顿并自动防误触）、`HexEdgePreview`（手牌与图解共享的六边形边线微缩组件）、`GameplayGuideModal`（4 分页图文玩法说明弹窗）、`TutorialCoach`（5 步互动新手引导浮层）、`UiStyles`、`MainMenu`、`ChapterSelectScreen`、`AlmanacScreen`、`GameHud`。
- `tools/` & `tests/`：离线资源处理脚本（`process_nano_assets.py`、`generate_audio.py`）、自动化验证脚本（`verify_project.ps1`）与完整集成测试（`TestSuite.gd`）。
