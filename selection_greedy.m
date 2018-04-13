% Run GridWatch-S greedy sensor selection.
% INPUT: 
% - M_in: power grid graph, in Matpower format
% - nclust_choices: an array of numbers of sensors we want to select. E.g. if
% you pass in [5, 10], the function output will be a cell array whose 1st
% element is the best 5 sensors, and whose 2nd element is the best 10
% sensors. 
% - Ira, etc: Time series of simulated current (I) or voltage (V) in real (r)
% or imaginary components (i) for normal (n) or anomalous (a) data. E.g. 
% - Ira is a (num_scenarios x num_edges) matrix containing real currents for 
% the anomalous scenarios.
% - c: threshold parameter (roughly, how certain we need to be to declare
% an anomaly as caught). 

% OUTPUT: 
% - sensors_greedy: a cell array where each element is the best k sensors, 
% for values of k corresponding to nclust_choices. 

function sensors_greedy = selection_greedy(M_in, nclust_choices, Ira, Iia, Irn, Iin, Vra, Via, Vrn, Vin, c)

num_anom = size(Ira, 1);
num_nodes = size(M_in.bus, 1);

% Xa, Xn, Z are (features) x (scenarios) x (sensors)
Xa = compute_features(M_in, Ira, Iia, Vra, Via);
Xn = compute_features(M_in, Irn, Iin, Vrn, Vin);
incidence_mat = abs(get_incidence_matrix(M_in));

Xfeata = compute_sensor_features(Xa, incidence_mat);
Xfeatn = compute_sensor_features(Xn, incidence_mat);
Za = bsxfun(@minus, Xfeata, median(Xfeatn, 2));
Za = abs(bsxfun(@rdivide, Za, iqr(Xfeatn, 2) + 1e-3));
Za = Za > c;

anoma = reshape(max(Za), [size(Za, 2) size(Za, 3)]); % sensor anom scores

%%
% choose sensors S using greedy algorithm. A is the anomalousness of each
% scenario based on the current S
A = zeros(num_anom, 1);
S = [];
for i = 1:max(nclust_choices)
    priority = nan(num_nodes, 1);
    for j = 1:num_nodes
        priority(j) = sum(max(A, anoma(:, j))); % priority is # of anomalous cases flagged if we add sensor j
    end
    if all(priority == priority(1)) % if all priorities are equal, we caught all the anomalies, most likely due to too small c
        error('Greedy algorithm terminated after too few sensors chosen. This can usually be fixed by increasing the c parameter.');
    end
    [~, best_idx] = max(priority);
    S = [S, best_idx];
    A = max(A, anoma(:, best_idx));
    fprintf('coverage fraction: %.3f\n', sum(A) / length(A));
end
for i = 1:length(nclust_choices)
    nclust = nclust_choices(i);
    sensors_greedy{i} = S(1:nclust);
end
