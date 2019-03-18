function [ sInner,sOuter,sHeadBEM, sHead ] = bem_surfaces_brainstorm( sMri,sHead,Cortex,nvert,thickness,Brainstorm_route )
sTemplate = my_bst_get(Brainstorm_route, 'ICBM152');
if isempty(sTemplate)
    bst_error(['The template anatomy ICBM152 is not available.' 10 ...
               'Please update Brainstorm...'], 'BEM surfaces', 0);
    return
end
% Get subject file
TemplateCortexFile = bst_fullfile(sTemplate.FilePath, 'tess_cortex_pial_low.mat');
TemplateInnerFile  = bst_fullfile(sTemplate.FilePath, 'tess_innerskull.mat');
TemplateMriFile    = bst_fullfile(sTemplate.FilePath, 'subjectimage_T1.mat');
sMriTemplate = load(TemplateMriFile, 'NCS', 'SCS');

tess2mri_interp  = my_tess_interp_mri( sMri,sHead );
sHead.mrimask = tess_mrimask(size(sMri.Cube), tess2mri_interp);
sHeadBEM = my_tess_envelope( sHead,sMri, 'mask_head', nvert(1) );
sCortex = my_tess_envelope( Cortex,sMri, 'convhull', nvert(2) );
TemplateCortex = my_in_tess_bst(TemplateCortexFile, 0);
sTemplateCortex = my_tess_envelope(TemplateCortex,sMriTemplate, 'convhull', nvert(3), 0.001);
%sTemplateCortex = my_tess_envelope(TemplateCortexFile, 'convhull', nvert(3), 0.001, TemplateMriFile);
sTemplateInner = my_in_tess_bst(TemplateInnerFile, 0);
% Downsample template inner skull if necessary
if (length(sTemplateInner.Vertices) > 3000)
    ratio = 1000 ./ length(sTemplateInner.Vertices);
    [sTemplateInner.Faces, sTemplateInner.Vertices] = reducepatch(sTemplateInner.Faces, sTemplateInner.Vertices, ratio);
end

vHead        = bst_bsxfun(@minus, sHeadBEM.Vertices,        sCortex.center)      * sCortex.R;
vCortex      = bst_bsxfun(@minus, sCortex.Vertices,      sCortex.center)      * sCortex.R;
% vCortexOrig  = bst_bsxfun(@minus, sCortexOrig.Vertices,  sCortex.center)      * sCortex.R;
vTemplateCortex = bst_bsxfun(@minus, sTemplateCortex.Vertices, sTemplateCortex.center) * sTemplateCortex.R;
vTemplateInner  = bst_bsxfun(@minus, sTemplateInner.Vertices,  sTemplateCortex.center) * sTemplateCortex.R;

% Parametrize the surfaces
p   = .2;   % Padding
th  = -pi-p   : 0.01 : pi+p;
phi = -pi/2-p : 0.01 : pi/2+p;
rCortex      = tess_parametrize_new(vCortex,      th, phi);
rTemplateCortex = tess_parametrize_new(vTemplateCortex, th, phi);

%ALIGNMENT

iThMax = bst_closest(th, 0);
[rMax,iPhiMax] = max(rCortex(:,iThMax));
[vMax(1),vMax(2),vMax(3)] = sph2cart(th(iThMax), phi(iPhiMax), rMax);
% Find the max radius for the mid-sagittal plane (phi=pi)
iThMin = bst_closest(th, pi);
[rMin,iPhiMin] = max(rCortex(:,iThMin));
[vMin(1),vMin(2),vMin(3)] = sph2cart(th(iThMin), phi(iPhiMin), rMin);
% Same for colin cortex
[rMax_c,iPhiMax_c] = max(rTemplateCortex(:,iThMax));
[vMax_c(1),vMax_c(2),vMax_c(3)] = sph2cart(th(iThMax), phi(iPhiMax_c), rMax_c);
[rMin_c,iPhiMin_c] = max(rTemplateCortex(:,iThMin));
[vMin_c(1),vMin_c(2),vMin_c(3)] = sph2cart(th(iThMin), phi(iPhiMin_c), rMin_c);

% Compute rotation around y axis
u = (vMax_c - vMin_c);
v = (vMax - vMin);
u = u([1 3]) ./ norm(u([1 3]));
v = v([1 3]) ./ norm(v([1 3]));
ay = atan2(v(2),v(1)) - atan2(u(2),u(1));
R_c = [cos(ay) 0 -sin(ay);
          0    1    0    ;
       sin(ay) 0  cos(ay)];
% Reorient template surfaces
vTemplateCortex = vTemplateCortex * R_c';
vTemplateInner  = vTemplateInner * R_c';
vMin_c = vMin_c * R_c';
vMax_c = vMax_c * R_c';

% Get bounding boxes for the 2 cortices
minv = min(vCortex);
maxv = max(vCortex);
minv_c = min(vTemplateCortex);
maxv_c = max(vTemplateCortex);
scale = (maxv-minv) ./ (maxv_c-minv_c);
offset = minv - minv_c .* scale;
% Force the template surfaces to fit into the subject box
vTemplateCortex = bst_bsxfun(@times, vTemplateCortex, scale);
vTemplateCortex = bst_bsxfun(@plus,  vTemplateCortex, offset);
vTemplateInner  = bst_bsxfun(@times, vTemplateInner, scale);
vTemplateInner  = bst_bsxfun(@plus,  vTemplateInner, offset);
vMin_c = vMin_c .* scale + offset; 
vMax_c = vMax_c .* scale + offset; 

% Parametrize the surfaces
% p   = .2;   % Padding
% th  = -pi-p   : 0.01 : pi+p;
% phi = -pi/2-p : 0.01 : pi/2+p;
rHead        = tess_parametrize_new(vHead,        th, phi);
rCortex      = tess_parametrize_new(vCortex,      th, phi);
rTemplateCortex = tess_parametrize_new(vTemplateCortex, th, phi);
rTemplateInner  = tess_parametrize_new(vTemplateInner,  th, phi);


%Compute Layer Sizes
iTopVert = (vHead(:,3) > 0);
radiusHead = mean(sqrt(sum(vHead(iTopVert,:).^2, 2)));
% Cortex radius: Average radius in the top part of the head
iTopVert = (vCortex(:,3) > 0);
radiusCortex = mean(sqrt(sum(vCortex(iTopVert,:).^2, 2)));
% Compute the erosions/dilatations values in meters, scaled by the size of current head
relLayerSize = thickness ./ sum(thickness);
layerSize = relLayerSize .* (radiusHead - radiusCortex);

% Inner skull: Apply colin cortex->innerskull transformation to subject's cortex
cortex2inner = rTemplateInner ./ rTemplateCortex;
rInner = rCortex .* cortex2inner;
% Limit growth of the inner skull with the head
iFix = find(rInner > rHead - layerSize(2) - layerSize(1));
rInner(iFix) = rHead(iFix) - layerSize(2) - layerSize(1);
% Force inner skull to include all the cortex
rInner = max(rInner, rCortex + 0.001);
% Grow head so that there is at least 2mm between the inner skull and the head
rHead = max(rHead, rInner + 0.002);
% Outer skull: Dilate inner skull, constrain with head
rOuter = min(rInner + layerSize(2), rHead - 0.001);

% Reinterpolate to get inner skull surface based on cortex surface
[thInner,phiInner] = cart2sph(vCortex(:,1), vCortex(:,2), vCortex(:,3));
rInner = interp2(th, phi, rInner, thInner, phiInner);
[vInner(:,1), vInner(:,2), vInner(:,3)] = sph2cart(thInner, phiInner, rInner);
% Reinterpolate to get outer skull surface
rOuter = interp2(th, phi, rOuter, thInner, phiInner);
% Recompute cartesian coordinates of the outer skull
[vOuter(:,1), vOuter(:,2), vOuter(:,3)] = sph2cart(thInner, phiInner, rOuter);

sOuter.Faces = sCortex.Faces;

% === DEFORM HEAD TO INCLUDE OUTER SKULL ===

% Reinterpolate to get head surface based on cortex surface
[thHead,phiHead] = cart2sph(vHead(:,1), vHead(:,2), vHead(:,3));
rHead = interp2(th, phi, rHead, thHead, phiHead);
[vHead(:,1), vHead(:,2), vHead(:,3)] = sph2cart(thHead, phiHead, rHead);

% Reproject into intial coordinates system
% sInner.Vertices = bst_bsxfun(@plus, vInner * inv(sCortex.R), sCortex.center);
% sOuter.Vertices = bst_bsxfun(@plus, vOuter * inv(sCortex.R), sCortex.center);
% sHeadBEM.Vertices  = bst_bsxfun(@plus, vHead  * inv(sCortex.R), sCortex.center);
sInner.Vertices = bst_bsxfun(@plus, vInner/sCortex.R, sCortex.center);
sOuter.Vertices = bst_bsxfun(@plus, vOuter/sCortex.R, sCortex.center);
sHeadBEM.Vertices  = bst_bsxfun(@plus, vHead/sCortex.R, sCortex.center);

sInner.Faces = sCortex.Faces;

sHeadBEM.Comment = sprintf('bem_head_%dV', length(sHeadBEM.Vertices));
sInner.Comment = '';
sHeadBEM.Comment = '';
sOuter.Comment = '';
sInner = my_in_tess_bst(sInner,1);
sHeadBEM = my_in_tess_bst(sHeadBEM,1);
sOuter = my_in_tess_bst(sOuter,1);

end

