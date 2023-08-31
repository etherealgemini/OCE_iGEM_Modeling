%% initialize
%initCobraToolbox(false);

%% load models

%modelpath = [pwd filesep 'model'];
%algae_core = readCbModel([modelpath filesep 'iJB785'],'fileType','SBML');
%ecoli_core = readCbModel([modelpath filesep 'iB21_1397'],'fileType','SBML');
%ecoli_core_sucr_digest = readCbModel([modelpath filesep 'iB21_1397'],'fileType','SBML');
%ecoli_core_Sulf = readCbModel([modelpath filesep 'iB21_1397'],'fileType','SBML');

%% modify e.coli BL21 models
% sucrose hyedrolys

Ecoli_BL21 = ecoli_core;
Ecoli_BL21 = addReaction(Ecoli_BL21,'EX_glc__D_e','lowerBound',-1.7); % no straight glucose
Ecoli_BL21 = addReaction(Ecoli_BL21,'EX_sucr_e','lowerBound',-1.7);

Ecoli_BL21 = addReaction(Ecoli_BL21,'SUCRe', ...
    'reactionName','Sucrose hydrolyzing enxyme extracellular', ...
    'metaboliteList',{'h2o[e]','sucr[e]','fru[e]','glc__D[e]'}, ...
    'stoichCoeffList',[-1,-1,1,1], ...
    'lowerBound',-1000, ...
    'subSystem','S-Alternate_Carbon_Metabolism');
ecoli_sol2 = optimizeCbModel(Ecoli_BL21);

%% modify algae
% add sucrose transport
Synechococcus_sp7942 = algae_core;
mblist = {'h[e]','h[c]','sucr[e]','sucr[c]'};
Synechococcus_sp7942 = addMetabolite(Synechococcus_sp7942,'sucr[e]','metName','Sucrose C12H22O11','metFormula','C12H22O11','Charge',0);
Synechococcus_sp7942 = addExchangeRxn(Synechococcus_sp7942,'sucr[e]',0,1000);
Synechococcus_sp7942 = addReaction(Synechococcus_sp7942,'SUCRt2','reactionName','Sucrose transport in via proton symport', ...
    'metaboliteList',mblist, ...
    'subSystem','S_Transport__Extracellular', ...
    'stoichCoeffList',[1;-1;1;-1], ...
    'lowerBound',-1000);

Synechococcus_sp7942 = changeObjective(Synechococcus_sp7942,{'BIOMASS__1','SUCRt2'},1);

%% load models into layout
models.Synechococcus_sp7942 = Synechococcus_sp7942;
models.Ecoli_BL21 = Ecoli_BL21;
modelNames = {'Synechococcus_sp7942';'Ecoli_BL21'};

layout = CometsLayout();
for m = 1:length(modelNames)
    layout = addModel(layout,models.(modelNames{m}));
end

%% load medium into layout

load Data\mediumCommunity.mat;

%this should be modified
minMed = vertcat(minMed,{'co2[e]';'photon550[e]';'photon570[e]';'photon590[e]';'photon610[e]'; ...
    'photon530[e]';'photon510[e]';'photon490[e]';'photon470[e]';'photon450[e]';'photon430[e]'; ...
    'photon410[e]';'photon630[e]';'photon650[e]';'photon670[e]';'photon690[e]'});
minMed = sort(minMed);

for mm = 1:length(minMed)
    minMed{mm} = replace(minMed{mm},"-","__");
    layout = layout.setMedia(minMed{mm},1000);
end
%%

%this should be modified
%minMed = vertcat(minMed,{'co2[e]';'photon530[e]';'photon510[e]';'photon410[e]'});
%minMed = sort(minMed);
%nutrientNames(1)=nutrientNames(2)
nutrientNames = {'fol'};
nutrients = {'fol[e]'};
%%
%layout = layout.setMedia(nutrients{1},1e-5);
for n = 1:length(nutrients)
    layout = layout.setMedia(nutrients{n},1e-5);
end

%layout = layout.setMedia(nutrients{2},1000);

layout.initial_pop = ones(length(modelNames),1).*1e-7;
layout.initial_pop(1) = 7e-7;

cometsDirectory = 'CometsRunDir';

%% params setting

layout.params.writeBiomassLog = true;
layout.params.biomassLogRate = 1;
layout.params.biomassLogName = 'biomassLog.m';
layput.params.biomassLogFormat = 'MATLAB';
layout.params.writeMediaLog = true;
layout.params.mediaLogRate = 1;
layout.params.mediaLogName = 'mediaLog.m';
layput.params.mediaLogFormat = 'MATLAB';
layout.params.writeFluxLog = true;
layout.params.fluxLogRate = 1;
layout.params.fluxLogName = 'fluxLog.m';
layout.params.fluxLogFormat = 'MATLAB';

layout.params.maxSpaceBiomass = 1e3;
layout.params.timeStep = 0.01;
layout.params.maxCycles = 1200;
layout.params.deathRate = 0.1;

%% Prepare metabolic models
for m = 1:length(modelNames)
    modelCurr = models.(modelNames{m});
    minMedMets = find(ismember(modelCurr.mets,minMed));
    for i = 1:length(minMedMets)
        modelCurr.lb(intersect(find(findExcRxns(modelCurr)),find(modelCurr.S(minMedMets(i),:)))) = -1000; % Allow unlimited uptake of nonlimiting nutrients
    end
    limitingMets = find(ismember(modelCurr.mets,nutrients));
    for i = 1:length(limitingMets)
        modelCurr.lb(intersect(find(findExcRxns(modelCurr)),find(modelCurr.S(limitingMets(i),:)))) = -10; % Allow limited uptake of limiting nutrients
    end
    models.(modelNames{m}) = modelCurr;
end

runComets(layout, cometsDirectory)

%% set Biomass rule

 
biomassLogRaw = parseBiomassLog([cometsDirectory filesep layout.params.biomassLogName]);
biomassLog = zeros(size(biomassLogRaw,1)/length(modelNames),length(modelNames));
for i = 1:length(modelNames)
    biomassLog(:,i) = biomassLogRaw.biomass(i:length(modelNames):end);
end
startBiomass = layout.initial_pop;
finalBiomass = biomassLog(end,:);
deltaBiomass = finalBiomass - startBiomass;
totalBiomass = sum(finalBiomass);

modelNamesFormatted = cell(length(modelNames),1);
for m = 1:length(modelNames)
    s = split(modelNames{m},'_');
    modelNamesFormatted{m} = [s{1} '. ' s{2}];
end

close all

%% plot

figure
plotColors = parula(length(modelNames));
for m = 1:length(modelNames)
    plot([1:layout.params.maxCycles+1]*layout.params.timeStep,biomassLog(:,m),'LineWidth',4,'Color',plotColors(m,:))
    hold on
end
set(gca,'FontSize',16)
ylabel('Biomass (gDW)')
xlabel('Time (h)')
legend(modelNamesFormatted)
xlim([0,12])

%%

allMetsFromModels = layout.mets;
COMETSCycles = layout.params.maxCycles;
mediaLogMat = zeros(length(allMetsFromModels),COMETSCycles);

mediaLogRaw = parseMediaLog([cometsDirectory filesep layout.params.mediaLogName]);
mediaLogMetOrder = zeros(length(allMetsFromModels),1);

% Re-order the medium components to match the list in layout.mets
for i = 1:length(allMetsFromModels)
    mediaLogMetOrder(i) = find(ismember(mediaLogRaw.metname(1:length(allMetsFromModels)),allMetsFromModels(i)));
end

for i = 1:COMETSCycles
    currentMedia = mediaLogRaw.amt(find(mediaLogRaw.t == i));
    mediaLogMat(:,i) = currentMedia(mediaLogMetOrder);
end

nutrientsToPlot = zeros(length(nutrients),1);
for i = 1:length(nutrients)
    nutrientsToPlot(i) = find(ismember(allMetsFromModels,nutrients{i}));
end

figure
plot([1:layout.params.maxCycles]*layout.params.timeStep,mediaLogMat(nutrientsToPlot,:)','LineWidth',2)
set(gca,'FontSize',16)
ylabel('Nutrient Amount (mmol)')
xlabel('Time (h)')
legend(nutrientNames)

%%
[secMets,absMets,excTable] = getSecAbsExcMets([cometsDirectory filesep layout.params.fluxLogName],models,layout);

nonzeroSecMetIndices = find(secMets(:,2)); % define the lowest bound of consumption

%selectSecMetIndices = intersect(find(ismember(allMetsFromModels,selectSecMets)),nonzeroSecMetIndices);
selectSecMetIndices = find(ismember(allMetsFromModels,selectSecMets));
figure
plot([1:layout.params.maxCycles]*layout.params.timeStep,smoothdata(mediaLogMat(selectSecMetIndices,:)'),'LineWidth',2)
set(gca,'FontSize',16)
ylabel('Metabolite Amount (mmol)')
xlabel('Time (h)')
legend(selectSecMets)

