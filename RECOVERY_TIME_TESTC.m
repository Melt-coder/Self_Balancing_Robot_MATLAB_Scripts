%% Data
lqr_trials = [2.17, 0.58, 1.13, 1.73, 3.41]; %lqr Recovery times 
pid_trials = [0.53, 0.35, 0.50, 0.90, 3.43];
lqr_median = median(lqr_trials);
pid_median = median(pid_trials);

%graphs
figure;
h1= bar(1, lqr_median, 'FaceColor',[0.90 0.95 0.99], 'EdgeColor', [0.09 0.37 0.65], 'LineWidth',1.5,'BarWidth',0.6); 
hold on;
h2= bar(2, pid_median, 'FaceColor',[0.99 0.93 0.90], 'EdgeColor', [0.85 0.35 0.19], 'LineWidth',1.5,'BarWidth',0.6);

jitter_lqr = 1+(rand(1,length(lqr_trials))-0.5)*0.25;
jitter_pid = 2+(rand(1,length(pid_trials))-0.5)*0.25;
scatter(jitter_lqr, lqr_trials, 40,[0.09 0.37 0.65], 'filled', 'MarkerFaceAlpha', 0.7);
scatter(jitter_pid, pid_trials, 40,[0.85 0.35 0.19], 'filled', 'MarkerFaceAlpha', 0.7);

set(gca, 'XTick', [1,2], 'XTickLabel', {'LQR', 'PID'}); %gca=get current axis
xlim([0.5, 2.5]);
ylabel('Recovery Time (sec)');
legend([h1,h2],{'LQR (median)', 'PID (median)'}, 'Location', 'northoutside', 'Orientation', 'horizontal','Box','off');
box off;
grid on;