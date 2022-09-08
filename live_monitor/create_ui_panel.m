function [ax1,ax2,btn]=create_ui_panel
    fig = uifigure;
    btn = uibutton(fig,'push',...
                   'Position',[630, 50, 50, 22],...
                   'Text', 'Sample',...
                   'ButtonPushedFcn', @(btn,event) plot_diagnostic(data));
    xstart = 10;
    ystart = 270;
    width = 600;
    height = 250;
    p1 = uipanel(fig,'Position',[xstart ystart width height]);
    ax1 = uiaxes(p1,'Position',[10 10 width-10 height-10]);
    xstart = 10;
    ystart = 10;
    width = 600;
    height = 250;
    p2 = uipanel(fig,'Position',[xstart ystart width height]);
    ax2 = uiaxes(p2,'Position',[10 10 width-10 height-10]);