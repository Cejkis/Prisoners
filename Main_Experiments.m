%% Simulation of population over several iterations.
clf
clear
figure(1)

%% Parameters
%The number of iterations the complete simulation will run for.
epochs=500;

% The initial magnitude of the population vector.
popMag=1000;

%The lowest possible sub-population before dying out.
critPop=1;

%Rounds to run the pd-game for.
gameRounds=100;

%How much of the pd rounds that will be cut of. Eg 0.80 would mean that 10%
%at the beginning and end of the rounds will be discarded in the average.
exPer=0.90;

%Setting for having a risk of mistakes happening.
mistakeProb=0.035;

%Severity scale. Used to either suppress or increase the harshness of the
%dynamics. Default is 1;
sevScale=1.0;

%% Set up the involved strategies.

alwaysCoop = AlwaysCooperate;
alwaysDefect = AlwaysDefect;
titForTat = TitForTat;
turnEvil = TurnEvil;
random = Random;
iCTTBMF=IllCountToThreeButMayForget;
wWYDHT=WhatWillYouDoHT(15,0.25);
twoInARow=TwoInARow;

% rNNNet=RNNStrategy();
NN1 = NeuralNet(3,[4 2],10,gameRounds*3);
NN2 = NeuralNet(3,[4 2],10,gameRounds*3);
NN3 = NeuralNet(3,[4 2],10,gameRounds*3);

%Store in cell array.
% strategiesHandles = {alwaysCoop, alwaysDefect, titForTat, turnEvil, random,iCTTBMF,wWYDHT,twoInARow};

global Strategies;

Strategies = {titForTat,alwaysDefect, NN1,NN2, NN3, iCTTBMF, twoInARow};
% Strategies = {NN1,NN2,NN3, alwaysDefect};
nrOfStrategies = length(Strategies);

%% Set up initial population.

population=ones(nrOfStrategies,1);
population=population/norm(population).*popMag;

% Set up the line animations.
%Preallocation.
container=repmat(animatedline,nrOfStrategies,1);

%Remove the dum-dum line.
clf

%Add the real lines.
for n=1:nrOfStrategies
    aline=animatedline('Color',[rand rand rand]);
    set(aline,'DisplayName',class(Strategies{n}));
    container(n)=aline;
end

legend('Location','eastoutside');
leg=legend('show');
set(leg,'FontSize',10);

%% CORE ALGO
startSave=floor(gameRounds*(1-exPer)/2);
endsave=gameRounds-startSave;

%For all of the epochs.
for n=1:epochs
    c = clock;
    fprintf('epoch %d \n',n);
    disp(datestr(datenum(c(1),c(2),c(3),c(4),c(5),c(6))));
    
    %Reset the states.
    iCTTBMF.resetState();
    
    %Draw the pop dynamics.
    for s=1:nrOfStrategies
        addpoints(container(s),n,population(s));
    end
    drawnow;
    
    results = zeros(nrOfStrategies);
    
    %Play all strategies against eachother.
    for i = 1:nrOfStrategies
        for j = nrOfStrategies:-1:(i) %+1 if you dont want to play yourself.
            
            %Extract the agents.
            a1=Strategies{i};
            a2=Strategies{j};
            
            %Play the PD-game.
            utilities=pdGame(a1,a2,gameRounds,mistakeProb,i,j);
            
            %Extract only the relevant parts of the utility series.
            utilities=utilities(startSave:endsave,:);
            avgUtil=mean(utilities);
            
            %The result is the average payoff for strat i against j. Making
            %use of symetry.
            results(i,j) = avgUtil(1);
            results(j,i)=avgUtil(2);
            
        end
    end
    
    %Calculate current epoch average score for all strategies.
    avgScorePerStrat=sum(results,2)/size(results,2);
    
    %Calculate current epoch average score for all strategies, taking the
    %size of the population of the opposing strategy into account.
    %popScale=repmat(population'./sum(population),[size(results,1) 1]);
    %scaledResults=results.*popScale;
    %avgScorePerStrat=sum(scaledResults,2)/size(results,2);
    
    %Total average for the epoch.
    %avgScoreForEpoch=mean(avgScorePerStrat);
    
    %Weighted average for the epoch.
    popShare=population./sum(population);
    avgScoreForEpoch=sum(avgScorePerStrat.*popShare);
    
    %Get the percentage of the average each strategy reached.
    fitness=avgScorePerStrat./avgScoreForEpoch;
    
    %Apply the severity scale.
    fitness=ones(size(fitness))-(ones(size(fitness))-fitness)*sevScale;
    
    %Set the change in population depending on the fitness.
    population=population.*fitness;
    
    %Renormalize to correct population magnitude.
    population=population./norm(population).*popMag;
    
    %If strategies falls below the critical point, they die and are removed.
    Gr=(population<critPop); %Gr-->GrimReaper has arrived.
    idx=find(Gr);
    if (idx)
        for p=1:length(idx)
            %Remove the strategy/strategies.
            Strategies{idx(p)}=[];
            
            %Remove the line(s) from the update list.
            container(idx(p))=[];
        end
        
        %Reformat the cell arrays.
        Strategies=Strategies(~cellfun('isempty',Strategies));
        
        %Recreate the legend.
        %leg=legend(container);
        
        %Update the count.
        nrOfStrategies=length(Strategies);
        
        %Update the population variable.
        population(Gr)=0;
        population=population(population~=0);
        
    end
    if(numel(population)==1)
        %Last species standing. Terminate simulation.
        break;
    end
    
    %Round to an integer amount of agents.
    %population=round(population);
end

%Print the strategies still alive. And their share of the population.
disp(Strategies)
disp(population')










