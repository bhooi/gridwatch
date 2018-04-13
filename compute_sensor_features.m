
% INPUT: X is a (num_edge_features = 2) x (num_scenarios) x (num_edges) matrix which is
%   output from compute_features
% OUTPUT: Xsensfeat is a (num_sensor_features = 6) x (num_scenarios) x (num_nodes)
%   matrix

function Xfeat = compute_sensor_features(X, incidence_mat)

num_sensor_features = 6;
num_scenarios = size(X, 2);
num_nodes = size(incidence_mat, 2);

Xfeat = nan(num_sensor_features, num_scenarios, num_nodes);

Xp = permute(X, [2 1 3]);
Xp = bsxfun(@minus, Xp, median(Xp, 1));
Xz = bsxfun(@rdivide, Xp, iqr(Xp, 1) + 1e-6);

for sensor_idx = 1:num_nodes
    sensor_edges = incidence_mat(:, sensor_idx);
    Xi = Xz(:,:,sensor_edges == 1);
    
    Xedge = max(abs(Xi), [], 3); % single edge anomaly
    Xave = abs(mean(Xi, 3)); % group anomaly
    Xmad = mad(Xi, 0, 3); % group diversion anomaly
    
    Xsensor = [Xedge Xave Xmad];
    Xfeat(:, :, sensor_idx) = Xsensor';
end


end