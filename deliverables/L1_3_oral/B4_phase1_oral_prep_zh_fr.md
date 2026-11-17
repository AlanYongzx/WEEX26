# WEEX DEPOL 第一阶段 — B4 组周三口试准备（L1_3）与代码说明（L1_2）

> 配套文件：`L1_2_B4_IA.m`（周三 8:30 提交的单文件 Matlab 代码）。
> 口试形式：黑板讲解约 17 分钟，无资料、无电子设备，每个问题随机点一人。所以**全组 6 人都要能讲第 2、3、5 节**。
> 语言：解释用中文，黑板上要写的内容和建议说法给了法语。

---

## 0. 一句话结论与验证状态

**B4 港口每年排放 109 t PM10 和 328 t COVNM；按我们的模型，它造成的人体健康损害约为 2.4 DALY/年，其中 PM10 约占 88%，约 60% 的损害发生在源网格以外的下风向网格。**

| 内容 | 状态 |
|---|---|
| 模型算法与全部数值结果 | **已用 Python 移植版运行核对**（同一算法、同一数据：`map.xlsx` + `Vent1AnFinal.mat`） |
| `L1_2_B4_IA.m` 本身 | **仅静态检查**（括号、代码块配对、无非 ASCII 字符串）。我这里没有 MATLAB，**没有实际运行过**。交之前必须在你们电脑上 Run 一次 |
| 2.4 DALY/年这个绝对值 | **理论预测，量级不确定**：取决于 USEtox 系数表的用法（见第 6 节），最坏可差约 100 倍 |
| 沉降速率、混合层高度、呼吸量 | 取自课程提供的 USEtox 2.0 文档默认值 |
| COVNM 半衰期 2 天 | **假设，没有来源** |

**更正**：我在之前的回复和第一份梳理文档里，把 USEtox 表的列读错了一列——当时写的"排放到城市空气 0.035、农村空气 0.011"其实是"工业室内空气"和"城市空气"。正确值是：PM10 城市空气 0.0114、农村空气 0.0096；COVNM 城市空气 0.0107、农村空气 0.0080。已交的方框图只用了总系数，"PM10 约占 87%"的结论不受影响。

---

## 1. 核心结果（Python 移植版，年风场，按网格序号对应风场）

| 量 | PM10 | COVNM |
|---|---|---|
| 排放量 $Q$ | $1.09\times10^{5}$ kg/yr | $3.28\times10^{5}$ kg/yr |
| 源网格年均浓度（模拟） | 0.0075 µg/m³ | 0.024 µg/m³ |
| 源网格浓度（箱模型手算） | 0.0077 µg/m³ | 0.024 µg/m³ |
| 大气寿命 $1/k$ | 1.4 天 | 2.9 天 |
| 在区域内被清除的比例 | 69%（沉降） | 59%（降解） |
| 被风带出区域的比例 | 31% | 41% |
| 质量守恒误差 | $2\times10^{-13}$ | $5\times10^{-14}$ |
| 吸入分数 $iF$ | $5.5\times10^{-7}$ | $5.8\times10^{-7}$ |
| 损害，仅源网格 | 0.83 DALY/yr | 0.11 DALY/yr |
| 损害，全部网格 | **2.10 DALY/yr** | **0.28 DALY/yr** |
| 占总损害 | 88% | 12% |

PM10 的沉降去向：海洋 42 t/yr，自然土壤 19 t/yr，农业土壤 11 t/yr，淡水 2 t/yr；其中湿沉降约 86%。

![Python 参考运行的结果图](b4_phase1_maps_python_reference.png)

图：Python 参考运行（数值模拟，不是 Matlab 输出，也不是实测）。左：PM10 年均浓度；中：PM10 年沉降；右：每个网格的健康损害。红星为 B4 场址。主导风向是东风和东北风，所以烟羽主要向西和西南方向伸展，大部分落在海上。

**敏感性（PM10 全部网格的损害）**

| 改动 | 结果 | 相对基准 |
|---|---|---|
| 基准 | 2.10 DALY/yr | — |
| 风场按经纬度最近邻对应（而不是按序号） | 2.40 | +14% |
| 没有风场文件，用内置 16 扇区风玫瑰 | 2.72 | +30% |
| 干沉降速率 $v_d$ 从 $10^{-3}$ 改为 $5\times10^{-3}$ m/s | 1.74 | −17% |
| 只用 1 月份的风场 | 1.36 | −35% |
| USEtox 系数不乘"城市/农村空气"份额 | 约 200 | ×96 |

前四项说明输运模型的不确定度在 ±35% 以内；最后一项说明**真正决定量级的是毒理系数的用法**，这是周二必须问清的问题。

---

## 2. 黑板讲解脚本（约 6 分钟主讲 + 提问）

### 2.1 黑板上画的方框图（对应评审问题 a）

```
 Source B4            Atmosphère (couche de mélange H)            Population
┌───────────┐  Q   ┌──────────────────────────────┐  C_j   ┌───────────────────┐
│ Port      │─────►│ advection (vent) + diffusion │───────►│ exposition        │
│ PM10,COVNM│      │ M_j [kg] par cellule 70 km   │        │ C_j × Pop_j       │
└───────────┘      └───────┬───────────┬──────────┘        └─────────┬─────────┘
                           │ k_dép     │ k_dég                       │ CF USEtox
                           ▼           ▼                             ▼
                   Sols / mer /    Dégradation              Dommage [DALY/an]
                   eau douce       (COVNM)
```

建议的法语开场：
« Notre site est un port : il émet 109 tonnes de PM10 et 328 tonnes de COVNM par an. On suit le polluant dans trois compartiments : l'air, où il est transporté par le vent ; les surfaces, où il se dépose ; et la population, qui le respire. On ne garde que ce qu'on sait calculer. »

### 2.2 要写在黑板上的方程（对应问题 b）

**(1) 输运方程**，对每个网格的空气柱写质量守恒：

$$
\frac{\partial C}{\partial t} + \nabla\cdot(\mathbf{u}\,C) = K\,\nabla^{2}C + \frac{Q}{A\,H} - k\,C
$$

| 符号 | 含义 | 单位 | 取值与来源 |
|---|---|---|---|
| $C$ | 混合层内平均浓度 | kg/m³ | 未知量 |
| $\mathbf{u}=(u_x,u_y)$ | 风速，$u_x$ 向东为正，$u_y$ 向北为正 | m/s | 风场文件，200 m 高度，每 3 h |
| $K$ | 湍流扩散系数 | m²/s | 100，流体力学课第 9 章：$D_t\simeq L\times U$，10–100 |
| $Q$ | 源强 | kg/s | `map.xlsx`，PM10：$3.5\times10^{-3}$ |
| $A$ | 网格面积 | m² | $4.919\times10^{9}$ |
| $H$ | 混合层高度 | m | 1000，USEtox 表 10 |
| $k$ | 清除速率 | s⁻¹ | 见下 |

**(2) 清除速率**

$$
k_{sec} = \frac{v_d}{H} = \frac{10^{-3}}{10^{3}} = 10^{-6}\ \text{s}^{-1},\qquad
k_{pluie} = \frac{CE\cdot I_{pluie}}{H} = \frac{2\times10^{5}\times3.6\times10^{-7}}{10^{3}} = 7.2\times10^{-5}\ \text{s}^{-1}
$$

- $v_d$：气溶胶干沉降速率 [m/s]；$CE$：雨滴对气溶胶的收集效率 [-]；$I_{pluie}$：下雨时的雨强，1.3 mm/h。
- 雨是间歇的。按 USEtox 的做法，一个干湿周期 80 h，其中下雨时间占比等于"年降水量 ÷（1.3 mm/h × 全年）"。B4 网格年降水 1821 mm，下雨时间占 16%。
- 对干湿交替取平均（USEtox 式 91）后，B4 处 $k \approx 8.2\times10^{-6}$ s⁻¹，寿命 1.4 天。
- COVNM 是气体，不算沉降，只算一级降解：$k = \ln 2/t_{1/2}$，$t_{1/2}=2$ 天（假设）。

**(3) 健康损害**

$$
D = \sum_{j}\; CF_{tot}\cdot M^{eq}_{j}\cdot\frac{f_{urb}\,P^{urb}_{j} + f_{rur}\,P^{rur}_{j}}{10^{9}},
\qquad M^{eq}_{j} = Q\,\frac{\bar C_j}{\bar C_{src}}
$$

| 符号 | 含义 | 单位 |
|---|---|---|
| $D$ | 健康损害 | DALY/yr（伤残调整生命年） |
| $CF_{tot}$ | USEtox 总表征因子 | DALY/(kg·10⁹ 人)，PM10：1.096 |
| $f_{urb}, f_{rur}$ | 排放到城市空气、农村空气所占份额 | 无量纲，PM10：0.0114、0.0096 |
| $P^{urb}_j, P^{rur}_j$ | 网格 $j$ 的城市、农村人口 | 人 |
| $\bar C_j$ | 网格 $j$ 的年均浓度 | kg/m³ |
| $M^{eq}_j$ | 网格 $j$ 的"等效排放量" | kg/yr |

物理意义：USEtox 假设剂量与效应成正比、没有阈值，所以损害正比于"浓度 × 人口"。对源网格 $M^{eq}=Q$，就是直接套 USEtox；对其他网格，按它的浓度相对源网格浓度的比例折算。

独立于 USEtox 的物理量：吸入量 $I = BR\cdot\sum_j \bar C_j P_j$，$BR=13$ m³/天/人；吸入分数 $iF = I/Q$。

### 2.3 数值方法（对应问题 b，全组都要知道）

- **网格**：直接用地图的 72 × 33 个网格，边长 70 km，平面近似（风场说明里就是这样假设的）。
- **未知量**：每个网格空气柱里的污染物质量 $M$ [kg]，$C = M/(AH)$。
- **格式**：有限体积法，显式欧拉，迎风格式。穿过一个面的通量 = 面上风速 × 上风侧网格的质量 ÷ $\Delta x$。
- **时间步**：满足 CFL 条件 $\Delta t\,(|u_x|/\Delta x + |u_y|/\Delta y)\le 0.8$。风最大 43 m/s 时，每 3 h 分成最多 9 个子步。
- **边界条件**：区域边界自由流出，流入的空气是干净的（$C=0$）。
- **初始条件**：$C=0$，先预跑 20 天再开始统计一年。
- **验证**：质量守恒（排放 = 沉降 + 流出 + 存量变化，误差 $10^{-13}$）；质量始终非负；源网格浓度与手算箱模型一致。

法语说法：
« On résout l'équation par volumes finis, avec un schéma amont explicite. Le pas de temps respecte la condition CFL. Aux bords du domaine, le polluant sort librement et l'air qui entre est propre. On vérifie que la masse est conservée : émis = déposé + sorti + stocké. »

---

## 3. 为什么选这些现象（对应问题 c）

用三个数量级论证，每个都能在黑板上现算：

1. **平流远大于扩散**。Péclet 数：
$$Pe = \frac{U\,\Delta x}{K} = \frac{5.9\times7\times10^{4}}{100}\approx 4000 \gg 1$$
所以网格尺度上风的输运是主导，湍流扩散可以忽略（代码里保留了这一项，以便证明它不重要）。

2. **污染物会跨越多个网格**。输运距离：
$$L = \frac{U}{k} = \frac{5.9}{8.2\times10^{-6}}\approx 700\ \text{km}\approx 10\ \text{个网格}$$
所以只算源网格是不够的，必须做空间输运。模拟结果也印证：60% 的损害在源网格以外。

3. **湿沉降是 PM10 的主要汇**。$k_{pluie}/k_{sec}=72$，即使只有 16% 的时间下雨，湿沉降仍占约 86%。B4 网格降水 1821 mm/yr，远高于大陆平均。

4. **PM10 优先于 COVNM**。COVNM 质量是 PM10 的 3 倍，但表征因子小 20 倍：
$$\frac{Q_{PM}\,CF_{PM}\,f_{PM}}{Q_{COV}\,CF_{COV}\,f_{COV}} = \frac{1.09\times10^{5}\times1.096\times0.0114}{3.28\times10^{5}\times0.0538\times0.0107}\approx 7$$

**没有纳入的现象及理由**

| 现象 | 不纳入的理由 |
|---|---|
| 臭氧生成（COVNM + NOx） | `map.xlsx` 没有 NOx 数据，无法定量 |
| 垂直结构、烟囱抬升 | 只有一层 200 m 高度的风；假设混合层内充分混合 |
| 沉降后经食物链的摄入 | 已包含在 USEtox 的空气表征因子里，不再单独相加，避免重复计算。代码里另算了一个"沉降路径"指标作对照：PM10 约 0.19 DALY/yr |
| 海产品途径 | 海洋网格人口为 0，无法分配受体。42 t/yr 的 PM10 落在海里，这是已知的低估 |
| 同网格其他源（壁炉 574 t/yr） | 不属于 B4 场址；模型是线性的，可以直接叠加 |

---

## 4. 量纲与数量级校验（对应问题 d）

**量纲**：输运方程每一项都是 kg·m⁻³·s⁻¹。
- $\nabla\cdot(\mathbf{u}C)$：(m/s)(kg/m³)/m ✓
- $K\nabla^2C$：(m²/s)(kg/m³)/m² ✓
- $Q/(AH)$：(kg/s)/(m²·m) ✓
- $kC$：s⁻¹·kg/m³ ✓

**箱模型手算源网格浓度**。稳态时排放 = 被风吹走 + 被清除：

$$
Q = C\,H\,(U\,\Delta x + k\,A)\ \Rightarrow\ 
C = \frac{3.46\times10^{-3}}{10^{3}\times(5.9\times7.0\times10^{4} + 8.2\times10^{-6}\times4.9\times10^{9})} = 7.7\times10^{-12}\ \text{kg/m}^3
$$

即 0.0077 µg/m³，模拟值 0.0075 µg/m³，相差 3%。同时可见通风项（$4.1\times10^{5}$）是清除项（$4.0\times10^{4}$）的 10 倍：源网格的浓度由风决定。

**与已知值比较**
- 0.0075 µg/m³ 是 70 km 网格平均的**增量**，远小于城市 PM10 背景（几十 µg/m³）。这是合理的：109 t/yr 稀释在 $4.9\times10^{12}$ m³ 的空气里。港口附近几公里内的浓度会高得多，但网格分辨不了。
- $iF\approx5\times10^{-7}$。USEtox 文档引用的 Humbert et al. (2011) 给出颗粒物吸入分数，印象中城市约 $10^{-5}$ 量级、农村约 $10^{-6}$ 量级——**这两个数值需要查原文确认**。我们的值偏低，原因是 70 km 网格把城市人口和污染物都摊平了，而且烟羽主要吹向海上。

---

## 5. 模型的优势与局限（对应问题 e）

**优势**
- 全链条定量，每一步的单位和来源都能说清。
- 用了真实的逐 3 小时年风场，而不是一个平均风。
- 质量严格守恒，有箱模型交叉验证。
- 模型对排放量是线性的：第二阶段有很多场址时，可以逐个叠加。
- 没有风场文件时也能运行（内置风玫瑰），满足"只依赖 `map.xlsx`"的要求。

**局限（按重要性排序）**
1. **USEtox 系数的用法没有确认**，决定绝对量级。
2. **70 km 网格**：分辨不了港口附近的高浓度区，低估近场暴露。
3. **迎风格式的数值扩散**约为 $U\Delta x/2\approx2\times10^{5}$ m²/s，比物理扩散大三个量级，烟羽被人为展宽。
4. **风场与地图的坐标不一致**：两者都是 72 × 33，但风场经度范围是 −27° 到 26.25°，地图是 −22.2° 到 22.3°。我们按网格序号一一对应，换成按经纬度对应结果变化 14%。
5. **混合层高度恒定** 1000 m，且用 200 m 高度的风代表整层。
6. **COVNM 当作单一物质**，半衰期 2 天是假设；不算它生成的臭氧和二次颗粒物。
7. **等效排放量按源网格浓度归一化**，隐含假设是 USEtox 系数适用于一个 70 km 网格尺度的空气箱。

---

## 6. 最大的未决问题：USEtox 系数表怎么用

表头写的是：
- E 列：*Total endpoint human health characterization factor for the sum on all compartment (CDUh/(kg.1E9humans))*
- F–N 列：*fraction of Comparative Damage Unit in each compartment*，子表头是 *Emission to urban air*、*Emission to cell rural air* 等，各列之和为 1。

已确认的部分（USEtox 文档原文）：CDUh/kg = DALY/kg；USEtox 默认大陆人口约 $10^{9}$ 人，所以"per 1E9 humans"应理解为"按实际人口 ÷ $10^{9}$ 缩放"。

我们的解读：排放到介质 $i$ 的系数 = $CF_{tot}\times f_i$。

| 解读 | PM10 损害 |
|---|---|
| A（代码采用）：乘以"城市/农村空气"份额 | 2.1 DALY/yr |
| B：不乘份额，直接用 $CF_{tot}$ | 约 200 DALY/yr |

**周二 14:00–16:00 问毒理顾问 Frédéric Dubreuil 的三个问题**（简单问题不花代币）：
1. « Les colonnes F à N sont-elles bien la part du CF total pour une émission dans chaque compartiment ? Doit-on calculer $CF_{air} = CF_{tot}\times f_{air}$ ? »
2. « "Par 1E9 humains" : faut-il multiplier par la population de la cellule divisée par $10^{9}$ ? »
3. « Pour les cellules sous le vent, peut-on appliquer le CF "air" à la masse qui arrive dans la cellule ? »

**周二问输运顾问 Andrea Maffioli**：
4. « Les coordonnées x, y du fichier de vent ne coïncident pas avec celles de map.xlsx. Doit-on associer les cellules par indice (i, j) ? »

答案出来后只需改代码第 1 节的参数或第 7 节的一行公式。

---

## 7. 评审可能的提问与简短回答

| 问题 | 回答要点（法语） |
|---|---|
| Pourquoi négliger la diffusion ? | Péclet ≈ 4000 à l'échelle de la maille : l'advection domine. On garde le terme pour le vérifier. |
| Quelles conditions aux limites ? | Sortie libre aux bords ; air entrant propre ; C = 0 au départ, 20 jours de mise en régime. |
| Comment choisissez-vous le pas de temps ? | Condition CFL ≤ 0,8 ; jusqu'à 9 sous-pas par pas de vent de 3 h. |
| Comment validez-vous le code ? | Bilan de masse fermé à 10⁻¹³ ; masse toujours positive ; concentration à la source = modèle boîte à 3 % près. |
| Pourquoi H = 1000 m ? | Valeur par défaut USEtox (Table 10). C'est une hypothèse forte : C varie comme 1/H. |
| D'où vient la vitesse de dépôt ? | 10⁻³ m/s, USEtox Table 10 (Mackay 2001). Cohérent avec la vitesse de Stokes d'une particule de quelques µm. |
| Et l'ozone ? | Pas de données de NOx dans map.xlsx : on ne peut pas le quantifier. C'est une limite. |
| Pourquoi le PM10 domine ? | Trois fois moins de masse, mais un facteur de caractérisation vingt fois plus grand. |
| Que signifie 2,4 DALY/an ? | 2,4 années de vie en bonne santé perdues par an dans la population exposée. L'ordre de grandeur dépend de l'interprétation des CF. |
| Votre résultat est-il fiable ? | Le transport à ±35 % ; le facteur toxicologique est la principale incertitude. |
| Que feriez-vous avec plus de temps ? | Maillage plus fin près de la source ; schéma d'ordre 2 ; voie ingestion par les produits de la mer ; hauteur de mélange variable. |

Stokes 沉降速度的验算（被问到 $v_d$ 时用）：

$$
v_s = \frac{\rho_p\,d^{2}\,g}{18\,\mu} = \frac{1500\times(5\times10^{-6})^{2}\times9.81}{18\times1.8\times10^{-5}}\approx1.1\times10^{-3}\ \text{m/s}
$$

其中 $\rho_p$ 是颗粒密度 [kg/m³]（取 1500，假设），$d$ 是粒径 [m]（取 5 µm），$\mu$ 是空气动力黏度 [Pa·s]。与 USEtox 的 $10^{-3}$ m/s 同量级。

---

## 8. 代码使用说明

**运行**：把 `L1_2_B4_IA.m` 和 `map.xlsx` 放在同一文件夹，在 MATLAB 里点 Run。需要 R2019a 或更新版本，不需要工具箱。

**风场**：如果同一文件夹里有 `Vent1AnFinal.mat`（或 `vent_un_an.mat`、`Vent1MoisFinal.mat` 等），自动使用；没有就用内置风玫瑰。

**参数位置**：全部在第 1 节的结构体 `P` 和 `POL` 里。

**输出**：命令行结果表；一张 2×2 的图；`results_B4/` 文件夹里的 PNG 和 CSV。

**代码结构**

| 节 | 内容 |
|---|---|
| 1 | 参数、USEtox 系数、备用风玫瑰 |
| 2 | 读 `map.xlsx`，建 72×33 网格 |
| 3 | 找到 B4 场址及其排放量 |
| 4 | 读风场或生成备用风 |
| 5 | 各网格的清除速率 |
| 6 | 输运模拟 |
| 7 | 暴露与健康损害 |
| 8 | 结果表与校验 |
| 9 | 画图与保存 |

**交之前的检查清单**
1. 在 MATLAB 里实际 Run 一次（有风场文件和没有风场文件各一次）。
2. 对照第 1 节的表：源网格 PM10 浓度应约 0.0075 µg/m³，质量守恒误差应小于 $10^{-6}$，总损害约 2.4 DALY/yr。
3. 如果报错，把报错信息发给我。
4. 文件名保持 `L1_2_B4_IA.m`（用了 AI 必须带 `_IA`）。

**注释语言**：代码注释和报错信息用法语（不带重音符号，避免旧版 MATLAB 的编码问题），图和命令行输出用英语。需要中文注释版可以再出一份。

---

## 9. 周二的分工建议

| 人 | 周二要做的事 |
|---|---|
| 健康影响（你） | 问 Dubreuil 第 6 节的三个问题；按答案修正第 7 节公式；查 Humbert 2011 的 $iF$ 数值 |
| 输运 | 问 Maffioli 风场坐标问题；理解迎风格式和 CFL |
| 沉降 | 读 USEtox 文档式 91、98–100；给 COVNM 的半衰期找来源 |
| 数据 | 在 MATLAB 里跑通代码，核对结果表 |
| 数值 | 准备讲边界条件、质量守恒验证、数值扩散 |
| 集成 | 更新方框图；组织全员轮流在白板上讲一遍第 2 节 |
