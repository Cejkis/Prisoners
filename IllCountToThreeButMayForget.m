function [ out ] = IllCountToThreeButMayForget( history )
%IllCountToThreeButMayForget Strategy that counts up to three defects. If this limit is
%passed, it will defect constantly untill it forgets its grudge.

%state the global variable. (state)
global threeCounter;

%cooperate initially. 
if size(history,1) ==0
    out = 1;
    return;
end

%Check if last round was a defect and counter not already passed.
if (history(end,2)==0)
    threeCounter=threeCounter+1;
end

%Randomly forget the grudge (or count).
if(rand>.75)
    clc
    disp('I seem to have forgotten something.')
    threeCounter=0;
end

%If counter has reched 3 or more then always defect.
if (threeCounter>=3)
    clc
    disp('Now im angry!')
    out = 0;
else
    %Play nice.
    out =1;
end

