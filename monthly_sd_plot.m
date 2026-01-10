% Monthly statistics comparison

months = categorical({'Nov 2021','Dec 2021','Jan 2022', ...
                      'Feb 2022','Mar 2022','Apr 2022'});
months = reordercats(months, categories(months));

% ATL07-like
mean_mine_sv   = [0.1330 0.2622 0.2213 0.2663 0.2225 0.1707];
median_mine_sv = [0.1171 0.2765 0.2048 0.2588 0.2328 0.1840];

mean_mine_gl   = [0.2007 0.2449 0.2573 0.2348 0.2546 0.3385];
median_mine_gl = [0.1958 0.2374 0.2484 0.2151 0.2076 0.2897];

% AMSR-E/AMSR2
mean_mw_sv   = [0.0604 0.1005 0.1499 0.1216 0.1242 0.1348];
median_mw_sv = [0.0616 0.0994 0.1476 0.1308 0.1172 0.1380];

mean_mw_gl   = [0.1926 0.2015 0.1984 0.1911 0.2215 0.2066];
median_mw_gl = [0.1850 0.1981 0.2052 0.1975 0.2188 0.2157];

% CryoTempo
mean_ct_sv   = [0.055 0.081 0.088 0.134 0.126 0.114];
median_ct_sv = [0.046 0.063 0.077 0.129 0.112 0.097];

mean_ct_gl   = [0.128 0.143 0.205 0.198 0.202 0.195];
median_ct_gl = [0.123 0.134 0.137 0.134 0.211 0.213];

% UiT product
mean_t_sv   = [0.078 0.089 0.109 0.157 0.135 0.119];
median_t_sv = [0.074 0.087 0.108 0.144 0.124 0.111];

mean_t_gl   = [0.169 0.201 0.228 0.244 0.252 0.278];
median_t_gl = [0.166 0.197 0.222 0.233 0.251 0.274];

% colors
col_mine_med  = [0.55 0.00 0.55];
col_mine_mean = [0.80 0.55 0.80];
col_ext_med   = [0.00 0.45 0.75];
col_ext_mean  = [0.60 0.80 0.95];

%% ATL07-like vs AMSR

figure('Color','w');

subplot(1,2,1); hold on
plot(months, median_mine_sv,'-o','Color',col_mine_med,'LineWidth',1.8,'MarkerFaceColor',col_mine_med)
plot(months, mean_mine_sv,  '-o','Color',col_mine_mean,'LineWidth',1.8,'MarkerFaceColor',col_mine_mean)
plot(months, median_mw_sv,  '-s','Color',col_ext_med,'LineWidth',1.8,'MarkerFaceColor',col_ext_med)
plot(months, mean_mw_sv,    '-s','Color',col_ext_mean,'LineWidth',1.8,'MarkerFaceColor',col_ext_mean)
ylim([0 0.4])
ylabel('Snow depth (m)')
title('Svalbard')
grid on; box on; xtickangle(45)
legend({'ATL07-like median','ATL07-like mean', ...
        'AMSR median','AMSR mean'}, ...
        'Location','north','FontSize',6.9)

subplot(1,2,2); hold on
plot(months, median_mine_gl,'-o','Color',col_mine_med,'LineWidth',1.8,'MarkerFaceColor',col_mine_med)
plot(months, mean_mine_gl,  '-o','Color',col_mine_mean,'LineWidth',1.8,'MarkerFaceColor',col_mine_mean)
plot(months, median_mw_gl,  '-s','Color',col_ext_med,'LineWidth',1.8,'MarkerFaceColor',col_ext_med)
plot(months, mean_mw_gl,    '-s','Color',col_ext_mean,'LineWidth',1.8,'MarkerFaceColor',col_ext_mean)
ylim([0 0.4])
title('NE Greenland')
grid on; box on; xtickangle(45)

%% ATL07-like vs CryoTempo

figure('Color','w');

subplot(1,2,1); hold on
plot(months, median_mine_sv,'-o','Color',col_mine_med,'LineWidth',1.8,'MarkerFaceColor',col_mine_med)
plot(months, mean_mine_sv,  '-o','Color',col_mine_mean,'LineWidth',1.8,'MarkerFaceColor',col_mine_mean)
plot(months, median_ct_sv,  '-d','Color',col_ext_med,'LineWidth',1.8,'MarkerFaceColor',col_ext_med)
plot(months, mean_ct_sv,    '-d','Color',col_ext_mean,'LineWidth',1.8,'MarkerFaceColor',col_ext_mean)
ylim([0 0.4])
ylabel('Snow depth (m)')
title('Svalbard')
grid on; box on; xtickangle(45)

subplot(1,2,2); hold on
plot(months, median_mine_gl,'-o','Color',col_mine_med,'LineWidth',1.8,'MarkerFaceColor',col_mine_med)
plot(months, mean_mine_gl,  '-o','Color',col_mine_mean,'LineWidth',1.8,'MarkerFaceColor',col_mine_mean)
plot(months, median_ct_gl,  '-d','Color',col_ext_med,'LineWidth',1.8,'MarkerFaceColor',col_ext_med)
plot(months, mean_ct_gl,    '-d','Color',col_ext_mean,'LineWidth',1.8,'MarkerFaceColor',col_ext_mean)
ylim([0 0.4])
title('NE Greenland')
grid on; box on; xtickangle(45)

%% ATL07-like vs UiT

figure('Color','w');

subplot(1,2,1); hold on
plot(months, median_mine_sv,'-o','Color',col_mine_med,'LineWidth',1.8,'MarkerFaceColor',col_mine_med)
plot(months, mean_mine_sv,  '-o','Color',col_mine_mean,'LineWidth',1.8,'MarkerFaceColor',col_mine_mean)
plot(months, median_t_sv,   '-d','Color',col_ext_med,'LineWidth',1.8,'MarkerFaceColor',col_ext_med)
plot(months, mean_t_sv,     '-d','Color',col_ext_mean,'LineWidth',1.8,'MarkerFaceColor',col_ext_mean)
ylim([0 0.4])
ylabel('Snow depth (m)')
title('Svalbard')
grid on; box on; xtickangle(45)

subplot(1,2,2); hold on
plot(months, median_mine_gl,'-o','Color',col_mine_med,'LineWidth',1.8,'MarkerFaceColor',col_mine_med)
plot(months, mean_mine_gl,  '-o','Color',col_mine_mean,'LineWidth',1.8,'MarkerFaceColor',col_mine_mean)
plot(months, median_t_gl,   '-o','Color',col_ext_med,'LineWidth',1.8,'MarkerFaceColor',col_ext_med)
plot(months, mean_t_gl,     '-o','Color',col_ext_mean,'LineWidth',1.8,'MarkerFaceColor',col_ext_mean)
ylim([0 0.4])
title('NE Greenland')
grid on; box on; xtickangle(45)
