%% Line+sd graphs
% Data
theta0 = [1,2,3,5,7,10];

%model
lqr_model = [0.63, 1.25, 1.88, 3.13, 4.38, 6.26];
pid_model = [0.35, 0.70, 1.04, 1.74, 2.44, 3.48];

%real results(avr+sd)
lqr_mean = [15.42, 18.49, 16.67, 19.3, 16.68, 17.82];
lqr_sd = [3.14, 5.81, 3.75, 3.84, 2.98, 3.71]; 
pid_mean = [1.47, 2.03, 1.74, 2.02, 1.50, 1.88];
pid_sd = [0.50, 0.58, 0.83, 0.93, 0.39, 0.76];

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
ylabel('max|x|(cm)');
title('MODEL vs REALITY: max|x| ');
legend('LQR-Model', 'PID-Model','LQR-Reality', 'PID-Reality', 'Location', 'best');
grid on;
box off;