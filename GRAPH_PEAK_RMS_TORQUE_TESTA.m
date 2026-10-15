%% BAR+SD-TEST A (Peak_torque/RMS_torque)
% Data
means = [0.6365,	0.196 , 0.510, 0.071]; %lqr-peak,pid-peak,lqr-rmstorque,pid-rmstorque
sds = [0.00, 0.019 , 0.015, 0.022 ]; % Standard deviations
labels = {'Peak{\tau}','RMS{\tau}'};
x_pos = [1,2,4,5];
colors = [0.09 0.37 0.65; 0.85 0.35 0.19; 0.09 0.37 0.65; 0.85 0.35 0.19];%colors(blue and orange)

% Bar Graphs, colors and Error Bars
figure;
h = gobjects(1,4);
for i = 1:4
h(i)= bar(x_pos(i), means(i), 'FaceColor',colors(i,:)); 
hold on;
end

errorbar(x_pos, means, sds, sds, 'k', 'LineStyle', 'none', 'LineWidth', 1.2);%1;2-x locations, k-color code
% axes and labels
set(gca, 'XTick', [1.5, 4.5], 'XTickLabel',labels); %gca=get current axis
ylabel('Torque(N.m)');
legend([h(1),h(2)], {'LQR', 'PID'},'Location', 'northoutside', 'Orientation', 'horizontal','Box','off');
box off;
set(gca, 'GridAlpha',0.15);
grid on;
title('Test A: Comparison with Peak/RMS Torque');
grid on;