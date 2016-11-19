
clear;
ROUNDS = 100;

alwaysCoop = @AlwaysCooperate;
alwaysDefect = @AlwaysDefect;
titForTat = @TitForTat;
turnEvil = @TurnEvil;
random = @Random;

strategiesHandles = {alwaysCoop, alwaysDefect, titForTat, turnEvil, random};
nrOfStrategies = length(strategiesHandles);

results = zeros(nrOfStrategies);

for i = 1:nrOfStrategies
   for j = 1:nrOfStrategies
       
       history = [];
       score = [0,0];
       
       for r = 1: ROUNDS
            p1 = strategiesHandles{i}(history);
            p2 = strategiesHandles{j}(history);
            history = [history; p1 p2];
            utilities = PrisonersRound(p1, p2);
            score(1) = score(1) + utilities(1);
            score(2) = score(2) + utilities(2);
       end
       
       results(i,j) = score(1);
       
       %fprintf('',)
       
    end
end



