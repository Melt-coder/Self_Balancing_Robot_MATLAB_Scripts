%% Line+sd graphs
% Data
theta0 = [1,2,3,5,7,10];

%model
lqr_model = [0.0902, 0.1805, 0.2707, 0.4512, 0.6317, 0.6374];
pid_model = [0.0055, 0.0111, 0.0166, 0.0277, 0.0387, 0.0553];

%real results(avr+sd)
lqr_mean = [0.6365, 0.6365, 0.6365, 0.6365, 0.6365, 0.6365]; %peaktau_lqr
lqr_sd = [0.00, 0.00, 0.00, 0.00, 0.00, 0.00]; % LQR Standard deviation
pid_mean = [0.200, 0.189, 0.185, 0.196, 0.178, 0.194];
pid_sd = [0.016, 0.021, 0.025, 0.019, 0.009, 0.021];

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
ylabel('Peak{\tau}(N.m)');
title('MODEL vs REALITY: Peak{\tau} ');
legend('LQR-Model', 'PID-Model','LQR-Reality', 'PID-Reality', 'Location', 'best');
grid on;
box off;