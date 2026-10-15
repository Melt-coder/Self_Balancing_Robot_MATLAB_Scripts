%% BAR+SD-TEST A T_fail
% Data
labels = {'LQR', 'PID'};
means = [3.73 , 1.50]; %T_fail avarages
sds = [1.76	, 1.14]; % Standard deviations

% Bar Graphs, colors and Error Bars
figure;
bar(1, means(1), 'FaceColor',[0.09 0.37 0.65]); %LQR blue
hold on;
bar(2, means(2), 'FaceColor',[0.85 0.35 0.19]);%PID orange
hold on; 
errorbar(1:2, means, sds, sds, 'k', 'LineStyle', 'none', 'LineWidth', 1.2);%1;2-x locations, k-color code
% axes and labels
set(gca, 'XTick', 1:2, 'XTickLabel', labels); %gca=get current axis
ylabel('T_{fail} (sec)');
title('Test A: Comparison with falling time');
grid on;






