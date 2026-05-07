function [normalized, mu, sigma] = normalize_features(features)
    mu = mean(features, 1);
    sigma = std(features, 0, 1);
    sigma(sigma < 1e-8) = 1;
    normalized = (features - mu) ./ sigma;
end
