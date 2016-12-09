function [ results ] = StrategyScore( strategy, enemies, rounds, mistake)
%% evaluate strategy against other strategies (enemies) for ^ rounds.
% Todo: add mistake possibility

if nargin < 3
   rounds = 50;
end

if nargin < 4
   mistake = 0.02;
end

nrOfStrategies = length(enemies);
results = zeros(1,nrOfStrategies);

score = 0;

for j = 1:nrOfStrategies
    
    history = [];
        
    for r = 1: rounds
        
        p1 = strategy.Action(history); % get the move of each prisoner
        
        if r > 1
            p2 = enemies{j}.Action([history(:,2),history(:,1)]); % history columns need to be swapped
        else
            p2 = enemies{j}.Action(history); % history columns need to be swapped
        end
        
        if rand < mistake
           p1 = 1 - p1 ;
        end
        
        if rand < mistake
           p2 = 1 - p2 ;
        end
        
        history = [history; p1 p2]; % update history matrix
        utilities = PrisonersRound(p1, p2); % compute utilities for both prisoners
        score = score + utilities(1);
    end
    
end

results = (score/nrOfStrategies)/rounds;

end

