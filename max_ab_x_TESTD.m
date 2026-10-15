%% BAR+SD-TEST D max|x|
% Data
labels = {'LQR', 'PID'};
max_absx = [19.30,	2.02]; %max|x|- lqr&pid
sds = [3.84, 0.93]; % Standard deviations

% Bar Graphs, colors and Error Bars
figure;
bar(1, max_absx(1), 'FaceColor',[0.09 0.37 0.65]); %LQR blue
hold on;
bar(2, max_absx(2), 'FaceColor',[0.85 0.35 0.19]);%PID orange
hold on; 
errorbar(1:2, max_absx, sds, sds, 'k', 'LineStyle', 'none', 'LineWidth', 1.2);%1;2-x locations, k-color code
% axes and labels
set(gca, 'XTick', 1:2, 'XTickLabel', labels); %gca=get current axis
ylabel('max|x| (cm)');
title('Test D: Comparison with max|x|');
grid on;

