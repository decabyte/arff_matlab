% example_write.m
%
% Authors:
%   Valerio De Carolis          <valerio.decarolis@gmail.com>

clear all; close all; clc;

path(path, '..');

%% create data structure
data = struct();
relname = sprintf('dataset_%s', datestr(now,'yyyymmdd'));
outfile = sprintf('%s.arff', relname);

% nominal classes
type_class = { 'front', 'middle', 'rear' };

%% populate dataset
for i = 1 : 100
    data(i).idx = i;
    data(i).low = randi([0 33], 1);
    data(i).med = randi([34 66], 1);
    data(i).high = randi([67 100], 1);
    data(i).type_class = type_class{ randi([1 3]) };
end

%% declare nominal specification attributes
nomspec.type_class = type_class;

% save arff
arff_write(outfile, data, relname, nomspec);

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
