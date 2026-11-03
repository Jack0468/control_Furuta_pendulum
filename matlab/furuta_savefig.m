function furuta_savefig(fig, name, width_in, height_in)
%FURUTA_SAVEFIG Format a figure for the IEEE report and write it as a 300 dpi PNG.
%   width_in : 3.5 for one column, 7.16 for two columns [inches]
%   Figures go to ../figures, or to the folder in the environment variable
%   FURUTA_FIGDIR (used to preview results without overwriting the report's figures).
figdir = getenv('FURUTA_FIGDIR');
if isempty(figdir), figdir = fullfile('..', 'figures'); end
if ~exist(figdir, 'dir'), mkdir(figdir); end

set(fig, 'Units', 'inches', 'Position', [1 1 width_in height_in], 'Color', 'w', 'PaperPositionMode', 'auto');
for ax = findall(fig, 'Type', 'axes').'
    set(ax, 'FontSize', 8, 'FontName', 'Helvetica', 'LineWidth', 0.5, 'Toolbar', []);
    ax.Title.FontSize = 8.5; ax.Title.FontWeight = 'normal';
end
set(findall(fig, 'Type', 'legend'), 'FontSize', 7, 'Box', 'on', 'EdgeColor', [0.8 0.8 0.8], 'Color', 'w');
for ln = findall(fig, 'Type', 'line').'
    if ln.LineWidth < 1, ln.LineWidth = 1; end
end
exportgraphics(fig, fullfile(figdir, [name '.png']), 'Resolution', 300);
end
