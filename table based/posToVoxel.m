function vox = posToVoxel(pos,gridVectors,species)
% creates a voxelisation of the data in 'pos' based on the bin centers in
% 'gridVectorstors' (can be created e.g. using 'gridVectorstorFromPos.m') for the
% atoms in species. Species can be a species list as in {'Fe','Mn'}. Ions
% if no atoms are allocated. Alternatively it can be a logical vector with
% the same length as the pos file.
% if no species variable is given, all atoms/ions are taken
% to get all ranged atoms, use species = categories(pos.atoms)
% to get all ranged ions, use species = categories(pos.ions)

if ~exist('species','var')
    species = true(height(pos),1);
end


if iscell(species) % create logical vector with true for all elements to be included
    % check if atomic or ionic count is calculated
    if any(ismember(pos.Properties.VariableNames,'atom'))
        species = ismember(pos.atom,species);
        
    elseif any(ismember(pos.Properties.VariableNames,'ion'))
        species = ismember(pos.ion,species);
        
    else
        error('unknown table format');
    end   
end

pos = [pos.x(species), pos.y(species), pos.z(species)];



%% calcualting 3d histogram

bin = [gridVectors{1}(2)-gridVectors{1}(1)...
    gridVectors{2}(2)-gridVectors{2}(1)...
    gridVectors{3}(2)-gridVectors{3}(1)];

% calculating bin association (I do not pretend to know what all of this
% does)
for d = 1:3
    % calculate edge vecotrs from bin centers
    edgeVec{d} = [gridVectors{d}-bin(d)/2 gridVectors{d}(end)+bin(d)/2];
    
    [useless loc(:,d)] = histc(pos(:,d),edgeVec{d},1);
    sz(d) = length(edgeVec{d})-1;
end
clear useless

% for points on the border
sz = max([sz; max(loc,[],1)]);

% count of atoms in each voxel
vox = accumarray(loc,1,sz);
