% example_read.m
%
% Author:
%   Valerio De Carolis          <valerio.decarolis@gmail.com>

clear all; close all; clc;

path(path, '..');

%% import dataset
infile = 'example_dataset.arff';

% load arff
[data, relname, nomspec] = arff_read(infile);

% extract nominal specification attribute
type_class = nomspec.type_class;

%% plot dataset
plot([data.idx], [data.high], 'r.-'); grid on; hold on;
plot([data.idx], [data.med], 'g.-'); grid on; hold on;
plot([data.idx], [data.low], 'b.-'); grid on; hold on;

m_values = mean([ data.high; data.med; data.low ]');

for k = 1 : length(m_values)
    hr = refline(0, m_values(k));
    set(hr,'Color','k','LineStyle','--');
end

legend('high','med','low');

tl = title(relname);
xl = xlabel('idx');
yl = ylabel('value');
set(tl,'Interpreter','none');

set(tl,'FontSize', 14); 
set(xl,'FontSize', 12); 
set(yl,'FontSize', 12);

%% type histogram
T = {data.type_class};
[B,I,J] = unique(T);

f = figure();
hist(J,length(B)); grid on;
xlim([0.5 3.5]);

hp = findobj(f,'Type','patch');
set(hp,'FaceColor','r','EdgeColor','w');

% labels
[n,x] = hist(J,length(B));
text(x, n, type_class, 'horizontalalignment', ...
    'center', 'verticalalignment', 'bottom');

tl = title(relname);
xl = xlabel('class');
yl = ylabel('count');
set(tl,'Interpreter','none');

set(gca,'XTick',[]);
set(tl,'FontSize', 14); 
set(xl,'FontSize', 12); 
set(yl,'FontSize', 12);
