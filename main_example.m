clearvars;
% File storing graph information (M). M is in Matpower format. 
load('data/example_graph.mat', 'M'); 

% File storing example simulated data: e.g. Ira is a (num_scenarios x
% num_edges) matrix containing real currents for the anomalous scenarios.
% V/I stand for voltage and current; r/i stand for real and imaginary; a/n
% stand for anomalous and normal scenarios. 
load('data/example_groundtruth.mat', 'Ira', 'Iia', 'Irn', 'Iin', 'Vra', 'Via', 'Vrn', 'Vin'); 

% File storing example sensor data that we want to perform anomaly
% detection on. true_labels is a binary vector containing ones where
% anomalies exist, used only for evaluation. 
load('data/example_data.mat', 'Ir', 'Ii', 'Vr', 'Vi', 'true_labels'); 

%% Greedy sensor selection algorithm
c = 50;
sensors_greedy = selection_greedy(M, 5, Ira, Iia, Irn, Iin, Vra, Via, Vrn, Vin, c);

%% Anomaly detection algorithm
scores = detectanom_gridwatch(Ir, Ii, Vr, Vi, M, sensors_greedy{1});

%% Plot anomalousness score over time (black line) and anomalies (red crosses)

figure('Position', [0 0 600 400]);
semilogy(1+scores, 'k-', 'LineWidth', 2); hold on;
xlabel('Time (h)');
ylabel('Anomaly score');
sorted = sort(scores, 'descend');
thres = sorted(sum(true_labels));
xl = xlim;
plot(xl, [thres thres], 'b--', 'LineWidth', 2);
semilogy(find(true_labels), 1+scores(true_labels == 1), 'rx', 'LineWidth', 3, 'MarkerSize', 12);
set(findall(gcf,'Type','Axes'),'FontSize',28);
set(findall(gcf,'Type','Text'),'FontSize',32);