%% Line+sd graphs
% Data
theta0 = [1,2,3,5,7,10];
lqr_mean = [0.6365, 0.6365, 0.6365, 0.6365, 0.6365, 0.6365]; %peaktau_lqr
lqr_sd = [0.00, 0.00, 0.00, 0.00, 0.00, 0.00]; % LQR Standard deviation
pid_mean = [0.200, 0.189, 0.185, 0.196, 0.178, 0.194];
pid_sd = [0.016, 0.021, 0.025, 0.019, 0.009, 0.021];

%graphs
figure;
errorbar(theta0, lqr_mean, lqr_sd, '-o', 'Color', [0.09 0.37 0.65], 'LineWidth', 1.5, 'MarkerFaceColor',[0.09 0.37 0.65]);
hold on;
errorbar(theta0, pid_mean, pid_sd, '-o', 'Color', [0.85 0.35 0.19], 'LineWidth', 1.5, 'MarkerFaceColor',[0.85 0.35 0.19]);

% axes and labels
xlabel('\theta_0 (deg)');
ylabel('Peak{\tau}(N.m)');
title('Test B: Peak{\tau} by Initial Sweep Angle');
legend('LQR', 'PID', 'Location', 'best');
grid on;