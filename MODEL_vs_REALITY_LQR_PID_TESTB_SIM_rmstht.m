%% Line+sd graphs
% Data
theta0 = [1,2,3,5,7,10];

%model
lqr_model = [0.04, 0.08, 0.13, 0.21, 0.30, 0.42];
pid_model = [0.08, 0.15, 0.23 ,0.38 ,0.53 ,0.75];

%real results(avr+sd)
lqr_mean = [5.52, 5.04, 4.56, 5.06, 5.13, 6.18]; %RMStht_lqr
lqr_sd = [0.80, 0.78, 0.17, 0.37, 0.45, 1.04]; % LQR Standard deviation
pid_mean = [6.20, 6.64, 5.21, 8.52, 10.95, 13.12];
pid_sd = [1.33, 0.66, 1.45, 2.57, 1.97, 1.61];

%graphs
figure;
plot(theta0, lqr_model, '--', 'Color', [0.09 0.37 0.65], 'LineWidth', 1.5);
hold on;
plot(theta0, pid_model, '--', 'Color', [0.85 0.35 0.19], 'LineWidth', 1.5);

errorbar(theta0, lqr_mean, lqr_sd, '-o', 'Color', [0.09 0.37 0.65], 'LineWidth', 1.5, 'MarkerFaceColor',[0.09 0.37 0.65]);
hold on;
errorbar(theta0, pid_mean, pid_sd, '-o', 'Color', [0.85 0.35 0.19], 'LineWidth', 1.5, 'MarkerFaceColor',[0.85 0.35 0.19]);

% axes and labels
xlabel('\theta_0 (deg)');
ylabel('RMS{\theta}(deg)');
title('MODEL vs REALITY: RMS{\theta} ');
legend('LQR-Model', 'PID-Model','LQR-Reality', 'PID-Reality', 'Location', 'best');
grid on;
box off;