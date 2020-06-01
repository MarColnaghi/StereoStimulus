function code = exp_bpod
% prova   Code for the ViRMEn experiment prova.
%   code = prova   Returns handles to the functions that ViRMEn
%   executes during engine initialization, runtime and termination.

% Begin header code - DO NOT EDIT
code.initialization = @initializationCodeFun;
code.runtime = @runtimeCodeFun;
code.termination = @terminationCodeFun;
% End header code - DO NOT EDIT


% --- INITIALIZATION code: executes before the ViRMEn engine starts.
function vr = initializationCodeFun(vr)
vr.a = arduino('COM5', 'Uno', 'Libraries', 'RotaryEncoder');
vr.encoder = rotaryEncoder(vr.a,'D3','D2', 1024);
vr.friction = 0.3;
vr.i = 1;
vr.numberofPresentations = 1; % Number of Object*Position Unity (basically 2x2)
vr.numberofShapes = 2;
vr.numberofPositions = 2;
vr.numberofObjects = 1; % Number of Presentations of each Condition
vr.numberofDistances = 3; % Number of starting points
vr.maxTrials = vr.numberofObjects*vr.numberofPositions*vr.numberofDistances;
vr.objPosition = [ones(vr.numberofDistances*vr.numberofShapes,1) ; -ones(vr.numberofDistances*vr.numberofShapes,1)];
vr.newWorldIndx = repmat(([zeros(vr.numberofDistances,1); ones(vr.numberofDistances,1)]+1)',1, vr.numberofPositions)';
vr.startingPoints = linspace(-2000,-1000, vr.numberofDistances);
vr.startingDistances = ceil(repmat(vr.startingPoints,1, vr.numberofShapes*vr.numberofPositions)');
vr.finalCombinations = [vr.objPosition, vr.newWorldIndx, vr.startingDistances];
vr.finalC = repmat(vr.finalCombinations, vr.numberofPresentations, 1)

for c = 1:length(vr.finalC);
    temp = vr.finalC(c, :);
    shufflepos = ceil(rand*length(vr.finalC));
    vr.finalC(c, :) = vr.finalC(shufflepos, :);
    vr.finalC(shufflepos, :) = temp;
end

vr.newWorldIndx(end+1) = 2;
vr.objPosition(end+1) = 1;
vr.startingDistances(end+1) = -1000;

vr.floorWidth = eval(vr.exper.variables.floorWidth);
vr.floorLength = eval(vr.exper.variables.floorLength);
vr.floorRatio = vr.floorLength/vr.floorWidth;
lstCone = vr.worlds{1}.objects.vertices(vr.worlds{1}.objects.indices.objectTarget,:);
lstCyl = vr.worlds{2}.objects.vertices(vr.worlds{2}.objects.indices.objectTarget,:);
vr.cylinderTriangulation = vr.worlds{2}.surface.vertices(1:2,lstCyl(1):lstCyl(2));
vr.coneTriangulation = vr.worlds{1}.surface.vertices(1:2,lstCone(1):lstCone(2));
vr.currentWorld = vr.finalC(vr.i,2);
vr.worlds{1}.surface.vertices(1,lstCone(1):lstCone(2)) = vr.coneTriangulation(1,:)*vr.finalC(vr.i,1);
vr.worlds{1}.surface.vertices(2,lstCone(1):lstCone(2)) = vr.coneTriangulation(2,:);
vr.worlds{2}.surface.vertices(1,lstCyl(1):lstCyl(2)) = vr.cylinderTriangulation(1,:)*vr.finalC(vr.i,1);
vr.worlds{2}.surface.vertices(2,lstCyl(1):lstCyl(2)) = vr.cylinderTriangulation(2,:);
vr.position(2) = vr.finalC(vr.i,3);



% --- RUNTIME code: executes on every iteration of the ViRMEn engine.
function vr = runtimeCodeFun(vr)
if  vr.position(2) > 100
    vr.i = vr.i + 1;
    vr.position(2) = vr.finalC(vr.i,3);
    vr.currentWorld = vr.finalC(vr.i,2);
    if vr.currentWorld == 1
        lstCone = vr.worlds{1}.objects.vertices(vr.worlds{vr.currentWorld}.objects.indices.objectTarget,:);
        vr.worlds{1}.surface.vertices(1,lstCone(1):lstCone(2)) = vr.coneTriangulation(1,:) * vr.finalC(vr.i,1);
        vr.worlds{1}.surface.vertices(2,lstCone(1):lstCone(2)) = vr.coneTriangulation(2,:);
        %vr.coneTriangulation = vr.worlds{1}.surface.vertices(1:2,lstCone(1):lstCone(2));
    elseif vr.currentWorld == 2
        lstCyl = vr.worlds{2}.objects.vertices(vr.worlds{vr.currentWorld}.objects.indices.objectTarget,:);
        vr.worlds{2}.surface.vertices(1,lstCyl(1):lstCyl(2)) = vr.cylinderTriangulation(1,:) * vr.finalC(vr.i,1);
        vr.worlds{2}.surface.vertices(2,lstCyl(1):lstCyl(2)) = vr.cylinderTriangulation(2,:);
        %vr.cylinderTriangulation = vr.worlds{2}.surface.vertices(1:2,lstCyl(1):lstCyl(2));
    end
    vr.dp(:) = 0;
    if vr.i == size(vr.finalC,1)
       vr.experimentEnded = true;
    end
end

if vr.collision
   % test if the animal is currently in collision
   % reduce the x and y components of displacement
   vr.dp(1:2) = vr.dp(1:2) * vr.friction;
end


% --- TERMINATION code: executes after the ViRMEn engine stops.

function vr = terminationCodeFun(vr)
disp(['The animal received rewards.']);
%EndBpod();