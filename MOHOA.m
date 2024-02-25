function Archive=MOHOA(varNum,costFunction)
Archive_size=100;   % Repository Size
alpha=0.1;  % Grid Inflation Parameter
nGrid=10;   % Number of Grids per each Dimension
beta=4; %=4;    % Leader Selection Pressure Parameter
gamma=2;    % Extra (to be deleted) Repository Member Selection Pressure

%%Define problem parameters

%% HOA Parameters
N=150; % Number of search agents
maxLoop=100; % Maximum numbef of iterations

VelMax=0.2*ones(1,varNum);
VelMin=-VelMax;

w=.999;
Pn=0.04; %Number of Best hourse in Imitaion
Qn=0.04; %Number of Worst hourse in Defense

Alpha.g=1.50;      % Grazing
Alpha.d=0.5;       % Defense Mechanism
Alpha.h=1.5;       % Hierarchy

Beta.g=1.50;       % Grazing
Beta.d=0.20;       % Defense Mechanism
Beta.h=0.9;        % Hierarchy
Beta.s=0.20;       % Sociability

Gamma.g=1.50;      % Grazing
Gamma.d=0.10;      % Defense Mechanism
Gamma.h=0.50;      % Hierarchy
Gamma.s=0.10;      % Sociability
Gamma.i=0.30;      % Imitation
Gamma.r=0.05;      % Random (Wandering and Curiosity)

Delta.g=1.50;      % Grazing
Delta.r=0.10;      % Random (Wandering and Curiosity)

%% Define Function and Solution
solution=[];
solution.Position=[];
solution.Cost=0;
solution.Velocity=ones(1,varNum);
%% Initialization Step
Hourse=CreateEmptyParticle(N);

for i=1:N
    Hourse(i).Position=round(rand(1,varNum));
    Hourse(i).Cost=costFunction(Hourse(i).Position);
end
PersonalBest=Hourse;
% Find best GrassHoper
[value,index]=sort([Hourse.Cost]);
Hourse=DetermineDomination(Hourse);

Archive=GetNonDominatedParticles(Hourse);

Archive_costs=GetCosts(Archive);
G=CreateHypercubes(Archive_costs,nGrid,alpha);
for i=1:numel(Archive)
    [Archive(i).GridIndex Archive(i).GridSubIndex]=GetGridIndex(Archive(i),G);
    ArchivePos(i,:)=Archive(i).Position;
end
% Main loop
for it=1:maxLoop
    for i=1:N
        Costi(i)=Hourse(i).Cost(2);
    end
    [value,index]=sort(Costi);
    
    Hourse=Hourse(index);
    for i=1:N
        AllPositin(i,:)=Hourse(i).Position;
    end
    clear rep2
    clear rep3
    
    P=floor(Pn*N);
    Q=floor(Qn*N);
    %     GoodPosition=mean(AllPositin(1:P,1));
    %     BadPosition=mean(AllPositin(N-Q:N,1));
    %     MeanPosition=mean([Hourse.Cost]);
   
    
    GoodPosition=mean(ArchivePos);
    BadPosition=mean(AllPositin(N-Q:N,:));
    MeanPosition=mean(AllPositin);
    GlobalBest=SelectLeader(Archive,beta);
    for i=1:N
        if i<=.1*N % Alpha Hourses
            Hourse(i).Velocity = +Alpha.h*rand([1,varNum]).*(GlobalBest.Position-Hourse(i).Position)...
                -Alpha.d*rand([1,varNum]).*(Hourse(i).Position)...
                +Alpha.g*(0.95+0.1*rand)*(PersonalBest(i).Position-Hourse(i).Position);
            
        elseif i<=.3*N % Beta Hourses
            Hourse(i).Velocity = Beta.s*rand([1,varNum]).*(MeanPosition-Hourse(i).Position)...
                -Beta.d*rand([1,varNum]).*(BadPosition-Hourse(i).Position)...
                +Beta.h*rand([1,varNum]).*(GlobalBest.Position-Hourse(i).Position)...
                +Beta.g*(0.95+0.1*rand)*(PersonalBest(i).Position-Hourse(i).Position);
        elseif i<=.6*N % Gama Hourses
            Hourse(i).Velocity = Gamma.s*rand([1,varNum]).*(MeanPosition-Hourse(i).Position)...
                +Gamma.r*rand([1,varNum]).*(Hourse(i).Position)...
                -Gamma.d*rand([1,varNum]).*(BadPosition-Hourse(i).Position)...
                +Gamma.h*rand([1,varNum]).*(GlobalBest.Position-Hourse(i).Position)...
                +Gamma.i*rand([1,varNum]).*(GoodPosition-Hourse(i).Position)...
                +Gamma.g*(0.95+0.1*rand)*(PersonalBest(i).Position-Hourse(i).Position);
            
        else              % Delta Hourses
            Hourse(i).Velocity = +Delta.r*rand([1,varNum]).*(Hourse(i).Position)...
                +Delta.g*(0.95+0.1*rand)*(PersonalBest(i).Position-Hourse(i).Position);
        end
        % Check Boundari
        Hourse(i).Velocity=max(Hourse(i).Velocity,VelMin);
        Hourse(i).Velocity=min(Hourse(i).Velocity,VelMax);
        
        % Update Position
        R = rand(1,varNum);
        cStep=1./(1+exp(-Hourse(i).Velocity));
        Hourse(i).Position =R<cStep;% Hourse(i).Position + Hourse(i).Velocity;
        
        % Check Boundari
        %         Hourse(i).Position=max(Hourse(i).Position,lowerBound);
        %         Hourse(i).Position=min(Hourse(i).Position,upperBound);
        
        
        
        %calc fitness
        Hourse(i).Cost=costFunction(Hourse(i).Position);
        %% Update Personal Best
        %Update local and global best solution
        if Dominates( Hourse(i),PersonalBest(i))
            PersonalBest(i)=Hourse(i);
        elseif Dominates(PersonalBest(i),Hourse(i))
            % Do Nothing
        else
            if rand<0.5
                PersonalBest(i)=Hourse(i);
            end
        end
        % Update Global Best
        if Dominates( Hourse(i),GlobalBest)
            GlobalBest=Hourse(i);
        end
        
    end
    Hourse=DetermineDomination(Hourse);
    non_dominated_wolves=GetNonDominatedParticles(Hourse);
    
    Archive=[Archive
        non_dominated_wolves];
    
    Archive=DetermineDomination(Archive);
    Archive=GetNonDominatedParticles(Archive);
    
    for i=1:numel(Archive)
        [Archive(i).GridIndex Archive(i).GridSubIndex]=GetGridIndex(Archive(i),G);
    end
    
    if numel(Archive)>Archive_size
        EXTRA=numel(Archive)-Archive_size;
        Archive=DeleteFromRep(Archive,EXTRA,gamma);
        
        Archive_costs=GetCosts(Archive);
        G=CreateHypercubes(Archive_costs,nGrid,alpha);
        
    end
    
    disp(['In iteration ' num2str(it) ': Number of solutions in the archive = ' num2str(numel(Archive))]);
    save results
    
    % Results
    
    costs=GetCosts(Hourse);
    Archive_costs=GetCosts(Archive);
    
    
    hold off
    plot(costs(1,:),costs(2,:),'k.');
    hold on
    plot(Archive_costs(1,:),Archive_costs(2,:),'rd');
    legend('Hourses','Non-dominated solutions');
    drawnow
    
    
    % Update Parameters
    Alpha.d=Alpha.d*w;
    Alpha.g=Alpha.g*w;
    Beta.d=Beta.d*w;
    Beta.s=Beta.s*w;
    Beta.g=Beta.g*w;
    Gamma.d=Gamma.d*w;
    Gamma.s=Gamma.s*w;
    Gamma.r=Gamma.r*w;
    Gamma.i=Gamma.i*w;
    Gamma.g=Gamma.g*w;
    Delta.r=Delta.r*w;
    Delta.g=Delta.g*w;
end