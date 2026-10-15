%% BAR+SD-TEST D RMS(x)
% Data
labels = {'LQR', 'PID'};
RMS_x = [8.94,	0.98]; %RMS(x)- lqr&pid
sds = [2.78, 0.59]; % Standard deviations

% Bar Graphs, colors and Error Bars
figure;
bar(1, RMS_x(1), 'FaceColor',[0.09 0.37 0.65]); %LQR blue
hold on;
bar(2, RMS_x(2), 'FaceColor',[0.85 0.35 0.19]);%PID orange
hold on; 
errorbar(1:2, RMS_x, sds, sds, 'k', 'LineStyle', 'none', 'LineWidth', 1.2);%1;2-x locations, k-color code
% axes and labels
set(gca, 'XTick', 1:2, 'XTickLabel', labels); %gca=get current axis
ylabel('RMS(x) (cm)');
title('Test D: Comparison with RMS(x)');
grid on;