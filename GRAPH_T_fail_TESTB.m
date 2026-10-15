%% Line+sd graphs
% Data
theta0 = [1,2,3,5,7,10];
lqr_mean = [4.21, 4.11, 4.60, 3.73, 3.34, 3.00]; %t_fail_lqr
lqr_sd = [2.39, 1.03, 1.32, 1.76, 0.65, 1.52]; % LQR Standard deviation
pid_mean = [1.62, 2.04, 3.28, 1.50, 0.80, 0.79];
pid_sd = [1.32, 2.29, 3.81, 1.14, 0.16, 0.29];

%graphs
figure;
errorbar(theta0, lqr_mean, min(lqr_sd,lqr_mean), lqr_sd, '-o', 'Color', [0.09 0.37 0.65], 'LineWidth', 1.5, 'MarkerFaceColor',[0.09 0.37 0.65]);%T-fail do not be negative.
hold on;
errorbar(theta0, pid_mean, min(pid_sd,pid_mean), pid_sd, '-o', 'Color', [0.85 0.35 0.19], 'LineWidth', 1.5, 'MarkerFaceColor',[0.85 0.35 0.19]);

% axes and labels
xlabel('\theta_0 (deg)');
xticks([1 2 3 5 7 10]);
ylabel('T_{fail}(sec)');
title('Test B: Fall Time by Initial Sweep Angle');
legend('LQR', 'PID', 'Location', 'best');
grid on;