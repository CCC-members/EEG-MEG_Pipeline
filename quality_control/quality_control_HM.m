function [KCQ] = quality_control_HM(LF,Vertices,Faces,elect,verbosity)
%% K_CQ is a function to evaluate the quality of a given Lead Field based
% on the energy ratio over the Lead Field rows...
%
% Input:
%   K        : M/EEG Lead Fields
%   Vertices : Vertex values
%   Faces    : Vertices connection
%   elect    : Sensor position
%
% Output
%   KCQ      : Lead Field Control Quality, 1 Good, 0.5 Regular, 0 Bad
%
% Author:
%   Eduardo Gonzalez Moreira
%
% Date:
%   2018/10/22
% ------------------------------------------------------------------------
%% Initial values
if (nargin < 5) || isempty(verbosity)
    verbosity  = 1;
end
[Ne1,Np1]  = size(LF);
ch_qc        = 0;
count_good = 0;
count_regu = 0;
count_bad  = 0;
%% Estimation of average EMG
for ii = 1:Ne1
    d      = zeros(Np1,1);
    p_fix  = elect(ii,:);
    for jj = 1:Np1
        d(jj) = (sum([(p_fix(1)-Vertices(jj,1))^2,...
            (p_fix(2)-Vertices(jj,2))^2,...
            (p_fix(3)-Vertices(jj,3))^2]))^0.5;
    end
    d = d/max(d);
    d = 1-d;
    d = d/max(d);
    d = d.^6;
    k = (abs(LF(ii,:))/max(abs(LF(ii,:))))';
    if verbosity
        clf;
        figure(1); set(gcf,'Color','k');
        subplot(2,2,1:2); hold on; set(gca,'Color','k');
        plot(k,'r-'); plot(d,'y--');
        title(['Sensor E',num2str(ii)],'Color','w');
        subplot(2,2,3); hold on; set(gca,'Color','k');
        patch('Faces',Faces,'Vertices',Vertices,'FaceVertexCData',d+0.1*(rand(length(d),1)),'FaceColor','interp','EdgeColor','none','FaceAlpha',.95);
        scatter3(p_fix(1),p_fix(2),p_fix(3),100,1,'filled');
        colormap('hot');
        title('Ground Truth','Color','w');
        view(0,0);
        subplot(2,2,4); hold on; set(gca,'Color','k');
        patch('Faces',Faces,'Vertices',Vertices,'FaceVertexCData',k+0.1*(rand(length(d),1)),'FaceColor','interp','EdgeColor','none','FaceAlpha',.95);
        scatter3(p_fix(1),p_fix(2),p_fix(3),100,1,'filled');
        colormap('hot');
        title('Leadfield row','Color','w');
        view(0,0);
        pause(verbosity/1.2);
    end
    d(d<0.50) = 0;
    k(k<0.50) = 0;
    [ind_80]  = find(d>0.85);
    ener1_d = sum(d(ind_80));
    ener1_k = sum(k(ind_80));
    ener2_d = sum(d)-ener1_d;
    ener2_k = sum(k)-ener1_k;
    if ((ener1_k/ener1_d) > 0.7) && ((ener2_k/ener2_d) > 0.7)
        if verbosity
            disp([num2str(ii),' -> good quality with ratio = ',num2str(ener1_k/ener1_d)]);
        end
        count_good = count_good+1;
    elseif ((ener1_k/ener1_d) > 0.5) || ((ener2_k/ener2_d) > 0.5)
        if verbosity
            disp([num2str(ii),' -> regular quality with ratio = ',num2str(ener1_k/ener1_d)]);
        end
        count_regu = count_regu+1;
    else
        if verbosity
            disp([num2str(ii),' -> bad quality with ratio = ',num2str(ener1_k/ener1_d)]);
        end
        count_bad = count_bad+1;
        if count_bad > Ne1/3
            break
        end
    end    
end
%%
if count_bad > Ne1/3
    KCQ = 0;
elseif count_good > Ne1/2
    KCQ = 1;
else
    KCQ = 0.5;
end
end
