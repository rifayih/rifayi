clc;
clear;

% Load EBSD data from your .ctf file
ebsd = EBSD.load('Project 1 Specimen 1 Site 2 Map Data 2.ctf', ...
                 'convertEuler2SpatialReferenceFrame');

% Get unique phase IDs (excluding 0 which is unindexed/no phase)
phaseIDs = unique(ebsd.phase);
phaseIDs = phaseIDs(phaseIDs ~= 0);

% Loop through each phase
for i = 1:length(phaseIDs)
    currentPhaseID = phaseIDs(i);
    
    % Select EBSD data for this phase
    ebsd_phase = ebsd(ebsd.phase == currentPhaseID);
    
    % Try to get orientations, skip phase if none
    try
        ori = ebsd_phase.orientations;
    catch
        warning(['No indexed orientations for phase ID: ', num2str(currentPhaseID)]);
        continue;
    end
    
    if isempty(ori)
        warning(['Empty orientation data for phase ID: ', num2str(currentPhaseID)]);
        continue;
    end
    
    % Get crystal symmetry of phase
    cs = ebsd_phase.CS;
    
    % Get phase name from crystal symmetry object
    phaseName = char(cs.mineral); % phase name
    
    % Get symmetry string to choose Miller indices
    symName = char(cs.pointGroup);
    
    % Define Miller indices based on symmetry
    if contains(symName, 'm-3m') || contains(symName, '4/mmm')
        h = [Miller(1,0,0,cs), Miller(1,1,0,cs), Miller(1,1,1,cs)];
    elseif contains(symName, '6/mmm') || contains(symName, '6/m')
        h = [Miller(0,0,0,1,cs), Miller(1,0,-1,0,cs), Miller(1,0,1,0,cs)];
    else
        h = [Miller(1,0,0,cs), Miller(0,1,0,cs), Miller(0,0,1,cs)];
    end
    
    % Plot pole figure
    figure('Name', ['Pole Figure - ' phaseName], 'NumberTitle', 'off');
    plotPDF(ori, h, 'contourf', 'antipodal', 'silent');
    mtexColorMap parula;
    mtexColorbar('title', ['Density - ' phaseName]);
end
%plotPDF(ori, h, 'antipodal', 'silent');
%mtexColorbar('title', ['Density - ' phaseName]);