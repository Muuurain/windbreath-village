# 音频生成提示词：bgm\_village\_pastoral\_loop\_main\_v01

> 文档性质：本文件由
> `audio-prompt-spec`
> 规范生成，仅作为外部音乐 / 音频生成模型的输入提示词与制作规格说明。
> **音频尚未生成**
> ，文中目标音频路径均为计划输出路径。

## 1. 资产元信息

### 基本信息



| 字段        | 内容                                                                           |
| --------- | ---------------------------------------------------------------------------- |
| 项目名称      | 风息村落物语 (Windbreath Village)                                                  |
| asset\_id | AUD\_BGM\_VILLAGE\_PASTORAL\_MAIN\_01                                        |
| 主文件名      | `bgm_village_pastoral_loop_main_v01`                                         |
| 资产类型      | `bgm`                                                                        |
| 用途        | 替换当前由 `tools/generate_audio.py` 生成的合成旧音轨，作为主界面、6 大主题章节箱庭与无尽禅意造景通用的常驻舒缓田园背景音乐 |
| 优先级       | `P0`                                                                         |
| 提示词版本     | `v01`                                                                        |
| 目标生成模型及版本 | 待确认（提供模型无关通用中文与英文正向提示词，可直接适配主流 AI 音乐生成模型）                                    |
| 当前状态      | 仅完成提示词文件，音频待生成                                                               |

### 路径规则与交付路径



| 路径类别                          | 路径值                                                                                                                                                                                                                        | 状态                                          |
| ----------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------- |
| 1. 提示词 Markdown 完整保存路径        | `D:\Code\project\windbreath_village\docs\audio_prompts\bgm_village_pastoral_loop_main_v01_prompt.md`                                                                                                                       | 已写入                                         |
| 2. 原始高质量音频完整输出路径              | `D:\Code\project\windbreath_village\assets\audio\source\bgm_village_pastoral_loop_main_v01.wav`                                                                                                                            | 计划输出（未生成）  |
| 3. 游戏运行时音频输出路径                | `D:\Code\project\windbreath_village\assets\audio\bgm\bgm_village_pastoral_loop_main_v01.ogg`                                                                                                                               | 计划输出（未生成）  |
| 4. 可选分轨 / 短版本 / 参考音频 / 后期工程路径 | `D:\Code\project\windbreath_village\assets\audio\stems\bgm_village_pastoral_loop_main_v01`（可选原声分轨与后期对齐工程）                                                                                                                  | 计划路径 / 待确认                                  |
| 5. 项目内相对路径 / 引擎资源导入路径         | `assets/audio/bgm/bgm_village_pastoral_loop_main_v01.ogg`（`res://assets/audio/bgm/bgm_village_pastoral_loop_main_v01.ogg`；上线替换时亦可在 `src/autoload/AudioManager.gd` 中切换引用或对应替换旧路径 `res://assets/audio/bgm/bgm_pastoral_loop.ogg`） | 计划导入路径     |

## 2. 音乐音频需求介绍



* **使用场景**：主菜单大厅（`MainMenu`）、6 大主题章节箱庭建造流程、无尽禅意造景模式以及右上角开启「赏景」纯净陪伴模式（含晨曦薄雾、午后暖阳、落日余晖、萤火夏夜四种光影氛围）。

* **叙事背景**：海风轻拂、步调舒缓的水彩手绘田园小村。麦田与茶园依溪流层层铺展，石板小路串起青瓦民居与风物奇观（水车磨坊、灯笼茶寮、灯笼木桥、风铃花塔、云泉温泉亭），阿禾、柳姨、远风与橘猫团子、白鹭霜羽、雪顶小狐在村落间自在漫步。

* **玩家正在做什么**：利用手机竖屏碎片时间单手点选、旋转并放置六边形地形卡片，观察溪流灌溉、宜居风景宅等协同连线，或在夜晚与微雨天开启「赏景」模式当作治愈系随身陪伴画卷放空休息；全程无倒计时、无失败惩罚、无任何竞争或战斗紧张感。

* **需要传达的情绪**：宁静松弛、温暖通透、质朴柔和、从容陪伴 —— 必须彻底解决当前版本合成音乐因高频硬泛音、反复急促短循环及多轨噪声叠加造成的「混乱、嘈杂、刺耳」听感，让玩家即使连续开着手机外放或佩戴耳机 15 分钟以上也毫无听觉疲劳。

* **音频承担的功能**：作为全游戏最底层的温和情绪底座，稳定慢节奏拼图的心流，并与溪流环境音及木质 / 风铃 UI 音效自然共存而不喧宾夺主。

* **开始、结束与切换条件**：应用启动后由 `AudioManager` 在常驻循环轨淡入播放，切换界面不中断；进入系统后台或失去焦点时随通知暂停、切回前台续播；玩家可在设置中随时通过独立音量滑块调节 BGM 比例。

* **对白与音效共存要求**：游戏内无语音对白，但本音轨在运行时会长期与 `amb_brook_loop`（溪流环境音，中高频段有水声连续能量）、可选开启的 `amb_rain_chime_loop`（细雨白噪音）以及 8 通道随机触发的 `sfx_*`（落子、旋转、资源冒泡、协同提示，核心清晰区在 600 Hz–2.8 kHz）同时叠加发声。因此**编曲密度必须刻意保持稀疏（预留约 35%–45% 乐句休止留白）**，避免持续高频拨奏或复杂对位堆叠；高频 2.5 kHz 以上能量须温和收敛，为自然水声与木质反馈音效留出充足的频谱净空与至少 `-6 dB` 混合余量。

## 3. 生成风格



* **音乐类型与子类型**：Acoustic Chamber Pastoral / Cozy Slice-of-Life Indie Game Score（原声室内乐田园配乐 / 治愈系慢节奏模拟经营背景音乐）

* **情绪关键词**：温暖恬淡、木质柔润、松弛呼吸感、午后暖阳、零压迫治愈

* **时代或文化背景**：现代东亚乡村田园美学与欧陆室内原声民谣的结合 —— 呈现出温暖手作木屋里的真实现场感，避免廉价芯片电子感与厚重古典宫廷交响的庄严感。

* **配器 / 音色构成**：


  * **织体铺底**：指腹轻弹的**尼龙弦古典木吉他**（Warm Nylon-String Acoustic Guitar，分解慢弧音型，避开钢弦拨片的尖亮擦弦声）与加装弱音毛毡的**温厚立式钢琴**（Soft Felt Upright Piano，仅用中低与中音区温和和弦衬托，柔化敲击瞬态）；

  * **旋律对答**：以**温润木质马林巴**（Mellow Felt-Mallet Marimba，中低音区柔和木质共鸣）和轻柔的**尼龙吉他单音小动机**交替引导；下半段可极温和、稀疏地加入带轻柔气声的**中音木质竖笛 / 低音竹笛**（Soft Wooden Alto Flute / Warm Wooden Recorder，只吹奏长呼吸舒缓中音，禁止尖啸高音区）；

  * **低频支撑**：大提琴温和拨弦（Warm Cello Pizzicato）在每小节 1、3 拍轻柔托底，辅以极薄、无刺耳弓弦噪音的弱奏温暖大提琴长音（Gentle Warm Cello Sustain）。

  * **禁止乐器与零打击乐**：**完全不配备架子鼓、军鼓、金属铙钹、三角铁、沙锤碎拍、清脆高频铁琴（Glockenspiel）或连续金属铃铛**，仅依赖原声木吉他与大提琴拨弦建立柔软摇曳脉冲，从根源消除嘈杂感。

* **节奏特点**：平稳安定的 `4/4` 拍轻缓行板脉冲，八分音符分解温柔起伏，每小节主旋律音符控制在 3–6 个之间，句尾稳定留白半小节至一小节；严禁切分乱拍、多声部互抢节奏或紧绷附点推进。

* **旋律与和声特征**：采用 **F 大调兼顾柔和五声色彩（F Major / F Pentatonic leaning: F-G-A-C-D）**，和弦选用温暖开放的延留色彩（如 `Fmaj7 -> Dm9 -> Bbmaj7 -> C6sus4`），完全避开尖锐三全音、不协和小二度碰撞或快速转调；旋律曲线平缓小跨度上下行，听感松弛笃定。

* **混音质感与制作方向**：近 - 中距离温暖木屋室内拾音（Close-Miked Intimate Room Tone）叠加顺滑自然的板式短混响（RT60 约 1.3–1.6 秒，且混响高频于 3.5 kHz 以上低通收敛）。能量重心饱满地落在温和的 `180 Hz–1.0 kHz` 暖木频段；**对&#x20;**`2.5 kHz–8.0 kHz`**&#x20;做平滑温顺的高频滚降（Warm Rolled-Off Highs）**，杜绝手机小扬声器刺耳嘶声与金属谐振。

* **参考特征（仅作抽象特征说明）**：仅借鉴传统原声治癒田园游戏 “少量原声乐器轮流对话、乐句之间大面积留白、软锤木质音色与中低频温暖包裹感” 的编制哲学与混音比例；严禁直接提及、模仿或复刻任何现成影视或游戏配乐的旋律走向与和弦固定段落。

## 4. 可量化音乐参数



| 参数           | 规格                                                       | 说明                                               |
| ------------ | -------------------------------------------------------- | ------------------------------------------------ |
| BPM / BPM 范围 | `72 BPM`                                                 | 配合慢节奏碎片化思考与放置操作，约每秒 1.2 拍，步调轻柔舒缓不催促，且 24 小节恰为整数秒 |
| 拍号           | `4/4`                                                    | 稳定均匀的四拍子呼吸律动，方便无缝对齐 4/8/24 小节结构与首尾接缝             |
| 调性 / 调式      | `F Major`（偏向 F-G-A-C-D 五声韵律）                             | 音高温暖明亮而不尖刺，且主音音域贴合柔和男 / 中音原声区，不易引发高频疲劳           |
| 速度变化         | `严格恒速 72 BPM`（禁止 rubato、禁止渐快渐慢）                          | 确保后期精确按 24 小节整拍点做循环裁剪（loop wrap），杜绝接缝节奏错位        |
| 目标时长及允许误差    | `80.0 秒（精确对应 24 小节 @ 72 BPM，允许误差 ±2 秒；后期修整至精确 80.000 秒）` | 相比旧版 16 秒短循环延长 5 倍，显著缓解重复听觉疲劳并保持轻量体积             |

## 5. 结构与情绪曲线



* `0–13.3 秒（第 1–4 小节，微风启幕与温暖铺底）`：加毡立式钢琴以轻触和弦奏出温和 `Fmaj7` 到 `C6sus4` 的呼吸起伏，大提琴低音温暖轻衬，尼龙木吉他切入舒缓稳健的八分音符分解；音区保持在柔和低中频，不出现主奏高音，留出宽广空气感，同时便于循环时平滑承接第 24 小节尾音。

* `13.3–40.0 秒（第 5–12 小节，田园晴日主题）`：尼龙木吉他单音与软锤马林巴先后呈示温婉恬淡的四小节问答乐句（`Fmaj7 -> Dm9 -> Bbmaj7 -> C6sus4` 循环变奏），大提琴拨弦在 1、3 拍温柔点缀根音；乐句末尾特意留空 2–3 拍余韵，让溪流水声自然透出，整体克制而亲切。

* `40.0–66.7 秒（第 13–20 小节，炊烟与阳光微扬段）`：中音木质竖笛以气声柔和的方式缓缓奏出两句简短呼应长音，弱奏温暖大提琴长音与毛毡钢琴宽广和声略微托高氛围（动态温和微升，依旧绝不厚重轰鸣），营造村落点灯、茶烟袅袅的满足情绪。

* `66.7–80.0 秒（第 21–24 小节，晚风回落与无缝转接）`：木质竖笛与马林巴于第 22 小节末温柔淡出退场，织体自然抽稀至毛毡钢琴、尼龙吉他分解与轻拨大提琴，最后一小节和声平稳悬停于温暖的 `C6sus4` 并向开头 `Fmaj7` 倾泻，保留轻微吉他琴箱残响以便无缝衔接回第 0 秒起点。

## 6. 人声与歌词



* **人声策略**：纯音乐（无任何人声）

* **强制约束**：本曲必须严格保持纯原声器乐演奏，**不得出现人声、念白、合唱或含歌词的声音**（包括人声哼唱 `ooh/aah` 采样或合成人声垫均予禁止）。

## 7. 循环与交互音乐要求



* **播放模式**：无缝循环（`loop`）

* **循环设计要求**：第 24 小节末尾禁止使用沉重且完全断音的主和弦完全终止式，必须以柔和过渡和弦与持续轻柔吉他分解 / 暖混响自然过渡到第 1 小节；首尾均不得有空白静默段，后期需通过首尾过零点微淡化或小节尾音回绕（tail wrap）使 80.000 秒结尾衔接第 0.000 秒时听感如连续演奏一般，无节奏跳跃、和声突兀或咔哒爆音。不拆单独 `intro` / `outro`。

* **自适应与交互要求**：单一静态无缝循环版本。当前无需分轨或战斗状态切换，只需在自身编曲频谱上长期温和让渡空间，即可兼容引擎内 `AudioManager` 对 `bgm`、`amb` 与 `sfx` 三个音频层的独立混音调节。

## 8. 完整生成提示词

### 中文完整正向提示词（可直接提交）



```
这是一首用于手机治愈系慢节奏田园建造游戏的无缝循环纯音乐背景配乐。整体采用温暖松弛的原声室内乐田园民谣风格（Acoustic Chamber Pastoral），严格恒速 72 BPM、4/4 拍、F 大调并带有温暖柔润的五声旋律色彩，总时长 80 秒（24 小节）。配器克制精简且质地温润：以指腹轻拨的尼龙弦古典木吉他分解和弦与加装弱音毛毡的温和立式钢琴作为核心铺底，搭配中低音区软毛毡锤敲击的木质马林巴单音涟漪、轻缓温暖的大提琴拨弦与薄透的大提琴弱奏长音，以及下半段极少量温柔气声的中音木质竖笛点缀。全曲完全不使用架子鼓、电子鼓、金属铙钹、铁琴、高音尖锐风铃或任何高频合成音色；编曲留白充分（预留超过三分之一的呼吸空间），乐句温和交错而不拥挤抢拍；整体音色采用近场温暖木屋拾音质感，能量重心集中在温和饱满的中低频，高频 2.5 kHz 以上自然温顺滚降，确保丝滑耐听、毫无毛刺与嘈杂感。前 4 小节轻柔分解引入，5 至 12 小节展示简洁恬静的田园主题，13 至 20 小节木笛与大提琴略微铺展暖意，21 至 24 小节乐器温和抽离并在 C6sus4 柔和过渡和弦处保持流畅连贯，顺滑衔接回第 0 秒开头形成无缝循环。纯器乐演奏，不得出现人声、念白、合唱或含歌词的声音。
```

### 英文版 generation\_prompt（适用于英文优先或未指定模型）



```
An 80-second seamless-looping instrumental pastoral soundtrack for a cozy, slow-paced mobile village-building game, strictly steady at 72 BPM in 4/4 time and F Major with gentle pentatonic warmth across 24 bars. The style is intimate acoustic chamber folk with a deeply relaxed, warm, and unhurried countryside mood—zero tension, zero harshness, and generous rhythmic breathing room (around 40% open space in the phrasing). Instrumentation is strictly soft and wood-toned: fingerpicked nylon-string acoustic guitar arpeggios, muted warm felt upright piano chords in the low-mid register, gentle soft-mallet wooden marimba ripples, warm cello pizzicato anchoring beats 1 and 3 with subtle low-register arco cello sustain, and a sparse, breathy mid-register wooden flute entering gently during bars 13 to 20 before fading back out. Absolutely no drums, no percussion kits, no cymbals, no glockenspiel, no metallic chimes, and no bright or harsh synthesizers. Mix profile features an intimate warm wooden-room tone with soft high-frequency roll-off above 2.5 kHz to stay silky smooth and leave clear headroom for gentle brook ambience and soft UI sound effects. Structural arc: bars 1–4 soft piano/nylon guitar breathing intro, bars 5–12 calm melodic dialogue, bars 13–20 gentle warm swell with soft wooden flute, bars 21–24 thinning back to nylon guitar over a smooth C6sus4 turnaround chord with continuous gentle tail energy ready to loop seamlessly back into bar 1 without abrupt cadence or silence. Purely instrumental: no vocals, no spoken word, no choir, no humming, no lyrics.
```

## 9. 负面提示词与禁止事项



* **排除声音与元素**：人声、念白、合唱、哼唱、采样人声、歌词、架子鼓、军鼓、电子节拍、Trap 碎拍、金属铙钹、沙锤高频碎响、清脆金属风铃、铁琴（Glockenspiel）、尖锐高频卡林巴、电吉他失真、刺耳锯齿波 / 方波合成器、铜管齐奏、紧张交响急奏、不协和半音碰撞、密集高频音符堆砌。

* **排除混音与技术缺陷**：持续底噪或嘶声、电子啸叫与金属共鸣峰（2–6 kHz 刺耳谐振）、过度砖墙限幅压缩导致的喘息泵浦感、削波爆音（0 dBFS）、突兀断音终止、开头或结尾超过 50 ms 的无意义纯静音、循环节点节拍断裂或爆响咔哒声。

* **冲突检查声明**：已核对本节所有排除项与第 4、6、8 节正向规格一致（纯原声木质室内乐、严格无鼓无金属高音、72 BPM 恒速 24 小节平滑无缝衔接、纯器乐无人声），不存在自相矛盾的要求。

## 10. 技术交付规格



| 规格项       | 源文件（Master）                                   | 运行时文件（Runtime）                                                             |
| --------- | --------------------------------------------- | -------------------------------------------------------------------------- |
| 文件格式      | `WAV（无压缩 PCM）`                                | `OGG Vorbis`（匹配 Godot 4.7.2 `AudioStreamOggVorbis`）                        |
| 采样率       | `48000 Hz`                                    | `44100 Hz`（与项目现行 `AudioManager` / 音频管线保持一致，或保持 `48000 Hz` 统一）              |
| 位深 / 比特率  | `24-bit PCM`                                  | `128–160 kbps VBR / Quality 5`（清晰保留木质柔润瞬态且兼顾 Android 包体体积）                 |
| 声道        | `Stereo（双声道，自然微宽木吉他/钢琴声像）`                    | `Stereo`                                                                   |
| 响度与峰值规范   | `-18.0 LUFS（±1.0 LU）/ True Peak <= -1.5 dBTP` | `-18.0 LUFS / True Peak <= -1.5 dBTP`（保守留白响度，防止叠加环境音与 SFX 刺耳）              |
| 首尾静默与淡入淡出 | 首尾零额外纯静默；保留微弱连续拨弦 / 混响衔接尾                     | 同左                                                                         |
| 循环点精度     | 精确至第 24 小节末拍边界（80.000 秒整数长度），过零点衔接无咔哒声        | 在 Godot 4.7.2 中启用 `(stream as AudioStreamOggVorbis).loop = true` 并真机试听过点顺畅 |

### 后期处理要求（模型单次生成无法直接保证，须人工 / 脚本处理）



1. **格式与采样率标准化**：将模型输出音频导入 DAW 或经 `ffmpeg` 转码校准至 `48000 Hz / 24-bit WAV` 母带文件。

2. **高频柔化与频谱清理（关键治本步骤）**：对母带检查频谱 —— 用高通滤波轻切 `45 Hz` 以下无用极低频隆隆声；若 `2.5 kHz–8 kHz` 仍存在模型残余颗粒感或亮度过强，柔和施加 `-2 dB` 至 `-3 dB` 宽 Q 值搁架衰减，并确保 `6 kHz` 以上平缓柔和。

3. **小节严格修剪与尾音回绕（Tail Wrap）**：在 DAW 中按 `72 BPM / 4/4` 节拍网格精准捕捉 24 个完整小节（或依实际稳定拍速换算整 16/24 小节采样长度），把多出的最后 1–2 秒自然残响叠回至音频开头第 0 秒位置并核对过零点，制作零咔哒声、节奏不断裂的真无缝循环。

4. **响度与峰值归一化**：测量并标准化至约 `-18.0 LUFS` 与 True Peak `<= -1.5 dBTP`。

5. **运行时转码与引擎验证**：使用 `ffmpeg` 重采样并编码为 `bgm_village_pastoral_loop_main_v01.ogg`，并在 Godot 4.7.2 中同步打开旧溪流环境音试听验证无失真与谐波冲突。

## 11. 交付物与变体



| 序号 | 交付物角色          | 目标文件名                                          | 目标路径                                                                                                 | 状态                            |
| -- | -------------- | ---------------------------------------------- | ---------------------------------------------------------------------------------------------------- | ----------------------------- |
| 1  | 提示词规格文档        | `bgm_village_pastoral_loop_main_v01_prompt.md` | `D:\Code\project\windbreath_village\docs\audio_prompts\bgm_village_pastoral_loop_main_v01_prompt.md` | 已写入                           |
| 2  | 主循环音频（母带源文件）   | `bgm_village_pastoral_loop_main_v01.wav`       | `D:\Code\project\windbreath_village\assets\audio\source\bgm_village_pastoral_loop_main_v01.wav`      | 待生成    |
| 3  | 主循环音频（游戏运行时文件） | `bgm_village_pastoral_loop_main_v01.ogg`       | `D:\Code\project\windbreath_village\assets\audio\bgm\bgm_village_pastoral_loop_main_v01.ogg`         | 待生成与转码 |

## 12. 验收标准

### 自动检查



* [ ] 源文件与运行时文件主命名严格符合小写 ASCII + 数字 + 下划线规则（`bgm_village_pastoral_loop_main_v01`）

* [ ] 文件保存在约定目录且非空、完整未损坏，可被 Godot 4.7.2 无报错导入为 `AudioStreamOggVorbis`

* [ ] 格式、采样率（源文件 `48000 Hz` / 24-bit WAV；运行时 `44100 Hz` OGG Vorbis）及双声道规格与第 10 节一致

* [ ] 实际运行时长严格对齐整数小节节拍（`72 BPM / 24 小节 ≈ 80.00 秒`，误差符合网格对齐后无缝要求）

* [ ] 峰值电平未超过 `-1.5 dBTP`（零 `0 dBFS` 削波），整体响度位于 `-18.0 ± 1.0 LUFS`

* [ ] 开头及结尾无超过 `50 ms` 的非预期纯静默段

### 人工听审



* [ ] 风格、温暖木质音色与缓慢舒展呼吸感完全贴合《风息村落物语》治愈系慢节奏定位

* [ ] 在手机外放与入耳式耳机下连续播放至少 3 次完整循环（4 分钟以上），完全无当前版本出现的刺耳感、金属泛音啸叫或烦躁机械重复感

* [ ] 循环衔接点在自然听感下流畅连贯，无节拍少拍 / 多拍、和声突兀跳变或 `pop/click` 爆音

* [ ] 与游戏内溪流白噪音及 10 个木质 / 五声调 UI、落子、协同音效同时播放时层次分明、互不打架或浑浊糊成一团

* [ ] 全曲无明显 AI 音频常见水声伪影、声音骤变、底噪嗡鸣或结构突然崩塌

## 13. 假设与待确认事项



* **已核对的现有工程事实与 “嘈杂刺耳” 根因提示**：


  * 经核查 `D:\Code\project\windbreath_village\tools\generate_audio.py` 与 `src\autoload\AudioManager.gd`，当前背景音是由 NumPy 叠加的 16 秒短正弦波音色与 FFT 噪声组成；且另有一条可选环境音 `amb_rain_chime_loop.ogg` 会在雨天白噪音中定时敲响 `C 大调高音合成钟琴（最高 1046.5 Hz）`，同时 `amb_brook_loop.ogg` 含有持续 4.2 kHz 频段水声噪声与高频脉冲水滴（`720–1450 Hz`）。当三条合成音轨叠加游戏内高频提示音同时发声时，容易互相打架并造成刺耳和混乱感。

  * **联动建议**：使用本提示词生成新主配乐后，建议顺带重新审视 `amb_brook_loop`（高切 2.5 kHz 以上过于尖锐的水流高频）与 `amb_rain_chime_loop`（移除合成钟琴、保留纯柔和细雨，或将雨铃调性改至与 F 大调兼容的极轻低音共鸣，避免后续音轨冲突）。

* **项目缺失信息**：尚未指定具体使用的外部 AI 音乐生成平台与模型版本（例如 Suno / Udio / ElevenLabs Music / Stable Audio）；文档中已同时提供中文描述提示词与通用英文 `generation_prompt` 以便跨平台直接投喂。

* **采用的保守默认值**：


  * 按高质量游戏制作保守标准设定母带为 `48000 Hz / 24-bit WAV`、运行时为 `44100 Hz` OGG Vorbis；

  * 将集成响度保守压低至 `-18.0 LUFS`（常见单曲常为 -12 至 -14 LUFS），以彻底优先保证手机多轨混音时的柔和度与长时间耐听度；

  * 全曲限定纯器乐无人声、`72 BPM`、`F Major`、`80 秒 / 24 小节` 无缝循环。

* **目标模型能力限制**：当前主流音乐生成模型在单次推理时**无法稳定做到严格对齐第 24 小节网格的采样级无缝循环，也难以精准卡死特定 LUFS 响度与完美柔和的高频滚降曲线**；因此可能需要抽卡 2–4 次挑选音色最干净温暖的片段，并严格依赖第 10 节「后期处理要求」手动完成。

* **人工后期处理依赖**：后期必须在 DAW 或 `ffmpeg` 中完成真实无缝循环剪辑（Tail Wrap）、2.5–6 kHz 温和滚降修饰、响度标准化与 OGG 转码；转码完成后如采用新文件名 `bgm_village_pastoral_loop_main_v01.ogg`，还需在 `src/autoload/AudioManager.gd` 中更新加载路径或直接覆盖替换运行路径 `bgm_pastoral_loop.ogg` 并做一轮实听验收。

* **商用授权与许可确认**：正式接入游戏并对外分发 APK / 安装包前，请确认你所使用 AI 音乐生成服务对应的付费订阅档位是否授予商业发行版权与衍生剪辑使用许可。