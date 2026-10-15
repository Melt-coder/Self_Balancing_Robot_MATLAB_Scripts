%% Line+sd graphs
% Data
theta0 = [1,2,3,5,7,10];

%model
lqr_model = [1.93, 1.93, 1.93, 1.93, 1.93, 1.94];
pid_model = [2.47, 2.47, 2.47, 2.47, 2.47, 2.47];

%real results(avr+sd)
lqr_mean = [4.21, 4.11, 4.60, 3.73, 3.34, 3.00]; %t_fail_lqr
lqr_sd = [2.39, 1.03, 1.32, 1.76, 0.65, 1.52]; % LQR Standard deviation
pid_mean = [1.62, 2.04, 3.28, 1.50, 0.80, 0.79];
pid_sd = [1.32, 2.29, 3.81, 1.14, 0.16, 0.29];

%graphs
figure;
plot(theta0, lqr_model, '--', 'Color', [0.09 0.37 0.65], 'LineWidth', 1.5);
hold on;
plot(theta0, pid_model, '--', 'Color', [0.85 0.35 0.19], 'LineWidth', 1.5);

errorbar(theta0, lqr_mean, min(lqr_sd, lqr_mean), lqr_sd, '-o', 'Color', [0.09 0.37 0.65], 'LineWidth', 1.5, 'MarkerFaceColor',[0.09 0.37 0.65]);
hold on;
errorbar(theta0, pid_mean,  min(pid_sd, pid_mean), pid_sd, '-o', 'Color', [0.85 0.35 0.19], 'LineWidth', 1.5, 'MarkerFaceColor',[0.85 0.35 0.19]);

% axes and labels
xlabel('\theta_0 (deg)');
ylabel('Time(sec)');
title('COMPARISON Of MODEL vs REALITY: T_{fail} / T_s');
legend('LQR-Model', 'PID-Model','LQR-Reality', 'PID-Reality', 'Location', 'best');
grid on;
box off;