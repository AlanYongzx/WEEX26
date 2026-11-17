# B4 口试（L1_3）：我们如何建模港口排放的人体健康影响 — 问题 a–e 的完整回答

> 用法：中文是解释，**« … »** 和公式是黑板上用的法语与方程。数值全部来自本组模型，注明了验证状态。
> 依据：`claude/B4_schema_bloc_modele_complet_zh.md`（定稿方框图的完整模型，`b4_schema_model.m` 已在 MATLAB R2024b 中运行、23 项自检通过）、`L1_2_B4_IA.m`（区域输运）、`claude/B4_deposition_surface_calc_zh.md`（200 m → 地表）。

## 0. 一句话回答

**B4 港口每年排放 109 t PM10 和 328 t COVNM；我们把污染物从"排放 → 大气 → 地表 → 作物 / 呼吸 → 人体"逐段定量，得到健康损害约 2.4 DALY/yr，其中 PM10 占 88%，吸入和经作物摄入各占 PM10 损害的一半。**

« Notre port émet 109 t/an de PM10 et 328 t/an de COVNM. Nous suivons le polluant de la source jusqu'à l'homme, compartiment par compartiment, et nous obtenons environ 2,4 DALY par an, dont 88 % dus aux PM10. »

| 结果 | 验证状态 |
|---|---|
| 源网格箱模型、沉降、作物链、吸入、COVNM 降解、臭氧上限 | 已在 MATLAB 中运行，23 项自检通过 |
| 区域输运（沉降去向、区域吸入、区域损害） | 用 Python 移植版在真实年风场上运行；`L1_2_B4_IA.m` 的 MATLAB 运行结果需对照 |
| 2.4 DALY/yr 的绝对值 | 理论预测；取决于 USEtox 系数表的用法（见 e） |

---

## a. 介质划分与介质间的转移现象

### a.1 方框图（只放能定量的环节）

```
                        ┌──────────────────────────────────────┐
  SOURCE (map.xlsx)     │  ATMOSPHÈRE  (couche de mélange H)   │
  Port B4, maille 32_27 │  72 × 33 mailles de 70 km            │
  Q_PM10  = 109 t/an ──►│  C(x,y) [kg/m³]                      │──► sortie du domaine
  Q_COVNM = 328 t/an    │  advection (vent U,V)                │    PM10 31 %, COVNM 41 %
                        └───┬───────────────┬──────────────┬───┘
                            │               │              │
           ┌────────────────┘               │              └───────────────┐
           │ dépôt humide 93 %              │ air au sol                   │ OH (COVNM)
           │ dépôt sec     7 %              │ C_g ≈ C                      │ k = 4×10⁻⁶ s⁻¹
           ▼  (PM10 seulement)              ▼                              ▼
  ┌───────────────────────────────┐   ┌──────────────┐               dégradé
  │ SURFACES  (PM10, t/an)        │   │ INHALATION   │               194 t/an
  │ mer               42,2        │   │ BR = 13 m³/j │
  │ sols naturels     19,0        │   │ 0,060 kg/an  │
  │ sols agricoles    11,3 ───┐   │   └──────┬───────┘
  │ eaux continentales 2,1 ─┐ │   │          │
  └─────────────────────────┼─┼───┘          │
            irrigation 1,7 %│ │              │
                            ▼ ▼              │
                  ┌────────────────────┐     │
                  │ VÉGÉTAUX           │     │
                  │ feuilles  1,66 %   │     │
                  │ racines  (BCF)     │     │
                  └─────────┬──────────┘     │
                            ▼                ▼
                  ┌────────────────┐   ┌───────────────────────────┐
                  │ INGESTION      │──►│ IMPACT SANTÉ (USEtox)     │
                  │ 191 kg/an      │   │ D = Σ CF·M·P/10⁹          │
                  └────────────────┘   │ 2,4 DALY/an               │
                                       └───────────────────────────┘
```

数值为 PM10 全区域年量（区域输运模型）；COVNM 不沉降，只有"大气 → 吸入"和"大气 → OH 降解"两个出口。

### a.2 各介质用什么量表示

| 介质 | 模型中的量 | 单位 | 数据来源 |
|---|---|---|---|
| 源 | 排放量 $Q$，连续、恒定 | kg/yr → kg/s | `map.xlsx` |
| 大气（混合层） | 每个网格的柱平均浓度 $C_j=M_j/(A H)$ | kg/m³ | 输运模型 |
| 近地面空气（2 m） | $C_g=(0.96\text{–}1.00)\,C$，取 $C_g=C$ | kg/m³ | 近地层通量守恒 |
| 农业土壤、自然土壤、淡水、海 | 年沉降质量 $m_i$，按土地利用比例分配 | kg/yr | `map.xlsx` 土地利用列 |
| 作物 | 叶面截留量 + 根系吸收量 | kg/yr | 第 b.3 节 |
| 人 | 吸入量 $I_{inh}$、摄入量 $I_{ing}$ | kg/yr | 呼吸量、产量 |
| 健康 | 损害 $D$ | DALY/yr | USEtox 表征因子 |

### a.3 支配每个箭头的现象与速率

| 箭头 | 支配现象 | 定量表达 | B4 数值 |
|---|---|---|---|
| 源 → 大气 | 排放并在混合层内混匀 | $Q/(AH)$ | $3.5\times10^{-3}$ kg/s（PM10） |
| 网格 → 网格 | 平流（风）+ 湍流扩散 | $\nabla\cdot(\mathbf{u}C)$，$K\nabla^{2}C$ | $U=5.85$ m/s，$K=100$ m²/s |
| 大气 → 地表（干） | 重力沉降 + 湍流输送 + 近地层扩散 | $k_{sec}=v_d/H$ | $1.0\times10^{-6}$ s⁻¹ |
| 大气 → 地表（湿） | 雨滴碰撞捕获颗粒（云下冲刷） | $k_{pluie}=CE\cdot I/H$，间歇平均 | 雨中 $7.2\times10^{-5}$ s⁻¹；平均 $\bar k=8.2\times10^{-6}$ s⁻¹ |
| 大气 → 降解（COVNM） | OH 自由基夺氢 | $k=k_{OH}[\text{OH}]$ | $4\times10^{-6}$ s⁻¹ |
| 地表 → 作物 | 叶面截留（主）、根系吸收（次） | $f_{fol}$，$BCF$ | 1.66%；根系第 1 年小 250 倍 |
| 淡水 → 农田 | 灌溉 | $f_{irr}$ | 1.7%，可忽略 |
| 空气 → 人 | 呼吸 | $BR\sum_j C_j P_j$ | $BR=13$ m³/d |
| 作物 → 人 | 食用（生产量法） | 收获量全部被食用 | — |
| 剂量 → 健康 | 线性无阈剂量–效应 | USEtox $CF$ | PM10 $CF_{tot}=1.096$ |

« Chaque flèche du schéma correspond à un taux que nous savons calculer. Nous n'avons gardé que ces flèches-là. »

**没画进图的东西及理由**（只放能算的）：臭氧（无 NOx 数据）、海产品（海洋网格人口为 0）、饮用水、畜牧、沉积物（方框图无此箭头，USEtox 系数已隐含）。

---

## b. 数值模拟方法

### b.1 总体策略：三层计算，每一层都能独立检验

| 层 | 内容 | 方法 | 代码 |
|---|---|---|---|
| 1 | 区域大气输运 | 二维有限体积，显式迎风格式，真实逐 3 h 年风场 | `L1_2_B4_IA.m` |
| 2 | 源网格箱模型 | 解析稳态解，用来校验第 1 层 | `b4_schema_model.m` |
| 3 | 地表、作物、暴露、健康 | 在第 1 层的年均浓度和沉降场上做后处理 | `b4_schema_model.m`、`B4_deposition_surface.m` |

### b.2 大气输运方程（第 1 层）

每个网格的空气柱写质量守恒：

$$
\frac{\partial C}{\partial t} + \nabla\cdot(\mathbf{u}\,C) = K\,\nabla^{2}C + \frac{Q}{A\,H} - k\,C
$$

| 符号 | 含义 | 单位 | 取值与来源 |
|---|---|---|---|
| $C$ | 混合层柱平均浓度 | kg/m³ | 未知量 |
| $\mathbf{u}=(u_x,u_y)$ | 200 m 风速，$u_x$ 向东、$u_y$ 向北为正 | m/s | 风场文件，逐 3 h |
| $K$ | 水平湍流扩散系数 | m²/s | 100，流体力学课第 9 章 $D_t\sim LU$ |
| $Q$ | 源强 | kg/s | `map.xlsx` |
| $A,\ H$ | 网格面积，混合层高度 | m²，m | $4.919\times10^{9}$；1000（USEtox 表 10） |
| $k$ | 一级清除速率（沉降或降解） | s⁻¹ | 见 a.3 |

离散化：
- **空间**：直接用地图的 72 × 33 个网格（有限体积），未知量是每个网格的质量 $M_j$ [kg]。
- **平流**：迎风格式，通过一个面的通量 = 面上风速 × 上风侧网格质量 ÷ $\Delta x$。
- **时间**：显式欧拉，CFL 条件
$$\Delta t\left(\frac{|u_x|}{\Delta x}+\frac{|u_y|}{\Delta y}\right)\le0.8$$
  每个 3 h 风场时段最多分成 9 个子步。
- **汇项**：精确指数衰减 $M\leftarrow M\,e^{-k\Delta t}$，保证质量非负。
- **边界条件**：区域边界自由流出，流入空气干净（$C=0$）。
- **初始条件**：$C=0$，预跑 20 天后统计完整一年，取年均浓度和年沉降量。

### b.3 地表与作物（第 3 层）

**200 m → 地表通量**（干湿交替平均，USEtox 式 91）：

$$
F=\bar k\,H\,C,\qquad
\bar k=\left[\frac{t_{dry}}{T k_{sec}}+\frac{t_{wet}}{T k_{pluie}}-\frac{1}{T}\left(\frac{1}{k_{pluie}}-\frac{1}{k_{sec}}\right)^{2}\frac{(1-e^{-k_{sec}t_{dry}})(1-e^{-k_{pluie}t_{wet}})}{1-e^{-k_{sec}t_{dry}-k_{pluie}t_{wet}}}\right]^{-1}
$$

$T=80$ h 为干湿周期；下雨时间占比 $t_{wet}/T$ = 年均降水强度 ÷ 雨中雨强 = 0.16（B4）。

**分配到地表**：$m_i=F\,A\,f_i$，$f_i$ 为 `map.xlsx` 中各土地利用比例。

**作物叶面途径**（截留后被雨水冲刷，收获时积分）：

$$
f_{fol}=\frac{n}{365}\,f_{int}\,\frac{1-e^{-k_w T_c}}{k_w}\,f_{food}=1.66\,\%
$$

$n=2$ 季/年，$T_c=120$ d，$f_{int}=0.3$，$k_w=\ln2/14\ \text{d}^{-1}$，$f_{food}=0.5$（均为假设，见 e）。

**根系途径**：$I_{root}=BCF\cdot M_{dep,agri}\cdot\dfrac{t\,Y}{h\,\rho_{sol}}$，$BCF=0.01$，$Y=1$ kg/m²/yr，$h=0.1$ m，$\rho_{sol}=1500$ kg/m³。

### b.4 暴露与健康

$$
I_{inh}=BR\sum_j C_j P_j,\qquad
D=\sum_j CF_{tot}\cdot M^{eq}_j\cdot\frac{f_{urb}P^{urb}_j+f_{rur}P^{rur}_j}{10^{9}},\qquad
M^{eq}_j=Q\,\frac{\bar C_j}{\bar C_{src}}
$$

$CF_{tot}$：USEtox 总表征因子，单位 DALY/kg（对 $10^{9}$ 人）；$f_{urb},f_{rur}$：排放到城市/农村空气的份额；$M^{eq}_j$：把网格 $j$ 的浓度折算成"等效排放量"。对源网格就是直接套 USEtox；对下风向网格按浓度比例折算。

### b.5 验证

| 检验 | 结果 |
|---|---|
| 质量守恒：排放 = 沉降 + 流出 + 存量变化 | 误差 $2\times10^{-13}$ |
| 质量非负 | 全程满足 |
| 源网格浓度：输运模型 vs 解析箱模型 | 0.0075 vs 0.0077 µg/m³，差 3% |
| 后处理沉降 vs 输运模型内部统计 | 74.5 vs 75.0 t/yr，差 0.7% |
| MATLAB vs 独立 Python 实现（12 项） | 相对误差 ≤ $2\times10^{-4}$ |
| 吸入损害：USEtox vs 流行病学（不用 USEtox） | 1.05 vs 3.5 (0.9–11) DALY/yr，在范围内 |

« On résout l'équation d'advection-diffusion par volumes finis, schéma amont explicite, avec la condition CFL. Aux bords, le polluant sort librement et l'air entrant est propre. On vérifie la conservation de la masse et on compare la maille source à un modèle boîte analytique. »

---

## c. 每项选择的依据

### c.1 为什么 PM10 优先于 COVNM

$$
\frac{Q_{PM}\,CF_{PM}\,f_{PM}}{Q_{COV}\,CF_{COV}\,f_{COV}}=\frac{1.09\times10^{5}\times1.096\times0.0114}{3.28\times10^{5}\times0.0538\times0.0107}\approx7
$$

COVNM 质量是 PM10 的 3 倍，但单位质量危害小约 20 倍。来源：`map.xlsx`、`infos_polluants`（USEtox 表）。

### c.2 大气：为什么要做二维区域输运，而不是只算源网格

1. **平流远大于扩散**（网格 Péclet 数）：
$$Pe=\frac{U\,\Delta x}{K}=\frac{5.85\times7.01\times10^{4}}{100}\approx4\times10^{3}\gg1$$
   风决定污染物去哪里，扩散只是次要项。
2. **污染物跨越很多网格**（输运距离）：
$$L=\frac{U}{\bar k}=\frac{5.85}{8.17\times10^{-6}}\approx700\ \text{km}\approx10\ \text{个网格}$$
3. **源网格里通风远大于清除**：
$$\frac{U\,\Delta x}{\bar k\,A}=\frac{4.10\times10^{5}}{4.02\times10^{4}}\approx10$$
   只有 9% 的 PM10 在源网格内沉降，91% 被风带走。模拟结果也印证：约 60% 的损害发生在源网格以外。

来源：风场文件（年均风速）、流体力学课第 9 章（$D_t\sim LU$）、USEtox 表 10。

### c.3 大气 → 地表：为什么湿沉降主导

$$
\frac{k_{pluie}}{k_{sec}}=\frac{7.2\times10^{-5}}{1.0\times10^{-6}}=72
$$

即使只有 16% 的时间下雨，湿沉降仍占 93%。B4 网格年降水 1821 mm，是多雨的热带地区。所以颗粒粒径分布虽然未知（干沉降速度可差 100 倍），对总沉降影响不大：$v_d$ 增大 5 倍，总沉降只增加约 17%。

为什么用干湿交替公式而不是简单平均：一场雨（约 12.8 h）就能洗掉 96% 的颗粒，雨后半段已无可洗，简单平均会高估约 50%。来源：USEtox 文档式 91、98–100；课程资料《précipitations atmosphère pollution》1.2.2 节。

### c.4 200 m → 近地面：为什么取 $C_g=C$

近地层内向下通量守恒：

$$
\frac{C_g}{C_{200}}=\frac{v_d}{v_s}+\left(1-\frac{v_d}{v_s}\right)e^{\,v_s r_a'},\qquad r_a'=\frac{\ln(200/2)}{\kappa u_*}=37\ \text{s/m}
$$

结果 0.96–1.00：湍流混合快、地面吸收慢，垂直方向几乎没有梯度。

### c.5 地表 → 人：为什么叶面途径比土壤途径重要

方框图原来画的是"沉降 → 土壤 → 植物"。计算后发现颗粒直接落在作物叶面才是主体：根系途径第 1 年小 250 倍，土壤累积 30 年后仍小 8 倍。灌溉箭头只增加 1.7%，保留在图上但数值可忽略。来源：本组模型（作物参数是假设，见 e）。

### c.6 化学：为什么只算 OH 降解、不算臭氧

1. `map.xlsx` 中 B4 只有 PM10 和 COVNM，没有 NOx；臭氧生成需要 NO。
2. USEtox 表没有 O₃ 的表征因子，算出也无法折算成 DALY。
3. 上限估算：假设 NOx 充足、按最大增量反应活性 $MIR\approx3$ g O₃/g COV（凭记忆，需查 Carter 原表），源网格臭氧增量 ≤ 0.0035 µg/m³，约为背景臭氧的万分之一。

$$
\text{RH}+\text{OH}^{\bullet}\rightarrow\text{R}^{\bullet}+\text{H}_2\text{O},\qquad k=k_{OH}[\text{OH}]=4\times10^{-12}\times10^{6}=4\times10^{-6}\ \text{s}^{-1}
$$

寿命 2.9 天。全区域每年降解 194 t（59%）。

### c.7 健康：为什么用 USEtox，以及系数表怎么用

- 课程设定：输运与沉降用确定性方法，健康影响用统计方法（USEtox 表征因子）。
- 我们的解读（A）：排放到某介质的系数 = $CF_{tot}\times$ 该介质份额。另一种解读（B）直接用 $CF_{tot}$，结果大约 96 倍。
- **独立检验**：用流行病学浓度–反应函数（Chen & Hoek 2020，PM10 长期暴露 $RR=1.04$ / 10 µg/m³）重算吸入损害，得 3.5 DALY/yr（0.9–11）。解读 A 的 1.05 在范围内，解读 B 的 99.7 超出上限 9 倍。**流行病学检验支持 A。**

« Pour chaque choix, nous avons un nombre sans dimension ou un ordre de grandeur : Péclet pour l'advection, la longueur U/k pour le transport régional, le rapport des taux pour le dépôt humide, et un contrôle épidémiologique pour les facteurs USEtox. »

---

## d. 量纲自洽与数量级

### d.1 量纲

| 方程 | 量纲检查 |
|---|---|
| 输运方程各项 | $\nabla\cdot(\mathbf{u}C)$：$\dfrac{\text{m/s}\cdot\text{kg/m}^3}{\text{m}}$；$K\nabla^2C$：$\dfrac{\text{m}^2/\text{s}\cdot\text{kg/m}^3}{\text{m}^2}$；$\dfrac{Q}{AH}$：$\dfrac{\text{kg/s}}{\text{m}^3}$；$kC$：$\text{s}^{-1}\cdot\text{kg/m}^3$ → 都是 kg·m⁻³·s⁻¹ ✓ |
| 箱模型 $C=\dfrac{Q}{H(U\Delta x+kA)}$ | $\dfrac{\text{kg/s}}{\text{m}\cdot(\text{m}^2/\text{s})}=\text{kg/m}^3$ ✓ |
| 沉降通量 $F=\bar k H C$ | $\text{s}^{-1}\cdot\text{m}\cdot\text{kg/m}^3=\text{kg·m}^{-2}\text{s}^{-1}$ ✓ |
| 根系摄入 $BCF\cdot M\cdot\dfrac{tY}{h\rho}$ | $[-]\cdot\dfrac{\text{kg}}{\text{yr}}\cdot\dfrac{\text{yr}\cdot\text{kg·m}^{-2}\text{yr}^{-1}}{\text{m}\cdot\text{kg·m}^{-3}}=\text{kg/yr}$ ✓ |
| 吸入 $BR\sum C P$ | $\dfrac{\text{m}^3}{\text{人·d}}\cdot\dfrac{\text{kg}}{\text{m}^3}\cdot\text{人}=\text{kg/d}$ ✓ |
| 损害 $CF\cdot M\cdot P/10^9$ | $\dfrac{\text{DALY}}{\text{kg}\cdot10^{9}\text{人}}\cdot\dfrac{\text{kg}}{\text{yr}}\cdot\dfrac{\text{人}}{10^{9}}\cdot10^{9}$ → DALY/yr ✓ |

### d.2 数量级：手算与已知值的对照

| 量 | 我们的值 | 对照 | 判断 |
|---|---|---|---|
| 源网格 PM10 浓度 | 0.0075 µg/m³（箱模型手算 0.0077） | 城市 PM10 背景几十 µg/m³ | 合理：109 t/yr 稀释在每秒 $U\Delta x H=4\times10^{8}$ m³ 的空气里，是 70 km 网格平均的**增量** |
| $v_d=10^{-3}$ m/s | USEtox 默认 | Stokes：$v_s=\dfrac{\rho_p d^2 g}{18\mu}=\dfrac{1500\times(5\times10^{-6})^2\times9.81}{18\times1.8\times10^{-5}}=1.1\times10^{-3}$ m/s | 相当于 5 µm 颗粒 ✓ |
| PM10 大气寿命 | 1.4 天 | 气溶胶寿命通常为几天到一周；多雨地区偏短 | 合理（文献值凭记忆，未核对） |
| COVNM 寿命 | 2.9 天 | 甲苯约 2 天，丙烷约 10 天（OH 速率常数凭记忆，需核对 IUPAC） | 在混合物范围内 |
| 吸入分数 $iF_{inh}$ | $5.5\times10^{-7}$ | Humbert 2011（USEtox 引用）：农村约 $10^{-6}$、城市约 $10^{-5}$ 量级（凭记忆，需查原文） | 偏低，原因见 e：70 km 网格摊平、烟羽吹向海面 |
| 吸入效应 $EF_{inh}$ | 17.6 DALY/kg 吸入 | USEtox/Humbert 一类研究的 PM2.5 值在几十 DALY/kg 量级（凭记忆） | 同量级 |
| 吸入损害 | 1.05 DALY/yr | 流行病学独立估算 3.5 (0.9–11) | 在范围内 ✓ |

« Nos équations sont homogènes. Pour les ordres de grandeur, le modèle boîte calculé à la main donne la même concentration que la simulation à 3 % près, et le contrôle épidémiologique donne le même ordre de grandeur que USEtox. »

---

## e. 优势与局限

### e.1 优势

1. **全链条定量**：每个箭头都有速率、单位和来源，从 kg/yr 一路算到 DALY/yr。
2. **真实气象**：用逐 3 h 的年风场，而不是一个平均风向。
3. **多层自检**：质量守恒到 $10^{-13}$；解析箱模型、Python 独立实现、流行病学方法三种交叉检验。
4. **线性**：对排放量线性、对多个源可叠加，适合第二阶段的多源场景。
5. **只依赖 `map.xlsx` 也能运行**：没有风场文件时用内置风玫瑰（结果偏高约 30%）。
6. **找出了方框图本身的问题**：叶面途径才是摄入主体，这是计算后得出的修正。

### e.2 局限（按影响大小排序）

| # | 局限 | 方向与大小 | 怎么改进 |
|---|---|---|---|
| 1 | USEtox 系数表用法未经官方确认 | 另一种解读大约 96 倍；流行病学检验已排除 | 向顾问 Dubreuil 确认 |
| 2 | 70 km 网格 + 瞬时混匀到 1000 m | 港口附近几公里的高浓度被摊平；源网格近地面浓度是**下限**（垂直混匀需 1–14 h，穿过网格只需 3.3 h） | 源网格内加高斯烟羽子模型 |
| 3 | 作物参数（截留 0.3、冲刷半衰期 14 d、两熟、可食比例 0.5）是假设 | 摄入量 ×0.34 到 ×1.9；不改变 USEtox 损害 | 查原始文献 |
| 4 | 迎风格式的数值扩散 $\approx U\Delta x/2\approx2\times10^{5}$ m²/s，远大于物理扩散 | 烟羽被人为展宽 | 二阶格式 + 通量限制器 |
| 5 | 风场与地图坐标不一致，按网格序号对应 | 损害变化 14% | 向顾问 Maffioli 确认 |
| 6 | 臭氧、二次有机气溶胶未计 | COVNM 影响低估；臭氧上限 0.0035 µg/m³ | 需要 NOx 数据 |
| 7 | 海产品、饮用水、畜牧未计；42 t/yr 落海不对应受体 | 摄入低估 | 若有渔业数据可加 |
| 8 | COVNM 当作单一物质（寿命 2.9 天） | 组分寿命从几小时到几个月 | 按组分拆分 |
| 9 | 室内 = 室外、人口不流动、网格内人口均匀 | 室内外比约 0.5–0.7 使吸入高估，与第 2 条低估部分抵消 | — |

« Notre principale incertitude n'est pas le transport — à ± 35 % — mais l'interprétation des facteurs USEtox. Le contrôle épidémiologique nous permet d'éliminer l'interprétation qui donnerait 100 fois plus. La deuxième limite est la maille de 70 km : près du port, l'exposition est sous-estimée. »

---

## 附：评审追问时的速答（法语）

| 问题 | 回答 |
|---|---|
| Pourquoi négliger la diffusion ? | $Pe\approx4000$ à l'échelle de la maille ; on garde le terme pour le vérifier. |
| Conditions aux limites ? | Sortie libre, air entrant propre, $C=0$ au départ, 20 jours de mise en régime. |
| Pas de temps ? | Condition CFL $\le0{,}8$ ; jusqu'à 9 sous-pas par pas de vent de 3 h. |
| Pourquoi le dépôt humide domine ? | $k_{pluie}/k_{sec}=72$ ; même avec 16 % de temps de pluie, il fait 93 % du dépôt. |
| Et l'ozone ? | Pas de NOx dans les données, pas de facteur USEtox ; borne supérieure $0{,}0035$ µg/m³. |
| Pourquoi PM10 domine ? | 3 fois moins de masse, mais un facteur de caractérisation 20 fois plus grand. |
| Que vaut 2,4 DALY/an ? | 2,4 années de vie en bonne santé perdues par an dans la population exposée. |
| Résultat fiable ? | Transport à ± 35 % ; l'incertitude principale est le facteur USEtox, contrôlée par l'épidémiologie. |

## 来源

- 课程文件：`MODELISATION_USEtox_Documentation_DEPOL.pdf`（表 10，式 91、98–100）；`MODELISATION_infos_polluants_S6_2025-26.xlsx`；`MODELISATION_Chapitre9_FLE_TC1.pdf`；`MODELISATION__précipitations_atmosphère_pollution.pdf` 1.2.2 节；`map.xlsx`；风场文件 `Vent1AnFinal.mat`。
- Chen, J., Hoek, G. (2020). Long-term exposure to PM and all-cause and cause-specific mortality. *Environment International* 143:105974.
- 凭记忆、**未核对原文**的数值：气溶胶典型寿命、$[\text{OH}]\approx10^{6}$ cm⁻³、$k_{OH}$ 代表值、Carter MIR ≈ 3、Humbert 2011 的吸入分数与效应因子、作物截留与冲刷参数。口试中可以说"ordre de grandeur de la littérature"，写进报告前需查原文。
