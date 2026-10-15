%% Line+sd graphs
% Data
theta0 = [1,2,3,5,7,10];

%model
lqr_model = [0.0016, 0.0033, 0.0049, 0.0082, 0.0115, 0.0116];
pid_model = [0.0003, 0.0005, 0.0008, 0.0013, 0.0019, 0.0027];

%real results(avr+sd)
lqr_mean = [0.539, 0.513, 0.493, 0.510, 0.478, 0.489];
lqr_sd = [0.036, 0.011, 0.030, 0.015, 0.013, 0.033]; 
pid_mean = [0.062, 0.058, 0.047, 0.071, 0.082, 0.094];
pid_sd = [0.024, 0.019, 0.017, 0.022, 0.009, 0.009];

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
ylabel('RMS{\tau}(N.m)');
title('MODEL vs REALITY: RMS{\tau} ');
legend('LQR-Model', 'PID-Model','LQR-Reality', 'PID-Reality', 'Location', 'best');
grid on;
box off;