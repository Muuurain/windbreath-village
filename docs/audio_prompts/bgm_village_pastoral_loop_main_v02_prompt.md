# 音频生成提示词：bgm_village_pastoral_loop_main_v02

> 文档性质：本文件由 `audio-prompt-spec` 规范基于 `v01` 实测审听反馈升级编写，仅作为音乐生成 Agent / 外部音频生成模型的输入提示词与修改规格说明。**`v02` 音频尚未生成**，文中目标音频路径均为计划输出路径。

## 1. 资产元信息

### 基本信息

| 字段 | 内容 |
| --- | --- |
| 项目名称 | 风息村落物语 (Windbreath Village) |
| asset_id | AUD_BGM_VILLAGE_PASTORAL_MAIN_02 |
| 主文件名 | `bgm_village_pastoral_loop_main_v02` |
| 资产类型 | `bgm` |
| 用途 | 针对 `v01` 实测频谱过闷（质心 259 Hz、88.97% 能量堆积于 500 Hz 以下）及循环接缝 17.9 dB 断崖落差问题进行重制，成为兼具木质通透清晰度、温暖质感与真无缝循环的常驻田园背景音乐 |
| 优先级 | `P0` |
| 提示词版本 | `v02`（承接并修订 `bgm_village_pastoral_loop_main_v01`） |
| 目标生成模型及版本 | 待确认（提供模型无关通用中文与英文正向/修改指令提示词，兼容真实生成式音频模型与高质量声学采样/物理建模合成工作流） |
| 当前状态 | 仅完成 `v02` 修订提示词文件，音频待音乐生成 Agent 执行制作与后续审核 |

### 路径规则与交付路径

| 路径类别 | 路径值 | 状态 |
| --- | --- | --- |
| 1. 提示词 Markdown 完整保存路径 | `D:\Code\project\windbreath_village\docs\audio_prompts\bgm_village_pastoral_loop_main_v02_prompt.md` | 已写入 |
| 2. 原始高质量音频完整输出路径 | `D:\Code\project\windbreath_village\assets\audio\source\bgm_village_pastoral_loop_main_v02.wav` | 计划输出（未生成） |
| 3. 游戏运行时音频输出路径 | `D:\Code\project\windbreath_village\assets\audio\bgm\bgm_village_pastoral_loop_main_v02.ogg` | 计划输出（未生成） |
| 4. 可选分轨 / 短版本 / 参考音频 / 后期工程路径 | `D:\Code\project\windbreath_village\assets\audio\stems\bgm_village_pastoral_loop_main_v02`（如不提供分轨可留空或不创建空目录） | 计划路径 / 待确认 |
| 5. 项目内相对路径 / 引擎资源导入路径 | `assets/audio/bgm/bgm_village_pastoral_loop_main_v02.ogg`（`res://assets/audio/bgm/bgm_village_pastoral_loop_main_v02.ogg`；通过审核后再由主工程切换 `src/autoload/AudioManager.gd` 引用） | 计划导入路径 |

## 2. 音乐音频需求介绍

- **使用场景**：主菜单大厅（`MainMenu`）、6 大主题章节箱庭建造场景、无尽禅意造景模式以及「赏景」纯净陪伴模式（适配晨曦、午后、落日、夏夜四时氛围）。
- **叙事背景**：吉卜力质感手绘水彩田园海风村落，麦田与茶园伴清溪起伏，石板路连接民居与水车、茶寮、木桥、风铃塔、温泉亭等奇观，6 位居民与小动物安适漫步。
- **玩家正在做什么**：在手机竖屏上碎片化慢节奏点选、旋转并摆放六边形地块，观察邻接协同；或在手机外放与耳机环境下静听伴音休息。
- **核心修正诉求（从 `v01` 到 `v02` 必须解决的两大听感缺陷）**：
  1. **打破“发闷如隔墙”的浑浊感**：`v01` 版本为了避免刺耳过度削减中高频，导致 `0–500 Hz` 挤占近 `89%` 能量、`1.2–2.5 kHz` 仅剩 `0.65%`、频谱质心跌至 `259 Hz`。新版必须在**保证 3 kHz 以上依旧温和无刺耳金属哨音的前提下，把 500 Hz–2.4 kHz 原声木质清晰度与手指拨弦轮廓充分还回来**，确保在无法回放 `<180 Hz` 低频的手机小扬声器上也能听清温润明亮的琴音与旋律线。
  2. **修复循环接缝 `17.9 dB` 响度断层**：`v01` 结尾最后 1 秒响度跌至 `-31.14 dBFS` 而第 0 秒瞬间跳至 `-13.25 dBFS`。`v02` 结尾与开头必须通过尾音回绕（Tail Wrap）保持连续起伏与稳定电平，首尾接缝几乎无感过渡。
- **音频承担的功能**：清晰温柔、久听不累、木质透亮的慢节奏情感基座。
- **开始、结束与切换条件**：由 `AudioManager` 启动淡入并无缝循环播放；切入后台暂停，回前台恢复；支持与溪流环境音及 UI 音效共同混音。
- **对白与音效共存要求**：无语音对白，但需与 `amb_brook_loop`（水声）及落子/协同 SFX 共存。维持约 35% 乐句呼吸留白，在 `180 Hz–2.2 kHz` 保持清晰温和的音乐主干（无需沉重低音压底，避免低频与手机共振糊成一片），在 `2.5–4 kHz` 保留适度自然空气泛音但切忌出现尖锐金属谐振峰。

## 3. 生成风格

- **音乐类型与子类型**：Acoustic Chamber Pastoral Folk / Cozy Indie Game Score（原声室内乐田园民谣 / 温暖通透的木屋现场质感）
- **情绪关键词**：清澈温润（Warm & Clear）、松弛自然（Effortless）、木质甘甜（Woody & Sweet）、微风通透（Airy）、毫无闷沉感（Unmuffled）
- **时代或文化背景**：现代东亚乡村田园诗意与精致室内原声器乐的结合。
- **配器 / 音色构成（重点纠正 `v01` 音色质感）**：
  - **主奏旋律与和声核心（要有清晰木质颗粒感）**：**指腹轻拨尼龙弦古典吉他（Fingerpicked Nylon Guitar）**——务必保留指尖拨弦瞬间柔和清润的 `600 Hz–2.2 kHz` 琴弦咬合与木箱共鸣（禁止像 `v01` 一样用重度低通滤成单纯闷嗡），搭配**温暖立式原声钢琴（Warm Felt / Soft-Hammer Upright Piano）**在 `C4–G5` 舒展中音区弹奏明晰柔和的点状旋律与分解和弦（让木槌轮廓清澈可辨而不显暗淡）；
  - **柔和木管与质感衬托**：温和的**中音木质竖笛 / 竹笛 / 轻柔手风琴或口琴弱音长音**于中段介入，吹奏柔和的 `G4–A5` 空气感旋律呼应，带有轻微自然气息感而非纯电子正弦波；
  - **木质打击/弹拨色彩**：温润中音区**木质马林巴或清柔木琴（Soft-Mallet Rosewood Marimba）**点缀轻快水滴般的木头颗粒声；
  - **低频收敛**：大提琴仅做**干净节制的低音托底（Focused Acoustic Bass / Cello Pizzicato）**，严格控制 `60–180 Hz` 低频厚度，防止抢占整曲半数以上能量造成浑浊闷糊！
  - **禁止乐器**：依旧禁止架子鼓、电子鼓、金属铙钹、尖刺高音铁琴/风铃或刺耳电子合成波形。
- **节奏特点**：柔和流动的 `4/4` 拍舒缓八分音符分解，旋律线清晰错落（每小节 4–7 个自然起落音符），保留舒缓留白而不僵硬死板。
- **旋律与和声特征**：以 **F 大调 / 自然柔和五声倾向**为主，常用顺滑清澈和弦走向（如 `Fmaj7 -> C/E -> Dm9 -> Bbmaj7 -> Gm7 -> C9sus4`），通过中高把位清澈的导音与七音/九音色彩带出阳光照透叶片的通透感（切忌像 `v01` 那样全部压在 `87–330 Hz` 窄低音区！主旋律重心提升至 **`C4–F5`（`261 Hz–700 Hz` 基频及 `600 Hz–2.4 kHz` 泛音）**）。
- **混音质感与制作方向**：现代高保真原声客厅录音棚质感（Clean Acoustic Studio Room）。整理并收紧 `180 Hz` 以下低频滚降与清理，让 **`500 Hz–2.4 kHz` 区间顺滑展开、充满自然声学乐器泛音**，仅对 `4.5–8 kHz` 做极其轻柔的顺滑保护、保留微量 `2.5–5 kHz` 自然空气感，绝对不做 1 kHz 一刀切低通滤镜！
- **参考特征（仅作抽象特征说明）**：借鉴高品质原声吉他与原声立式钢琴二重奏的**清晰泛音透明度、均衡高-中-低频黄金比例与自然空间感**；禁止抄袭或近似模仿任何外部现有作品的具体旋律或段落结构。

## 4. 可量化音乐参数

| 参数 | 规格 | 说明 |
| --- | --- | --- |
| BPM / BPM 范围 | `72 BPM` | 严格恒速（匹配游戏慢节奏体验与工程 `.import` 网格设置） |
| 拍号 | `4/4` | 均匀四拍子呼吸感 |
| 调性 / 调式 | `F Major`（主体旋律线与和弦泛音覆盖 `C4–F5` 中高甜区） | 较 `v01` 上移旋律音区与泛音亮度，解决闷暗感 |
| 速度变化 | `严格恒速 72 BPM`（无大幅 rubato，保证 24 小节整格无缝循环） |  |
| 目标时长及允许误差 | `80.000 秒（严格 24 小节 @ 72 BPM，零额外前后静默）` | 与 Godot 工程配置对齐 |
| **频谱与清晰度量化靶标（`v02` 新增硬指标）** | 频谱质心 **`480–820 Hz`**；`60–180 Hz` ≤ `28%`；`500–2500 Hz` 合计 ≥ **`30%`**；`2500–6000 Hz` **`1.5%–5.0%`** | 直接纠正 `v01` 质心仅 259 Hz、低频占 88%、>1.2 kHz 不足 0.7% 的发闷问题 |

## 5. 结构与情绪曲线

- `0–13.33 秒（第 1–4 小节，晨光透亮引入）`：清晰的尼龙木吉他中高把位分解音型（基频 `260–520 Hz` 搭配 `700–1800 Hz` 真实琴弦泛音）与轻柔原声立式钢琴中音区清澈主题碎音共同切入，大提琴拨弦轻量点底；一开场便明亮干净、毫不闷沉，且必须以稳定音量衔接来自第 24 小节的循环过渡。
- `13.33–40.00 秒（第 5–12 小节，田园明朗主题段）`：毛毡钢琴清晰奏出温柔悦耳的主旋律（`A4–F5` 音区），木质马林巴以温润木质感在中高音区作出点睛应答，尼龙吉他持续铺织细腻透明的分解律动，低频克制干净，手机小喇叭也能清楚听出每一个灵动乐句。
- `40.00–66.67 秒（第 13–20 小节，清风木管展开段）`：加入温暖空气感的中音木质竖笛 / 竹笛于 `C5–F5` 区间温和吹奏舒展长句，与吉他、钢琴构成通透暖意的室内乐三重奏；动态平顺微微上扬，保持阳光明媚与清澈透明质感，毫无浑浊压迫感。
- `66.67–80.00 秒（第 21–24 小节，平滑衔接循环段）`：木管乐句于第 22 小节轻柔收束，**保持尼龙木吉他清晰的八分音符分解与立式钢琴轻柔共鸣一直延续到第 24 小节最后一拍**，和声平稳引导至 `C9sus4 -> Fmaj7`，末尾严禁大幅渐弱衰减，必须通过 0.6–1.0 秒尾音回绕（Tail Wrap）让 80.000 秒结尾与第 0.000 秒开头的 RMS 响度差保持在 **`<= 4.0 dB`** 以内。

## 6. 人声与歌词

- **人声策略**：纯音乐（无任何人声）
- **强制约束**：本曲必须严格为纯原声器乐演奏，**不得出现人声、念白、合唱或含歌词的声音**。

## 7. 循环与交互音乐要求

- **播放模式**：无缝循环（`loop`）
- **循环设计要求（重点针对 `v01` 断层问题修订）**：
  - **严禁末尾 1 秒响度跌崖式渐弱**！通过把生成超出的第 25 小节自然延音或混响尾音（约 0.8–1.5 秒）裁剪后叠加混合回第 1 小节开头（Tail Wrap），确保第 79–80 秒与第 0–1 秒在波形衔接与宏观响度上连贯如一，**头尾 100ms RMS 落差严格控制在 `<= 4.0 dB`**。
  - 结尾和声保持开放流畅导向下一循环第 1 拍，禁止完全断音收尾。
- **自适应与交互要求**：单一静态无缝循环版本；清澈的中高频设计需同时兼容游戏内水声环境音及五声调提示音效。

## 8. 完整生成提示词

### 中文完整正向提示词（给音乐生成 Agent 的直接执行指令）

```text
请严格基于 v02 规范重新生成《风息村落物语》的 80 秒（72 BPM，4/4 拍，F 大调，24 小节）纯原声室内乐无缝循环主配乐 `bgm_village_pastoral_loop_main_v02`。重点彻底修正 v01 “过度低通发闷（质心 259Hz、88% 能量在 500Hz 以下）”和“结尾淡出导致与开头相差 17.9dB 断层”的两大缺陷：
1. 音色与清晰度要求：呈现真正透明清澈、阳光温暖的手作木屋声学质感。以指腹拨奏、保留真实 600Hz–2.2kHz 琴弦细节与木箱亮度的尼龙弦古典木吉他分解作为贯穿纹理，搭配清晰温和的中高音区（C4–F5）原声立式钢琴主旋律、润泽木质马林巴清脆但温和的木颗粒点缀、克制干净不浑浊的低音大提琴拨弦，以及 13–20 小节温柔通透的中音木质竖笛呼应。绝对不要使用激进低通滤镜把 1kHz 以上砍光；必须保证手机外放都能清楚听见清亮温暖的木吉他与钢琴旋律轮廓，同时避免 3kHz 以上金属尖锐刺耳或任何合成器/正弦波塑料感。目标频谱质心 480–820 Hz，500–2500 Hz 清晰频段能量占总能量 30% 以上，60–180 Hz 低频控制在 28% 以下绝不轰头浑浊。
2. 禁止元素：严禁架子鼓、电子鼓、铙钹、尖刺铁琴/风铃及任何纯正弦波/方波合成音色，绝对不得出现人声、念白、合唱或含歌词的声音。
3. 真无缝循环与响度规格：24 小节严格恒速精准对齐 80.000 秒；末尾 1 秒严禁明显 fade-out，必须通过跨小节尾音回绕（tail wrap）将自然余韵平滑叠回第 0 秒开头，使首尾 100ms RMS 电平差 <= 4.0 dB 且无爆音咔哒声；整体标准化至 -18.0 ± 1.0 LUFS，True Peak <= -1.5 dBTP。完成后同时输出 48kHz/24-bit WAV 母带与 44.1kHz OGG Vorbis 运行时文件等待审核。
```

### 英文版 generation_prompt（给外部 AI 音乐生成模型的提示词文本）

```text
A warm, crystal-clear, unmuffled 80-second seamless-looping instrumental acoustic chamber pastoral soundtrack for a cozy village-building game, strictly steady at 72 BPM in 4/4 time and F Major across 24 bars. Bright sunlit wooden clarity without harshness: crisp yet gentle fingerpicked nylon-string acoustic guitar arpeggios with natural wooden string definition and articulate upper-mid overtones (600 Hz to 2.2 kHz), expressive soft-hammer upright acoustic piano carrying a sweet lyrical melody in the middle-to-upper register (C4 to F5), warm rosewood marimba notes, clean restrained acoustic cello pizzicato supporting the low end without boominess, and a light breathy wooden alto flute softly entering in bars 13–20. Open, transparent acoustic studio room tone with clean low-mid balance (no muddy bass buildup below 200 Hz, no aggressive low-pass filtering) and smooth airy highs gently tamed only above 5 kHz so every plucked note sparkles softly even on small mobile phone speakers without any piercing metallic resonance. Strictly no drums, no percussion kits, no cymbals, no metallic chimes, no harsh synths, no pure sine-wave synth tones, and purely instrumental: no vocals, no spoken word, no choir, no lyrics. Designed for continuous looping: keep the guitar and piano resonance flowing steadily through bar 24 into a smooth C9sus4 turnaround back to bar 1 with tail-wrap energy continuity (no trailing fade-out drop).
```

## 9. 负面提示词与禁止事项

- **排除声音与元素**：人声、念白、合唱、哼唱、歌词、架子鼓、电子鼓、铙钹、尖锐高音风铃、金属铁琴、廉价正弦波合成音（`sine-only synth feel`）、过度低沉嗡嗡贝斯轰鸣、激进 1 kHz 以下硬切低通闷音效果（`over-muffled / underwater / muddy low-pass sound`）。
- **排除混音与技术缺陷**：首尾音量落差超过 4 dB（结尾大幅淡出后开头重敲断层）、80–250 Hz 浑浊堆积、2.5–6 kHz 尖锐谐振刺耳、削波爆音、底噪、超过 20 ms 的头尾纯静音。
- **冲突检查声明**：正向要求已精准协调“清澈温暖的 `500–2500 Hz` 木质清晰度”与“柔和收敛 `>4.5 kHz` 避免刺耳”之间的平衡，与禁止“过度低通发闷”及“尖锐高频刺耳”完全自洽。

## 10. 技术交付规格

| 规格项 | 源文件（Master） | 运行时文件（Runtime） |
| --- | --- | --- |
| 文件格式 | `WAV（无压缩 PCM）` | `OGG Vorbis`（匹配 Godot 4.7.2 `AudioStreamOggVorbis`） |
| 采样率 | `48000 Hz` | `44100 Hz` |
| 位深 / 比特率 | `24-bit PCM` | `128–160 kbps VBR / Quality 5` |
| 声道 | `Stereo（双声道，自然立体声像）` | `Stereo` |
| 响度与峰值规范 | `-18.0 LUFS（±1.0 LU）/ True Peak <= -1.5 dBTP` | 同左 |
| **频谱健康靶标** | 频谱质心 `480–820 Hz`；`60–180 Hz` ≤ `28%`；`500–2500 Hz` ≥ `30%`；`2500–6000 Hz` `1.5%–5.0%` | 同左（转码后不可破坏高中频轮廓） |
| 首尾静默与循环一致性 | 首尾零纯静音；**头尾 100ms RMS 差值 ≤ `4.0 dB`**；采样点无爆音 | 同左，启用 `.ogg.import` `loop=true` |

### 后期处理与工程交付要求（音乐生成 Agent 需严格落实）

1. **避免重度低通造成二度发闷**：如果从模型得到的音频存在轻微齿音或毛刺，**禁止使用 `<1500 Hz` 低通一刀切**！仅对 `80–160 Hz` 做 `-2 dB` 清理防浑浊，使用宽 Q 值温和削减特定刺耳窄带（如 `3.5–5.5 kHz` 处最多 `-2 到 -3 dB`），务必保留 `600 Hz–2.4 kHz` 原声轮廓。
2. **真无缝循环 Tail Wrap**：严禁直接加末端 fade-out！应裁取 `80.000 s`（24 小节）后紧接着的多余 1.0–1.5 秒余韵片段，渐弱叠加混入音频第 `0.000 s` 开头处，并用极短过零点平滑确保第 80 秒直连第 0 秒时 RMS 平稳连贯。
3. **不污染游戏打包体积**：将 23 MB 级别的 `.wav` 母带保留在本地 `assets/audio/source/` 时，**必须配合 `assets/audio/source/.gdignore`（或排除 `assets/audio/source/*`）确保 Godot 不会把未压缩 `.wav` 打包进 APK / EXE**，提交审核前保持工程整洁。

## 11. 交付物与变体

| 序号 | 交付物角色 | 目标文件名 | 目标路径 | 状态 |
| --- | --- | --- | --- | --- |
| 1 | 提示词修改规格文档（`v02`） | `bgm_village_pastoral_loop_main_v02_prompt.md` | `D:\Code\project\windbreath_village\docs\audio_prompts\bgm_village_pastoral_loop_main_v02_prompt.md` | 已写入 |
| 2 | 主循环音频母带（待重制） | `bgm_village_pastoral_loop_main_v02.wav` | `D:\Code\project\windbreath_village\assets\audio\source\bgm_village_pastoral_loop_main_v02.wav` | 待生成 |
| 3 | 主循环音频运行时（待转码） | `bgm_village_pastoral_loop_main_v02.ogg` | `D:\Code\project\windbreath_village\assets\audio\bgm\bgm_village_pastoral_loop_main_v02.ogg` | 待生成与转码 |

## 12. 验收标准（供后续返工后审核逐项核对）

### 自动检查（硬性放行门槛）

- [ ] 文件命名为 `bgm_village_pastoral_loop_main_v02.wav` 与 `bgm_village_pastoral_loop_main_v02.ogg`
- [ ] `WAV` 为 `48000 Hz / 24-bit Stereo`，`OGG` 为 `44100 Hz / Stereo`，时长严格 `80.000 s`（±0.05 s）
- [ ] 集成响度 `-18.0 ± 1.0 LUFS`，True Peak `<= -1.5 dBTP`，无 DC 偏置、无 >20ms 头尾静音
- [ ] **已修复发闷**：频谱质心处于 **`480–820 Hz`**，`500–2500 Hz` 能量占比 **`>= 30%`**，`60–180 Hz` 低频能量 **`<= 28%`**
- [ ] **已修复不刺耳**：`2500–6000 Hz` 占 **`1.5%–5.0%`** 且无尖锐高频啸叫峰值
- [ ] **已修复循环断层**：开头 `0–0.1 s` 与结尾 `79.9–80.0 s` 的 100ms RMS 响度差值 **`<= 4.0 dB`**
- [ ] `.wav` 母带已通过 `.gdignore` / `.gitignore` / `export_presets.cfg` 与运行时隔离，不膨大 APK/PCK 包体

### 人工听审

- [ ] 具有真实尼龙吉他拨弦与原声钢琴颗粒度，彻底告别“水下闷音/纯合成正弦波感”与旧版刺耳感
- [ ] 手机小扬声器低音量外放清晰悦耳，耳机连听 3 遍循环衔接处顺滑无跳跃感
- [ ] 与游戏内溪流环境音及木质/五声调 UI 音效叠加不冲突、不糊成一片

## 13. 假设与待确认事项

- **与 `v01` 审核实测数据的映射**：本修订版参数直接针对 `v01` 实测结果制定（`v01` 实测质心 `259.0 Hz`、`60–180 Hz` `47.68%`、`1200–2500 Hz` `0.65%`、首尾 100ms RMS 差 `17.89 dB`）。
- **关于伴音环境音的并行提醒**：若音乐生成 Agent 有权限一并优化配套环境音，建议同步将 `amb_brook_loop.ogg`（旧版质心 `835.4 Hz`）略作柔和化并移除 `amb_rain_chime_loop.ogg` 内的 C 大调高音合成钟琴，或留待审核阶段再统一处理。
- **审核责任划分**：本文件只负责明确 `v02` 的完整音乐生成与技术纠偏规范；**未修改当前仓库中的任何代码或音频文件**，等待外部音乐生成 Agent 按此完成重制后，由本侧运行自动化频谱/包络/打包规范审核。
