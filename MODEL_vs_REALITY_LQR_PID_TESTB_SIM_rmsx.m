%% Line+sd graphs
% Data
theta0 = [1,2,3,5,7,10];

%model
lqr_model = [0.18 ,0.36, 0.53, 0.89, 1.24, 1.78];
pid_model = [0.05, 0.09, 0.14, 0.23, 0.32, 0.46];

%real results(avr+sd)
lqr_mean = [7.25, 6.42, 7.65, 8.94, 7.41, 8.72];
lqr_sd = [2.20, 1.44, 1.18, 2.78, 2.20, 2.46]; 
pid_mean = [0.65, 0.95, 0.70, 0.98, 0.74, 0.94];
pid_sd = [0.27, 0.48, 0.22, 0.59, 0.21, 0.39];

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
ylabel('RMS(x)(cm)');
title('MODEL vs REALITY: RMS(x) ');
legend('LQR-Model', 'PID-Model','LQR-Reality', 'PID-Reality', 'Location', 'best');
grid on;
box off;