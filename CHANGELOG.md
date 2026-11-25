# Changelog

All notable changes to **Windbreath Village (风息村落物语)** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-11-25

### Added
- **5 步互动新手引导 (`src/ui/TutorialCoach.gd`)**：首次进入村落自动开启，根据玩家真实选牌旋转、预览空位、放置地块操作自动推进步骤，支持随时跳过或从指南/暂停界面重新开启。
- **4 分页图文玩法说明弹窗 (`src/ui/GameplayGuideModal.gd`)**：在主菜单、图鉴页、局内顶部「玩法」按钮与暂停弹窗均可随时打开，涵盖「核心操作」「协同加分（双六边形配对图解）」「风物居民」「模式图鉴」四大模块，内置 `TouchScrollContainer` 滑动与一键开启互动引导入口。
- **全手牌旋转边缘预览 (`src/ui/HexEdgePreview.gd`)**：提取共享微缩六边形边缘组件，所有手牌卡片在显示农田/建筑图标的同时实时渲染随旋转同步转动的蓝色溪流与米色石路接口。

### Changed
- 弹窗开启时自动屏蔽底层 `VillageWorld` 误触，并增强 `TouchScrollContainer` 跨 `CanvasLayer` 遮挡检测。
- 扩展 `tests/TestSuite.gd` 覆盖 `GameplayGuideModal`、`TutorialCoach`、`HexEdgePreview` 与 `tutorial_seen` 持久化。

## [1.0.0] - 2026-11-25

### Added
- **核心玩法闭环**：完成六边形田园拼接 × 生态微循环经营（溪流灌溉、水力驱动、宜居风景宅、道路与水路连通、1 步撤回、手牌微调与风物工坊建造）。
- **动态世界与居民系统**：6 位村民与动物伙伴（阿禾、柳姨、团子、霜羽、远风、绒雪）沿连通道路/水系实时漫游与冒泡产出。
- **双模式与长线收集**：包含 6 大主题章节箱庭、4 张全彩纪念明信片收集册、无尽禅意造景模式及「赏景」纯净模式。
- **四种昼夜光影与白噪音混音**：支持晨曦薄雾、午后暖阳、落日余晖、萤火夏夜切换；内置田园配乐、溪流声与细雨风铃声多轨混音。
- **Nanobanana 美术与离线音频流水线**：生成全套手绘风背景、图标、地标、道具、居民与明信片插画（39 张 PNG）以及 13 个 OGG 音乐音效。
- **移动端 UX 与自动化验证**：内置 `TouchScrollContainer` 解决触屏滚动被图标遮挡问题，包含 `tests/TestSuite.gd` 全自动单元测试与集成测试。
