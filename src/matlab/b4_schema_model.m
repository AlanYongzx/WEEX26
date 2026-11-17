%% B4 (Effergie) - WEEX DEPOL : 基于 schema-bloc 的完整模型（单文件 MATLAB）
% 链条：港口排放 -> 对流层（平流 + 混合层）-> 干/湿沉降 -> 陆地水体与海洋 / 农业用地
%       -> 土壤传递（灌溉、累积）-> 植物富集（叶面 + 根系）-> 摄入；悬浮颗粒 -> 吸入
%       -> USEtox 表征因子 -> DALY/yr
% 输入：B4 源网格 32_27 的 map.xlsx 数值（已提取，写在第 1 节）；
%       区域输运结果（之前真实年风场的运行，写在 REG 结构体中）。
% 运行：直接 Run（R2019b 或更新，无需工具箱）。
% 输出：results/tables/*.csv，results/figures/*.png|svg，命令行结果与自检。
clear; clc; close all;

%% 1. 参数 ------------------------------------------------------------------
YR_s = 3.156e7;                       % 一年的秒数 [s/yr]

% --- map.xlsx：源网格 32_27（Bantania，工业与商业港口）---
Q_kg_yr.PM10  = 1.09e5;               % PM10 排放 [kg/yr]
Q_kg_yr.COVNM = 3.28e5;               % COVNM 排放 [kg/yr]
A_m2   = 4.919e9;                     % 网格面积 [m2]
dx_m   = sqrt(A_m2);                  % 网格边长 [m]，约 70.1 km
P_mm_yr = 1821;                       % 年降水 [mm/yr]
f_agri = 0.539;                       % 农业用地面积比例 [-]
f_nat  = 0.179 + 0.190;               % 自然土壤（森林 + 其他）[-]
f_fw   = 1 - f_agri - f_nat;          % 城市 + 工矿 + 内陆水面 -> 计入"陆地水体" [-]
pop_urb = 348699;  pop_rur = 313296;  % 城市 / 农村人口 [人]

% --- 大气（USEtox 2.0 Table 10 默认值）---
H_m   = 1000;                         % 混合层高度 [m]
U_ms  = 5.85;                         % 源网格 200 m 年均风速 [m/s]（风场文件）
vd_ms = 1e-3;                         % 气溶胶干沉降速度 [m/s]
CE    = 2e5;                          % 雨水对气溶胶的清洗比 [-]
I_rain_ms  = 1.3e-3/3600;             % 下雨时雨强 1.3 mm/h -> [m/s]
T_cycle_s  = 80*3600;                 % 干湿周期 [s]

% --- COVNM 化学（假设，需查原文）---
kOH_cm3_s = 4e-12;                    % OH 反应速率常数 [cm3/(molecule*s)]，烷烃/芳烃代表值
OH_cm3    = 1e6;                      % OH 浓度 [molecule/cm3]，全球 24 h 平均量级
MIR_g_g   = 3.0;                      % 臭氧最大增量反应活性 [g O3/g COV]，上限

% --- 土壤与作物（假设，典型值）---
h_soil_m = 0.1;  rho_soil_kg_m3 = 1500;   % 耕作层深度、容重
f_int    = 0.3;                       % 冠层截留比例 [-]
t_w_d    = 14;                        % 叶面颗粒冲刷半衰期 [d]
n_cycles = 2;   T_c_d = 120;          % 每年两熟，每季 120 d
f_food   = 0.5;                       % 叶面污染进入可食部分并被吃下的比例 [-]
BCF      = 0.01;                      % 根系富集系数 C_plant(fw)/C_soil(dw) [-]
Y_kg_m2  = 1.0;                       % 鲜重产量 [kg/(m2*yr)]
f_irr    = 0.1;                       % 陆地水体沉降经灌溉返回农田的比例 [-]
BR_m3_d  = 13;                        % 呼吸量 [m3/(d*人)]，USEtox

% --- USEtox 系数（MODELISATION_infos_polluants）---
CF.PM10  = struct('tot',1.096, 'urb',0.0114,'rur',0.0096,'inh',0.501,'ing',0.499);
CF.COVNM = struct('tot',0.0538,'urb',0.0107,'rur',0.0080,'inh',0.304,'ing',0.696);

% --- 区域输运结果（之前的真实年风场运行，72x33 网格）---
REG.PM10  = struct('sea_t',42.2,'nat_t',19.0,'agri_t',11.3,'fw_t',2.1,'out',0.31, ...
                   'iF_inh',5.5e-7,'D_src',0.83,'D_tot',2.10);
REG.COVNM = struct('deg',0.59,'out',0.41,'iF_inh',5.8e-7,'D_src',0.11,'D_tot',0.28);

species = {'PM10','COVNM'};

%% 2. 大气清除速率 ----------------------------------------------------------
k_dry_s  = vd_ms/H_m;                             % 干沉降 [1/s]
k_wet_s  = CE*I_rain_ms/H_m;                      % 下雨时冲刷 [1/s]
wet_frac = (P_mm_yr/1000/YR_s)/I_rain_ms;         % 下雨时间占比 [-]
t_wet_s  = wet_frac*T_cycle_s;  t_dry_s = T_cycle_s - t_wet_s;

kmean = @(kd,kw) 1./( t_dry_s./(T_cycle_s.*kd) + t_wet_s./(T_cycle_s.*kw) ...
    - (1/T_cycle_s).*(1./kw - 1./kd).^2 .* ...
      (1-exp(-kd.*t_dry_s)).*(1-exp(-kw.*t_wet_s))./(1-exp(-kd.*t_dry_s-kw.*t_wet_s)) );  % USEtox 式 91

k_s.PM10  = kmean(k_dry_s, k_wet_s);              % PM10 平均清除速率 [1/s]
dry_share = k_dry_s*t_dry_s/(k_dry_s*t_dry_s + k_wet_s*t_wet_s);   % 干沉降占比
k_s.COVNM = kOH_cm3_s*OH_cm3;                      % COVNM 一级降解 [1/s]

%% 3. 对流层：源网格稳态箱模型 Q = C*H*(U*dx + k*A) -------------------------
Vvent_m3_s = U_ms*dx_m*H_m;                        % 风每秒带出网格的空气体积 [m3/s]
for i = 1:2
    s = species{i};
    Qs = Q_kg_yr.(s)/YR_s;                         % [kg/s]
    Vrm_m3_s = k_s.(s)*A_m2*H_m;                   % 清除的"等效体积流量" [m3/s]
    R.(s).C_kg_m3   = Qs/(Vvent_m3_s + Vrm_m3_s);  % 混合层平均浓度 [kg/m3]
    R.(s).C_ug_m3   = R.(s).C_kg_m3*1e9;
    R.(s).tau_d     = 1/k_s.(s)/86400;             % 大气寿命 [d]
    R.(s).f_rm_src  = Vrm_m3_s/(Vvent_m3_s + Vrm_m3_s);   % 在源网格内被清除的比例
    R.(s).massbal   = (Qs - R.(s).C_kg_m3*(Vvent_m3_s+Vrm_m3_s))/Qs;   % 相对质量守恒误差
end
Cg_ratio_min = 1 - vd_ms*log(200/2)/(0.4*0.31);    % 2 m / 200 m 浓度比下限（v_s->0）

%% 4. 源网格 PM10 沉降及在地表介质间的分配 ---------------------------------
F_kg_m2_yr = k_s.PM10*H_m*R.PM10.C_kg_m3*YR_s;     % 总沉降通量 [kg/(m2*yr)]
dep_src_kg = F_kg_m2_yr*A_m2;                      % 源网格年沉降 [kg/yr]
dep_agri_src_kg = dep_src_kg*f_agri;
dep_nat_src_kg  = dep_src_kg*f_nat;
dep_fw_src_kg   = dep_src_kg*f_fw;
A_agri_src_m2   = A_m2*f_agri;
irr_src_kg      = f_irr*dep_fw_src_kg;             % 灌溉返回农田 [kg/yr]

%% 5. 农业用地 -> 植物 -> 摄入（生产量法）---------------------------------
% 叶面：f_fol = n/365 * f_int * (1-exp(-k_w*T_c))/k_w * f_food
% 根系：I_root = BCF * M_dep * t * Y /(h*rho)   （面积相消）
crop = @(Mdep_kg, years, fint, tw_d, bcf) deal( ...
    Mdep_kg*n_cycles/365*fint*(1-exp(-log(2)/tw_d*T_c_d))/(log(2)/tw_d)*f_food, ...   % 叶面 [kg/yr]
    bcf*Mdep_kg*years*Y_kg_m2/(h_soil_m*rho_soil_kg_m3));                               % 根系 [kg/yr]

f_fol = n_cycles/365*f_int*(1-exp(-log(2)/t_w_d*T_c_d))/(log(2)/t_w_d)*f_food;
Mag.src = dep_agri_src_kg + irr_src_kg;
Mag.reg = REG.PM10.agri_t*1e3 + f_irr*REG.PM10.fw_t*1e3;
cases = {'src',1; 'src',30; 'reg',1; 'reg',30};
ING = struct('zone',{},'years',{},'foliar',{},'root',{},'total',{});
for c = 1:size(cases,1)
    [fol, root] = crop(Mag.(cases{c,1}), cases{c,2}, f_int, t_w_d, BCF);
    ING(c) = struct('zone',cases{c,1},'years',cases{c,2},'foliar',fol,'root',root,'total',fol+root);
end
Csoil_src_1yr_ug_kg  = F_kg_m2_yr*1/(h_soil_m*rho_soil_kg_m3)*1e9;   % 耕作层浓度增量
Csoil_src_30yr_ug_kg = 30*Csoil_src_1yr_ug_kg;
I_ing_reg_kg = ING(3).total;  iF_ing_reg = I_ing_reg_kg/Q_kg_yr.PM10;

%% 6. 吸入 -----------------------------------------------------------------
pop = pop_urb + pop_rur;
for i = 1:2
    s = species{i};
    INH.(s).I_src_kg = R.(s).C_kg_m3*BR_m3_d*365*pop;     % 源网格吸入量 [kg/yr]
    INH.(s).iF_src   = INH.(s).I_src_kg/Q_kg_yr.(s);
    INH.(s).I_reg_kg = REG.(s).iF_inh*Q_kg_yr.(s);        % 区域吸入量 [kg/yr]
end

%% 7. 健康损害（USEtox 解读 A）---------------------------------------------
for i = 1:2
    s = species{i}; c = CF.(s);
    D.(s).src = c.tot*Q_kg_yr.(s)*(c.urb*pop_urb + c.rur*pop_rur)/1e9;   % [DALY/yr]
    D.(s).reg = REG.(s).D_tot;
    D.(s).inh = D.(s).reg*c.inh;
    D.(s).ing = D.(s).reg*c.ing;
end
D_total = D.PM10.reg + D.COVNM.reg;
EF_inh = D.PM10.inh/INH.PM10.I_reg_kg;     % 每 kg 吸入的损害 [DALY/kg]
EF_ing = D.PM10.ing/I_ing_reg_kg;          % 每 kg 吃下的损害 [DALY/kg]

%% 7b. 独立交叉检验：流行病学浓度-反应函数（只针对 PM10 吸入）-----------
% 死亡 = beta * m0 * sum_j(dC_j * P_j)，beta = ln(RR)/10 [1/(ug/m3)]
% RR：Chen & Hoek 2020 (Environ. Int. 143:105974)，PM10 长期暴露全因死亡 1.04 (1.03-1.06) / 10 ug/m3
% m0（基础死亡率）与每例归因死亡损失年数为假设
RR_PM10 = [1.04 1.03 1.06];             % 中值 / 低 / 高
m0_yr   = [0.007 0.005 0.010];          % 基础死亡率 [1/yr]（假设）
YLL_yr  = [10 5 15];                    % 每例归因死亡损失生命年 [yr]（假设）
CP_ug_m3 = INH.PM10.I_reg_kg/(BR_m3_d*365)*1e9;   % 人口加权浓度增量之和 sum(dC*P) [ug/m3*人]
beta_epi  = log(RR_PM10)/10;
deaths_epi = beta_epi.*m0_yr*CP_ug_m3;  % 归因死亡 [人/yr]
D_epi      = deaths_epi.*YLL_yr;        % [DALY/yr]（仅 YLL）
ratio_A    = D_epi(1)/D.PM10.inh;       % 流行病学 / USEtox 解读 A（吸入部分）
D_inh_B    = CF.PM10.tot*CF.PM10.inh*D.PM10.reg/(CF.PM10.tot*(CF.PM10.urb*pop_urb+CF.PM10.rur*pop_rur)/(pop_urb+pop_rur)); % 解读 B 的吸入损害（不乘份额）

%% 8. 化学：COVNM 降解与臭氧上限 -------------------------------------------
deg_src_kg = Q_kg_yr.COVNM*R.COVNM.f_rm_src;
deg_reg_kg = Q_kg_yr.COVNM*REG.COVNM.deg;
O3_src_max_kg = MIR_g_g*deg_src_kg;
C_O3_src_max_ug_m3 = O3_src_max_kg/YR_s/Vvent_m3_s*1e9;   % 源网格臭氧增量上限
O3_reg_max_kg = MIR_g_g*deg_reg_kg;

%% 9. 敏感性：PM10 区域摄入量 ----------------------------------------------
sens_name = {'base','f_int 0.1','f_int 0.5','t_w 7 d','t_w 28 d','BCF 1e-3','BCF 1e-1','30 yr soil'};
sens_par  = {{f_int,t_w_d,BCF,1},{0.1,t_w_d,BCF,1},{0.5,t_w_d,BCF,1},{f_int,7,BCF,1}, ...
             {f_int,28,BCF,1},{f_int,t_w_d,1e-3,1},{f_int,t_w_d,0.1,1},{f_int,t_w_d,BCF,30}};
sens_val = zeros(numel(sens_name),1);
for j = 1:numel(sens_name)
    p = sens_par{j};
    [fol, root] = crop(Mag.reg, p{4}, p{1}, p{2}, p{3});
    sens_val(j) = fol + root;
end
k_PM_vd5 = kmean(5*k_dry_s, k_wet_s);

%% 10. 结果表 --------------------------------------------------------------
names = {'k_dry_s-1';'k_wet_s-1';'wet_time_frac';'k_PM_mean_s-1';'dry_share';'k_PM_mean_vd5_s-1';'k_COV_s-1'; ...
 'PM10_C_ug_m3';'PM10_tau_d';'PM10_f_removed_src';'COVNM_C_ug_m3';'COVNM_tau_d';'COVNM_f_removed_src'; ...
 'Cg_over_C200_min';'F_PM_mg_m2_yr';'dep_src_t';'dep_src_agri_t';'dep_src_nat_t';'dep_src_fw_t';'irr_src_kg'; ...
 'Csoil_src_1yr_ug_kg';'Csoil_src_30yr_ug_kg';'f_fol'; ...
 'ing_src_1yr_foliar_kg';'ing_src_1yr_root_kg';'ing_src_30yr_root_kg';'ing_reg_1yr_foliar_kg';'ing_reg_1yr_root_kg';'ing_reg_30yr_root_kg';'ing_reg_1yr_total_kg';'iF_ing_reg'; ...
 'inh_PM10_src_kg';'iF_inh_PM10_src';'inh_PM10_reg_kg';'inh_COVNM_src_kg';'inh_COVNM_reg_kg'; ...
 'D_PM10_src';'D_PM10_reg';'D_PM10_inh';'D_PM10_ing';'D_COVNM_src';'D_COVNM_reg';'D_COVNM_inh';'D_COVNM_ing';'D_total'; ...
 'EF_inh_DALY_kg';'EF_ing_DALY_kg';'CP_ug_m3_pers';'epi_deaths_mid';'epi_D_mid';'epi_D_low';'epi_D_high';'epi_over_A';'D_PM10_inh_interpB';'COV_deg_src_t';'COV_deg_reg_t';'O3_src_max_t';'C_O3_src_max_ug_m3';'O3_reg_max_t'};
vals = [k_dry_s;k_wet_s;wet_frac;k_s.PM10;dry_share;k_PM_vd5;k_s.COVNM; ...
 R.PM10.C_ug_m3;R.PM10.tau_d;R.PM10.f_rm_src;R.COVNM.C_ug_m3;R.COVNM.tau_d;R.COVNM.f_rm_src; ...
 Cg_ratio_min;F_kg_m2_yr*1e6;dep_src_kg/1e3;dep_agri_src_kg/1e3;dep_nat_src_kg/1e3;dep_fw_src_kg/1e3;irr_src_kg; ...
 Csoil_src_1yr_ug_kg;Csoil_src_30yr_ug_kg;f_fol; ...
 ING(1).foliar;ING(1).root;ING(2).root;ING(3).foliar;ING(3).root;ING(4).root;ING(3).total;iF_ing_reg; ...
 INH.PM10.I_src_kg;INH.PM10.iF_src;INH.PM10.I_reg_kg;INH.COVNM.I_src_kg;INH.COVNM.I_reg_kg; ...
 D.PM10.src;D.PM10.reg;D.PM10.inh;D.PM10.ing;D.COVNM.src;D.COVNM.reg;D.COVNM.inh;D.COVNM.ing;D_total; ...
 EF_inh;EF_ing;CP_ug_m3;deaths_epi(1);D_epi(1);D_epi(2);D_epi(3);ratio_A;D_inh_B;deg_src_kg/1e3;deg_reg_kg/1e3;O3_src_max_kg/1e3;C_O3_src_max_ug_m3;O3_reg_max_kg/1e3];

fprintf('\n===== B4 schema-bloc model : results =====\n');
for j = 1:numel(names), fprintf('%-26s %12.4g\n', names{j}, vals(j)); end
fprintf('\nSensitivity, PM10 ingestion (whole domain):\n');
for j = 1:numel(sens_name), fprintf('  %-12s %8.3g kg/yr  x%.2f\n', sens_name{j}, sens_val(j), sens_val(j)/sens_val(1)); end

%% 11. 自检 ----------------------------------------------------------------
% (a) 质量守恒；(b) 与 Python 参考运行比对（相对误差 < 1e-3）；(c) 物理合理性
ref = struct('k_PM',8.167e-6,'C_PM',0.007667,'C_COV',0.02417,'F_PM',1.976,'dep_src',9.72, ...
             'ing_reg',191.3,'inh_PM_src',0.02408,'D_PM_src',0.8342,'D_tot',2.38,'O3_C',0.003477, ...
             'epi_deaths',0.3469,'epi_D',3.469);
got = struct('k_PM',k_s.PM10,'C_PM',R.PM10.C_ug_m3,'C_COV',R.COVNM.C_ug_m3,'F_PM',F_kg_m2_yr*1e6, ...
             'dep_src',dep_src_kg/1e3,'ing_reg',ING(3).total,'inh_PM_src',INH.PM10.I_src_kg, ...
             'D_PM_src',D.PM10.src,'D_tot',D_total,'O3_C',C_O3_src_max_ug_m3, ...
             'epi_deaths',deaths_epi(1),'epi_D',D_epi(1));
fn = fieldnames(ref); npass = 0; ntest = 0;
fprintf('\n===== Self-checks =====\n');
for j = 1:numel(fn)
    e = abs(got.(fn{j})-ref.(fn{j}))/abs(ref.(fn{j})); ok = e < 1e-3;
    fprintf('  [%s] %-11s ref %-10.4g got %-10.4g rel.err %.1e\n', tern(ok), fn{j}, ref.(fn{j}), got.(fn{j}), e);
    npass = npass + ok; ntest = ntest + 1;
end
chk = {'mass balance PM10 |err|<1e-12', abs(R.PM10.massbal)<1e-12; ...
       'mass balance COVNM |err|<1e-12', abs(R.COVNM.massbal)<1e-12; ...
       'wet fraction in (0,1)',          wet_frac>0 && wet_frac<1; ...
       'k_mean between k_dry and k_wet', k_s.PM10>k_dry_s && k_s.PM10<k_wet_s; ...
       'land fractions sum to 1',        abs(f_agri+f_nat+f_fw-1)<1e-12; ...
       'deposition split conserves mass',abs(dep_agri_src_kg+dep_nat_src_kg+dep_fw_src_kg-dep_src_kg)<1e-9*dep_src_kg; ...
       'D_PM10_src ~ transport run 0.83 (5%)', abs(D.PM10.src-REG.PM10.D_src)/REG.PM10.D_src<0.05; ...
       'box C_PM10 ~ transport 0.0075 (5%)',  abs(R.PM10.C_ug_m3-0.0075)/0.0075<0.05; ...
       'inh+ing damage = total',         abs(D.PM10.inh+D.PM10.ing-D.PM10.reg)<1e-12; ...
       'USEtox-A inhalation inside epi range', D.PM10.inh>=D_epi(2) && D.PM10.inh<=D_epi(3); ...
       'USEtox-B inhalation outside epi range', D_inh_B>D_epi(3)};
for j = 1:size(chk,1)
    fprintf('  [%s] %s\n', tern(chk{j,2}), chk{j,1}); npass = npass + chk{j,2}; ntest = ntest + 1;
end
fprintf('  %d / %d checks passed\n', npass, ntest);
% 自检失败时报错：matlab -batch 会返回非零退出码，便于终端判断
if npass < ntest, error('b4:selfcheck', '%d self-check(s) FAILED', ntest - npass); end

%% 12. 保存与绘图 ----------------------------------------------------------
outdir = fullfile(fileparts(mfilename('fullpath')), 'results');
if isempty(fileparts(mfilename('fullpath'))), outdir = fullfile(pwd,'results'); end
if ~exist(fullfile(outdir,'tables'),'dir'),  mkdir(fullfile(outdir,'tables'));  end
if ~exist(fullfile(outdir,'figures'),'dir'), mkdir(fullfile(outdir,'figures')); end
writecell([{'quantity','value'}; names, num2cell(vals)], fullfile(outdir,'tables','b4_schema_summary_matlab.csv'));
writecell([{'case','ingested_kg_yr','ratio_to_base'}; sens_name', num2cell(sens_val), num2cell(sens_val/sens_val(1))], ...
          fullfile(outdir,'tables','b4_schema_sensitivity_ingestion_matlab.csv'));

BLUE = [0.15 0.39 0.92]; GREY = [0.61 0.64 0.69];
% 图 1：PM10 区域去向
f1 = figure('Color','w','Position',[100 100 760 360]);
lab = {'Exported (domain edge)','Continental water','Agricultural soil','Natural soil','Sea'};
v = [REG.PM10.out*109, REG.PM10.fw_t, REG.PM10.agri_t, REG.PM10.nat_t, REG.PM10.sea_t];
b = barh(v, 0.6, 'FaceColor','flat','EdgeColor','none'); b.CData = repmat(GREY,5,1); b.CData(3,:) = BLUE;
set(gca,'YTickLabel',lab,'Box','off','TickDir','out'); xlim([0 55]);
for j = 1:5, text(v(j)+0.8, j, sprintf('%.1f t/yr (%.0f %%)', v(j), v(j)/109*100)); end
xlabel('PM10 mass flux (t/yr)'); title('Fate of PM10 emitted by the B4 port (109 t/yr), regional transport run');
print(f1, fullfile(outdir,'figures','b4_pm10_fate_region_matlab'), '-dpng','-r200');
print(f1, fullfile(outdir,'figures','b4_pm10_fate_region_matlab'), '-dsvg');
% 图 2：各途径摄入量（对数）
f2 = figure('Color','w','Position',[100 100 760 360]);
lab2 = {'PM10 inhaled','PM10 ingested (foliar)','PM10 ingested (root, 1 yr)','PM10 ingested (root, 30 yr)','COVNM inhaled'};
v2 = [INH.PM10.I_reg_kg, ING(3).foliar, ING(3).root, ING(4).root, INH.COVNM.I_reg_kg];
b2 = bar(v2, 0.6, 'FaceColor','flat','EdgeColor','none'); b2.CData = repmat(GREY,5,1); b2.CData([1 5],:) = repmat(BLUE,2,1);
set(gca,'YScale','log','XTickLabel',lab2,'XTickLabelRotation',15,'Box','off','TickDir','out'); ylim([1e-3 3e3]);
for j = 1:5, text(j, v2(j)*1.5, sprintf('%.2g', v2(j)), 'HorizontalAlignment','center'); end
ylabel('Mass taken in by population (kg/yr)'); title('Human intake by exposure route, whole domain (model estimate)');
print(f2, fullfile(outdir,'figures','b4_intake_by_route_matlab'), '-dpng','-r200');
print(f2, fullfile(outdir,'figures','b4_intake_by_route_matlab'), '-dsvg');
fprintf('\nResults written to %s\n', outdir);

%% 局部函数 -----------------------------------------------------------------
function s = tern(ok)
    if ok, s = 'PASS'; else, s = 'FAIL'; end
end
